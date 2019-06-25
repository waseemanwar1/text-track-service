require 'faktory_worker_ruby'

require 'connection_pool'
require 'faktory'
require 'securerandom'
require "google/cloud/speech"
require "google/cloud/storage"
require "speech_to_text"

module WM
    
    class AudioWorker
      include Faktory::Job
      faktory_options retry: 0

      def perform(data)
          
          SpeechToText::Util.video_to_audio(data["published_file_path"],data["recordID"]);

          if(data["service"] === "google")
            ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{data["auth_key"]}";
            WM::GoogleWorker.perform_async(data);
          elsif(data["service"] === "ibm") 
            WM::IbmWorker.perform_async(data);   
          end


      end
    end
    
    class GoogleWorker
      include Faktory::Job
      faktory_options retry: 0

      def perform(data)
          if(data["service"] === "google")

             #google_speech_to_text 
              SpeechToText::BBBGoogleCaptions.google_speech_to_text(data["published_file_path"],data["recordID"],data["auth_key"],data["google_bucket_name"])

              #dice = GamesDice.create '4d6+3'
              #puts dice.roll  #  => 17 (e.g.)
          end
      end
    end
    
    class IbmWorker
      include Faktory::Job
      faktory_options retry: 0

      def perform(data)
          if(data["service"] === "ibm")
             SpeechToText::BBBIbmCaptions.ibm_speech_to_text(data["published_file_path"],data["recordID"],data["auth_key"])
          end
      end
    end
    
    
end
