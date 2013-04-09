@version = '0.0.1'
console.log "Starting Encoder-Node #{@version}"

encoder = require './encoder.js.coffee'
downloader = require './downloader.js.coffee'
kue = require('/home/besu/code/kue')
jobs = kue.createQueue()

#downloader = new downloader.Downloader()
#uploader = new uploader.Uploader()

jobs.process 'video', "2", (job, done) ->
  # download
  #  downloader.download job, (resp) ->
  #    console.log resp
  encoder = new encoder.Encoder()
  encoder.encode job, (resp) ->
    console.log resp
    done()
