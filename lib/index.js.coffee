@version = '0.0.1'
console.log "Starting Encoder-Node #{@version}"

encoder = require './encoder.js.coffee'
downloader = require './downloader.js.coffee'
kue = require('kue')
jobs = kue.createQueue()

downloader = new downloader.Downloader()
encoder = new encoder.Encoder()

jobs.process 'video', "2", (job, done) ->
  # download
  downloader.download job, (resp) ->
    console.log resp
  
  #encoder.encode(job, done)
  # upload
  # notify requester
