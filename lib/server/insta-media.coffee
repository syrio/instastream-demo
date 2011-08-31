getCurrentMediaObjects = (cb) ->
  
  media_objects_max =  14
  parse_error = 0
  R.lrange 'media:objects', 0, media_objects_max, (err, media_objects) ->
    if media_objects? and not err
      parsed_media_objects = media_objects.map (media_object) ->
        return JSON.parse(media_object)
      cb(parse_error, parsed_media_objects)
      
addCurrentMediaObjects = (geo_name, new_media_objects) ->
    for media_object in new_media_objects
      media_object.meta =
        location : geo_name.replace(/-/g, ' ')
      R.lpush('media:objects', JSON.stringify(media_object))

exports.currentMediaObjects = 
 get: getCurrentMediaObjects
 add: addCurrentMediaObjects

