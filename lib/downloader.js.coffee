class Downloader

  http = require 'http'
  url = require("url")
  sys = require("sys")
  fs = require 'fs'  
 
  constructor: ( options = {} ) ->
    @version = '0.0.1'
    @storage_path = options.storage_path || '/tmp/'
    console.log "b'nerd Download #{@version}"
    
  download: (job, callback) ->
    input_file = job.data.input_file 
    
    info = url.parse(input_file)
    protocol = info.protocol || 'http:'
    port = info.port || 80
    host = info.hostname || null
    path = info.pathname
    href = info.href
    
    console.log info
    
    request = http.get input_file, (res) ->
      total = res.headers['content-length'] || 0
      completed = 0
      
      file = fs.createWriteStream "/tmp/filename"
      res.on "data", (chunk) ->
        console.log "chunk"
        file.write chunk
        completed += chunk.length
        job.progress(completed, total)
      res.on "end", ->
        file.end
        console.log "file downloaded"
        callback
  
exports.Downloader = Downloader
