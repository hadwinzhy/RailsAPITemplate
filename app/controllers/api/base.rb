require 'grape-swagger'
require "garner/mixins/rack"

module API
  class Base < Grape::API
    helpers Garner::Mixins::Rack

    mount API::V1::Root
    #mount API::V2::Root
  end

end
