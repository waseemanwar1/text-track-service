require 'faktory_worker_ruby'

require 'connection_pool'
require 'faktory'
require 'securerandom'
require "speech_to_text"
require "sqlite3"
ENV['RAILS_ENV'] = "development"
require "./config/environment"

module WM            
  class SpeechmaticsWorker
    include Faktory::Job
    faktory_options retry: 0

    def perform(data, id)
      u = Caption.find(id)
      u.update(progress: "finished audio & started #{u.service} transcription process")
      SpeechToText::SpeechmaticsS2T.speechmatics_speech_to_text(data["published_file_path"],data["recordID"],data["userID"],data["auth_key"])
              
      u.update(progress: "done with #{u.service}")
          
    end
  end
end