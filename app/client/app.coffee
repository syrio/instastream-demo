# Client-side Code

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  positionAll = ->
    columns = 5
    pixles = 10
    container = $('.container')
    width = parseInt(container.css('width'))
    container.each (index, item) ->
      item_top_pixles = pixles+parseInt(index/columns) * width
      item_left_pixles = pixles+(index%columns) * width
      $(item).css('top',  item_top_pixles+'px').css('left', item_left_pixles+'px')

  # Make a call to the server to retrieve existing media
  SS.server.app.init (response) ->
    if response?
      $('#wrapper').append($('#geo-image').tmpl(response))
      positionAll()

  # Listen for new media and append it to the screen
  SS.events.on 'newMedia', (ev) ->
    for media_object in ev.media
      image_url = media_object.images.low_resolution.url
      location = media_object.location?.name
      channel = media_object.meta?.location
      $('<img/>').attr('src', image_url).load () ->
        num_children = $('#wrapper').children().length
        if num_children < 15
              $('#wrapper').prepend($('#geo-image').tmpl(media_object))
              positionAll()
              return
        index = Math.floor(Math.random() * num_children)
        $container = $($('#wrapper').children()[index])
        $oldCube = $('.cube', $container)
        if $.browser.webkit?
          $newCube = $('<div class="cube in"><span class="location"></span><span class="channel"></span</div>')
          $newCube.prepend(this)
          $('.location', $newCube).html(location)
          $('.channel', $newCube).html(channel)
          $container.addClass('animating').append($newCube)
          $oldCube.addClass('out')
          $oldCube.bind 'webkitAnimationEnd', ->
            $container.removeClass('animating')
            $(this).remove()
        else
          $('img', $oldCube).attr('src', image_url)
          $('.location', $oldCube).html(location)
          $('.channel', $oldCube).html(channel)
