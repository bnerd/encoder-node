utils = require './util.js.coffee'
child_process = require 'child_process'
fs = require 'fs'

class Encoder

  constructor: ->
    @version = "0.0.1"
    @job = null
    console.log "b'nerd Encoder #{@version}"

  encode: (job, callback) ->
    console.log "processing job: #{job.id}"
    meta = new utils.Metadata()
    
    job_id = job.data.job_id
    output_file = job.data.output_file
    input_file = job.data.input_file
    output_length = job.data.output_length || null

    file = "/tmp/#{job_id}.txt"
    meta.get_meta "/home/besu/input_foo.mp4", (meta) -> 
      # override duration if user specified length
      meta.duration_in_s = output_length if output_length
      
      # trigger progress to notify that we're encoding
      job.progress(0, meta.duration_in_s)
      
      # encode :)
      child_process.exec "ffmpeg -y -i #{input_file} -t 200 #{output_file}.mp4 2>&1 | tee #{file}", (error, stdout, stderr) ->
        fs.unwatchFile(file)
        callback()

      # watch progress, write method for that
      fs.watchFile "#{file}", (curr, prev) ->
        child_process.exec("tail -n1 #{file}", (error, stdout, stderr) ->
          output = stdout.split(/\r\n|\r|\n/)
          output = output[output.length - 2]
          if output
            t = output.match(/time=\d*\.\d*/)
            if t
              duration = meta.duration_in_s
              time = t[0].split("=")[1] # time=12.12
              progress = ((time / duration)*100)
              console.log "progress: #{progress}"
              completed = time
              job.progress(time, meta.duration_in_s)
            else
              progress = 0
        )          
    
exports.Encoder = Encoder
