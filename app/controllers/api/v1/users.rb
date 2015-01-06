module API
  module V1
    class Users < Grape::API
      include API::Defaults

      helpers do
        extend Grape::API::Helpers
      end

      resource :ideas do

        ################################# Get ###################################

        ################### / ####################

        desc "Return ideas list"

        params do
          use :default_order
        end

        paginate per_page: PAGINATE, max_per_page: PAGINATE_MAX

        get "/" do
          garner.options(expires_in: EXPIRES_TIME) do

          end
        end

        ###################/[:id]####################

        desc "Return detail of one idea"

        params {use :id}

        get ":id"  do
          []
        end

        ################################# Post ###################################

        ############# POST /ideas###############

        desc "create a new idea"

        params do
        end

        post "/" do
          authenticated
        end
      end
    end#End of Idea
  end
end
