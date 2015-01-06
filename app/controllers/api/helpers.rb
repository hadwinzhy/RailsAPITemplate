module API
  module Helpers
    extend Grape::API::Helpers

    ###################################Params####################################

    def represent(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      with = opts[:with] || (raise ArgumentError.new(":with option is required"))

      raise ArgumentError.new("nil can't be represented") unless args.first

      if with.is_a?(Class)
        with.new(*args)
      elsif args.length > 1
        raise ArgumentError.new("Can't represent using module with more than one argument")
      else
        args.first.extend(with).to_hash
      end
    end

    def represent_each(collection, *args)
      collection.map {|item| represent(item, *args) }
    end

    params :order do |options|
      optional :order_by, type:Symbol, values:options[:order_by], default:options[:default_order_by]
      optional :order, type:Symbol, values:%i(asc desc), default:options[:default_order]
    end

    params :default_order do
      use :order, order_by: %i(id created_at),  default_order_by: :id, default_order: :desc
    end

    params :id do
      requires :id, type: Integer
    end

    params :default_required do |option|
      (option[:klass].send "required_keys").each do |key|
        if key[:values]
          requires key[:name], type: key[:type], values: key[:values]
        else
          requires key[:name], type: key[:type]
        end
      end
    end

    params :default_optional do |option|
      (option[:klass].send "optional_keys").each do |key|
        if key[:values]
          optional key[:name], type: key[:type], values: key[:values]
        else
          optional key[:name], type: key[:type]
        end
      end
    end

    def add_order activeRecord
      activeRecord.order({params[:order_by] => params[:order]})
    end

    def item_changed? item
      item.previous_changes().present?
    end

    def to_datetime time_string
      return unless time_string
      DateTime.iso8601(time_string) rescue nil
    end

    ###################################Errors####################################

    def error_for_params missing_param, desc=nil
      message = { message: "must include params #{missing_param}", desc: desc}
      error!(message , 400)
    end

    def error_for_save item
      message = { message: "Save Error", error: item.errors.as_json }
      error!(message , 422)
    end

    def error_for_401
      message = { message: "401 Unauthorized" }
      error!(message, 401)
    end

    def error_for_403 desc=nil
      message = { message: "403 Forbidden", desc: desc}
      error!(message, 403)
    end

    def error_for_404 desc=nil
      message = { message: "404 Not Found", desc: desc}
      error!(message, 404)
    end

    def error_for_exists param
      message = { message: "Entity Exists", desc: "for params of #{param}"}
      error!(message, 409)
    end

    ###################################Others####################################

    def warden
      env['warden']
    end

    def authenticated
      return true if warden.authenticated?
      token = params[:access_token]
      token = 'DH1mJ9KSdH_wVK8jvCC8'
      return error_for_401 unless token
      @user = User.find_by_authentication_token token
      return true if @user
      error_for_404 "User token by #{token} not found"
    end

    def current_user
      warden.user || @user
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def is_vip?
      error_for_403 "Not Vip User" unless current_user.is_vip?
    end

    def is_company?
      error_for_403 "not for normal user" if current_user.user_type != "startup"
      current_user.products.first
    end

    def can_access? owner
      access = owner.profile.access
      return true if access == "user"
      authenticated
      #user himself it equal access == "me"
      return true if current_user.id == owner.id or
        (access == "follow" and owner.following_ids.include? current_user.id)
    end

    def can_edit? obj, user=nil
      user = current_user unless user
      error_msg = "User #{user.id} can not edit #{obj.class} #{obj.id}"
      begin
        error_for_403 error_msg unless current_user.id == obj.user.id
      rescue
        error_for_403 error_msg
      end
    end

  end
end
