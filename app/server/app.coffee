# Server-side Code
media = require('../../lib/server/insta-media')

exports.actions =
  
  init: (cb) ->
    media.currentMediaObjects.get( (err, media_objects) ->
      if media_objects.length and not err
        cb(media_objects)
      else
        cb()
    )
