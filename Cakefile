querystring = require('querystring')
https = require('https')
http = require('http')
request = require('request')
config = require('./config/app').config


cities = 
  'London'        : { lat: '51.507222', lng: '-0.1275' },
  'Los Angeles'   : { lat: '34.05', lng :'-118.25' },
  'San Francisco' : { lat:  '37.761216', lng: '-122.43953' },
  'Buenos Aires'  : { lat: '-34.603333', lng: '-58.381667' },
  'Tokyo'         : { lat: '35.700556', lng: '139.715' },
  'Chicago'       : { lat: '41.881944', lng: '-87.627778' },
  'Boston'        : { lat: '42.357778', lng: '-71.061667' },
  'Madrid'        : { lat: '40.4', lng: '-3.683333' }


for own city, location of cities
  delete cities[city]
  cities[city.toLowerCase().replace(' ', '-')] = location

watchCity = (city, cb) ->
  
  watch_url = 'https://' + config.instagram.api.host + config.instagram.api.subscriptions_path  
  
  callback_url = 'http://' + config.http.external.hostname + ':' + config.http.external.port + '/callbacks/geo/' + city.name + '/'

  insta_options = 
    client_id : config.instagram.api.client_id, client_secret : config.instagram.api.client_secret,
    object: 'geography', aspect: 'media', 
    lat: city.location.lat, lng : city.location.lng, radius: '5000',  callback_url : callback_url

  boundary = 'e908f80f278f'
  insta_fields = ''
  for own field_name, field_value of insta_options
    insta_fields += '----' + boundary + '\r\n'
    insta_fields += 'Content-Disposition: ' + 'form-data; name="' + field_name + '"' + '\r\n\r\n';
    insta_fields += field_value + '\r\n'
  insta_fields += '----' + boundary + '--' + '\r\n'

  headers = 
    'Expect' : '100-continue', 'Accept' : '*/*', 
    'Content-Type' : 'multipart/form-data; boundary=' + '--' + boundary,

  request.post {uri: watch_url, body: insta_fields, headers: headers}, (error, response, body) ->
    if !error && response.statusCode == 200
      cb(0)
    else
      cb(error)


removeWatches = (cb) ->
  insta_options = 
    object: 'all', client_id : config.instagram.api.client_id, client_secret : config.instagram.api.client_secret, 
  delete_path = config.instagram.api.subscriptions_path + '?' + querystring.stringify(insta_options)
  delete_url = 'https://' + config.instagram.api.host + delete_path

  headers = { 'Accept' : '*/*', 'Content-length' : '0' }
  console.log delete_url
  request.del {uri: delete_url, headers: headers}, (error, response, body) ->
    console.log response.statusCode
    if !error && response.statusCode == 200
      cb(0)
    else
      cb(error)



option '-w', '--watch [CITY]', 'a city to watch pictures from'
option '-t', '--lat [Latitude]', 'the latitude of the city'
option '-o', '--lng [Longtitude]', 'the longtitude of the city'

task 'watch', 'adds another city to the current pictures watch list', (options) ->
  given_name = options.watch
  city_name = given_name.toLowerCase().replace(' ', '-')
  if cities[city_name]?
    location = cities[city_name]
  else
    if options.lat? and options.lng?
      
      location = { lat: options.lat.replace('--', '-'), lng: options.lng.replace('--', '-') }
    else
      console.log 'Cannot watch city - doesn\'t exist in tge default cities dictionary and no cooridnates specified by the suer'
      return
  console.log city_name, location      
  watchCity({name: city_name, location: location}, (err, name) ->
    if err == 0
      console.log "Now watching the city of #{ given_name }"
    else
      console.log "Failed to watch the city of #{ given_name }, error:", err?.message ? 'unknown'
  )


task 'all', 'adds all known cities to the current pictures watch list', (options) ->
  for own city_name, city_location of cities
    do (city_name) ->
      watchCity({name: city_name, location: city_location}, (err) ->
        if err == 0
          console.log "Now watching the city of #{ city_name }"
        else
          console.log "Failed to watch the city of #{ city_name }, error:", err?.message ? 'unknown'
      )

task 'clear', 'clears all active city watches', (options) ->  
  removeWatches ( (err) -> 
    if err == 0
      console.log 'Cleared all watches'
    else
      console.log 'Failed to clear watches, error:', err.message ? 'unknown'
  )
  
task 'list', 'lists all cities in default DB name', (options) ->
  console.log 'Default cities: '
  for own city_name, city_location of cities
    console.log '\t'+city_name
  console.log 'There is no need to specify a location on --watch, just mention the city name (free format works)'
