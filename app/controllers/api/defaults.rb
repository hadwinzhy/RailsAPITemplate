module API
  module PrettyJSON
    def self.call(object, env)
      JSON.pretty_generate(JSON.parse(object.to_json))
    end
  end

  module Defaults
    extend ActiveSupport::Concern

    EXPIRES_TIME = 15.seconds
    EXPIRES_LONG_TIME = 1.minutes
    PAGINATE = 15
    PAGINATE_MAX = 30

    included do
      include Grape::Kaminari
      helpers API::Helpers

      version 'v1'
      format :json
      formatter :json, PrettyJSON

      # global handler for simple not found case
      rescue_from ActiveRecord::RecordNotFound do |e|
        error_response(message: e.message, status: 404)
      end

      # global exception handler, used for error notifications
      rescue_from :all do |e|
        if Rails.env.development?
          raise e
        else
          Raven.capture_exception(e)
          error_response(message: "Internal server error", status: 500)
        end
      end

      # HTTP header based authentication
      before do
        error!('Unauthorized', 401) unless params['api_key'] == "fuckthegfw"
      end
    end

  end
end
