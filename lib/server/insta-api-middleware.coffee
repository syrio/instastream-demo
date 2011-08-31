url = require('url')
https = require('https')
media = require('./insta-media')

class CallBackHandler

  route:
    matcher : '/callbacks/geo/(.*)/',
    POST : 'handleInstagramUpdates',
    GET : 'handleInstagramVerificationCheck'
  
  constructor:  (request, response, next) ->
    request.body = ''
    request.on 'data', (data_chunk) ->
      request.body += data_chunk
    request.on 'end', =>
      @handleAPICallbackRequest(request, response, next)
    request.on 'error', ->
      next()
  
  handleAPICallbackRequest:  (@request, @response, @next) ->
    method = @request.method
    re = RegExp(@route.matcher)
    geo_name = re.exec(@request.url)?[1]
    if geo_name?
      if (action = @route[method])?
        @body = @request.body
        @params = url.parse(@request.url, true).query
        @config = SS.config.instagram.api
        this[action].call(this, geo_name)
    else
      @next()

        
  handleInstagramUpdates: (geo_name) ->
    try
      updates = JSON.parse(@body)
    catch error
      return @sendResponse('FAIL')

    for update in updates
      if update.object == 'geography'
        @processInstagramGeography geo_name, update
    @sendResponse('OK')

  handleInstagramVerificationCheck: ->    
    content = @params['hub.challenge'] ? 'No hub.challenge present'
    @sendResponse(content)

  buildQueryOptions: (geo_name, update, cb) ->
    path = @config.base_path
    path += @config.geographies_path + (update.object_id ? '') + @config.recent_media_path

    getMinID = (geo_name, cb) ->
      R.get('min-id:channel:' + geo_name, cb)


    getMinID(geo_name, (err, min_id) =>
      query = '?' + 'client_id=' + @config.client_id
      if min_id?
        query += '&min_id=' + min_id
      else
        query += '&count=' + '1'

      path += query

      options = 
        host: @config.host
        path: path
      cb(options)
    )

  processInstagramGeography: (geo_name, update) ->

    retrieveNewGeographyMedia = (query_options, cb) ->
      https.get(query_options, (response) ->
        response_data = ''
        response.on('data', (data_chunk) ->
          response_data += data_chunk
        )
        response.on('end', () ->
          try
            parsed_media = JSON.parse(response_data)
          catch error
            cb(error)
          cb(0, parsed_media['data'])
        )
      )

    publishNewGeographyMedia = (error, new_media) ->
      
      return if error or not new_media?
    
      setMinID = (geo_name, parsed_media) ->
        sorted = parsed_media.sort( (a,b) -> 
          parseInt(b.id) - parseInt(a.id)
        )
        id = sorted[0]?.id ? parsed_media[0]?.id
        if id?
          R.set('min-id:channel:' + geo_name, parseInt(id))
          
      setMinID(geo_name, new_media)
      media.currentMediaObjects.add(geo_name, new_media)
      SS.publish.broadcast 'newMedia', { type: 'newMedia', media: new_media }
    
    @buildQueryOptions(geo_name, update, (query_options) ->
      retrieveNewGeographyMedia(query_options, publishNewGeographyMedia)
    )

  verifyInstagramUpdates: (updates) ->
  

  sendResponse: (content) ->
    @response.writeHead(200, {"Content-Type": "text/plain"})
    @response.write(content)
    @response.end()
    

exports.call = (request, response, next) ->
  handler = new CallBackHandler(request, response, next)

