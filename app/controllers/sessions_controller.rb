class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  #layout 'application'
  respond_to :json
  def create
    resource = warden.authenticate!(
      :scope => resource_name, :recall => "#{controller_path}#failure")
    #user = current_user.extend(UserRepresenter).to_hash
    #user[:email] = current_user.email
    #user[:ideas] = current_user.ideas.select([:id, :title])
    #user[:teams] = current_user.products.stage(:seedling).select([:id, :title])
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in Success",
                      :user => current_user,
                    }
  end

  def destroy
    warden.authenticate!(
      :scope => resource_name, :recall => "#{controller_path}#failure")
    sign_out
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out" }
  end

  def failure
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Credentials Failed" }
  end

  def show_current_user
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200,
           :json => { :success => true,
                      :info => "Current User",
                      :user => current_user }
  end

end
