utils = require './util.js.coffee'
child_process = require 'child_process'
ffmpeg = require("/home/besu/src/node-fluent-ffmpeg/lib/fluent-ffmpeg.js")
fs = require 'fs'

class Encoder

  constructor: ->
    @version = "0.0.2"
    console.log "b'nerd Encoder #{@version}"
    @job = ''
    @callback = ''

  encode: (job, callback) ->
    console.log "processing job: #{job.id}"
    
    # analyze job (outputs)
    outputs = [
      {
        id: 123
        # video options
        video_codec: 'libx264'
        video_bitrate: 1024
        video_size: '640x360'
        aspect_ratio: '16:9'
        # audio options
        audio_codec: 'libfdk_aac'
        audio_bitrate: '128'
        audio_channels: 2
        # additional options
        auto_padding: true
      }
    ]
    console.log outputs
    #transcode(job, ->
    #  console.log "transcoding done"
    #)

  transcode = (job, callback) ->
    job_id = job.data.job_id
    output_file = job.data.output_file
    input_file = job.data.input_file
    output_length = job.data.output_length || null
    job.step("analyzing")
    Metalib = require("fluent-ffmpeg").Metadata

    # make sure you set the correct path to your video file
    metaObject = new Metalib(input_file)
    metaObject.get (metadata, err) ->    
      proc = new ffmpeg(source: input_file, timeout: 99999)
        .withAspect('16:9')
        .withSize("640x360")
        .applyAutopadding(true)
        .withVideoBitrate('1024k')
        .withVideoCodec('libx264')
        .addOption("-r", "25")
        .withAudioCodec('libfdk_aac')
        .withAudioChannels(2)
        .addOption("-bufsize", "1024k")
        .addOption("-g", "60")
        .addOption("-keyint_min", "60")
        .addOption("-pass", "1")
        .onProgress( (progress) ->
          total_frames = (metadata.durationsec * metadata.video.fps) || 0
          current_frame = progress.frames || 0
          console.log metadata.durationsec
          console.log total_frames
          console.log current_frame
          console.log progress.timemark
          time = progress.timemark.split(':') || null
          if time
            h = parseInt(time[0] * 60 * 60)
            m = parseInt(time[1] * 60)
            s = parseInt(time[2])
            current_time = h + m + s
            console.log current_time
            console.log(current_time / metadata.durationsec)
            job.progress(current_time, metadata.durationsec)
        )      
        .saveToFile(output_file, (stdout, stderr) ->
          console.log stdout
          console.log "first pass"
          callback()
          #second_pass '1024k'
          #second_pass '2048k'
        )

  second_pass = (bitrate)->  
    Metalib = require("fluent-ffmpeg").Metadata

    # make sure you set the correct path to your video file
    metaObject = new Metalib(@input_file)
    metaObject.get (metadata, err) ->
      @job.step("transcoding")
      proc = new ffmpeg(source: @input_file, timeout: 99999)
        .withAspect('16:9')
        .withSize("640x360")
        .applyAutopadding(true)
        .withVideoBitrate(bitrate)
        .withVideoCodec('libx264')
        .withAudioCodec('libfdk_aac')
        .withAudioChannels(2)
        .addOption("-r", "25")
        .addOption("-bufsize", bitrate)
        .addOption("-g", "60")
        .addOption("-keyint_min", "60")
        .addOption("-pass", "2")
        .onProgress( (progress) ->
          total_frames = (metadata.durationsec * metadata.video.fps) || 0
          current_frame = progress.frames || 0
          console.log metadata.durationsec
          console.log total_frames
          console.log current_frame
          console.log progress.timemark
          time = progress.timemark.split(':') || null
          if time
            h = parseInt(time[0] * 60 * 60)
            m = parseInt(time[1] * 60)
            s = parseInt(time[2])
            current_time = h + m + s
            console.log current_time
            @job.progress(current_time, metadata.durationsec)
        )
        .saveToFile(@output_file + "_#{bitrate}.mp4", (stdout, stderr) ->
          console.log "second pass"
          console.log stderr
          @callback()
        )        
#    file = "/tmp/#{job_id}.txt"
#    meta.get_meta "/home/besu/input_foo.mp4", (meta) -> 
#      # override duration if user specified length
#      meta.duration_in_s = output_length if output_length
#      
#      # trigger progress to notify that we're encoding
#      job.progress(0, meta.duration_in_s)
#      
#      # encode :)
#      child_process.exec "ffmpeg -y -i #{input_file} -t 200 #{output_file}.mp4 2>&1 | tee #{file}", (error, stdout, stderr) ->
#        fs.unwatchFile(file)
#        callback()

#      # watch progress, write method for that
#      fs.watchFile "#{file}", (curr, prev) ->
#        child_process.exec("tail -n1 #{file}", (error, stdout, stderr) ->
#          output = stdout.split(/\r\n|\r|\n/)
#          output = output[output.length - 2]
#          if output
#            t = output.match(/time=\d*\.\d*/)
#            if t
#              duration = meta.duration_in_s
#              time = t[0].split("=")[1] # time=12.12
#              progress = ((time / duration)*100)
#              console.log "progress: #{progress}"
#              completed = time
#              job.progress(time, meta.duration_in_s)
#            else
#              progress = 0
#        )          
    
exports.Encoder = Encoder
