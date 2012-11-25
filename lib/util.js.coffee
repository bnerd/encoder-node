child_process = require 'child_process'

class Metadata

  constructor: ->

  meta_object = (meta, callback) ->
    m = {}
    try m.aspect = meta.aspect[0].split(" ")[1]
    try m.pixel = meta.pixel[0].split(" ")[1]
    try m.video_bitrate = meta.video_bitrate[1]
    try m.fps = meta.fps[1]
    try m.container = meta.container[1]
    try m.creation_time = meta.creation_time[1]
    try m.duration = meta.duration[1]
    if meta.duration
      m.duration_in_s = get_duration_in_s(meta.duration)    
    try m.video_codec = meta.video_codec[1]
    try m.video_resolution = meta.resolution[1]
    try m.video_width = meta.resolution[2]
    try m.video_height = meta.resolution[3]

    callback m
    
  get_meta: (file, callback) ->
    meta = {}
    child_process.exec "ffmpeg -i #{file}", (error, stdout, stderr) ->
      meta.aspect = /DAR ([0-9\:]+)/.exec(stderr) || null
      meta.pixel  = /[SP]AR ([0-9\:]+)/.exec(stderr) || null
      meta.video_bitrate = /bitrate: ([0-9]+) kb\/s/.exec(stderr) || null
      meta.fps           = /([0-9\.]+) (fps|tb\(r\))/.exec(stderr) || null
      meta.container     = /Input #0, ([a-zA-Z0-9]+),/.exec(stderr) || null
      meta.creation_time = /creation_time\s+:\s+([0-9]{4}-[0-9]{2}-[0-9]{2}\s([0-9]{2}):[0-9]{2}:[0-9]{2})/.exec(stderr) || null 
      meta.title         = /(INAM|title)\s+:\s(.+)/.exec(stderr) || null
      meta.artist        = /artist\s+:\s(.+)/.exec(stderr) || null
      meta.album         = /album\s+:\s(.+)/.exec(stderr) || null
      meta.track         = /track\s+:\s(.+)/.exec(stderr) || null
      meta.date          = /date\s+:\s(.+)/.exec(stderr) || null
      meta.video_stream  = /Stream #([0-9\.]+)([a-z0-9\(\)\[\]]*)[:] Video/.exec(stderr)[0] || null
      #meta.video   = /Video: ([\w]+)/.exec(stderr) || null
      meta.duration      = /Duration: (([0-9]+):([0-9]{2}):([0-9]{2}).([0-9]+))/.exec(stderr) || null
      meta.resolution    = /(([0-9]{2,5})x([0-9]{2,5}))/.exec(stderr) || null
      #meta.audio_bitrate = /Audio:(.)*, ([0-9]+) kb\/s/.exec(stderr) || null
      #meta.sample_rate   = /([0-9]+) Hz/i.exec(stderr) || null
      #meta.audio_codec   = /Audio: ([\w]+)/.exec(stderr) || null
      #meta.channels      = /Audio: [\w]+, [0-9]+ Hz, ([a-z0-9:]+)[a-z0-9\/,]*/.exec(stderr) || null
      #meta.audio_stream  = /Stream #([0-9\.]+)([a-z0-9\(\)\[\]]*)[:] Audio/.exec(stderr) || null
      #meta.is_synched    = (/start: 0.000000/.exec(stderr) !== null)
      #meta.rotate        = /rotate[\s]+:[\s]([\d]{2,3})/.exec(stderr) || null
      #meta.getVersion    = /ffmpeg version (?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)/i.exec(stderr) || null
      
      meta_object(meta, callback)
    
  get_duration_in_s = (duration) ->
    if duration[2] && duration[3] && duration[4]
      h = parseInt duration[2] * 60 * 60
      m = parseInt duration[3] * 60
      s = parseInt duration[4]
      duration_in_s = h + m + s
      
exports.Metadata = Metadata
