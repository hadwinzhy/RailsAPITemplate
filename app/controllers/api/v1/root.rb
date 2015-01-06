module API
  module V1
    class Root < Grape::API

      all_files =  Dir.glob("app/controllers/api/v1/*.rb")
      file_names = all_files.map {|path| File.basename(path, ".rb")}
      file_names -= ["root"] #this file

      file_names.each do |name|
        mount "API::V1::#{name.camelize}".constantize
      end

      get "/" do


      end

      add_swagger_documentation base_path: "/api", api_version: 'v1', hide_documentation_path: true
    end
  end
end
