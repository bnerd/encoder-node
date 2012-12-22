@version = '0.0.1'
console.log "Starting Encoder-Node #{@version}"

encoder = require './encoder.js.coffee'
downloader = require './downloader.js.coffee'
kue = require('/home/besu/code/kue')
jobs = kue.createQueue()

downloader = new downloader.Downloader()
encoder = new encoder.Encoder()
#uploader = new uploader.Uploader()

jobs.process 'download', "2", (job, done) ->
  # download
  downloader.download job, (resp) ->
    console.log resp
    
jobs.process 'encode', "2", (job, done) ->
  # download
  encoder.encode job, (resp) ->
    console.log resp
    
jobs.process 'upload', "2", (job, done) ->
  # notify
  #uploader.upload job, (resp) ->
  #  console.log resp        
  
jobs.process 'notify', "2", (job, done) ->
  # notify
  #uploader.upload job, (resp) ->
  #  console.log resp 
