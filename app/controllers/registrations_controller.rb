class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication
  before_filter :resource_name
  before_filter :configure_account_update_params, only: [:update]
  require 'securerandom'

  def resource_name
    :user
  end

  def new  
    redirect_to root_path unless current_user && current_user.global_admin?
    @user = User.new
  end

  def create
    acp = account_creation_params
    # another stuff here
    pwx = SecureRandom.urlsafe_base64
    acp['password'] = pwx
    acp['password_confirmation'] = pwx

    respond_to do |format|
      u = User.new(acp)
      if u.save
        u.send_reset_password_instructions
        format.html { redirect_to u, notice: "User was successfully created. Email to reset password successfully sent.".html_safe }
        format.json { render :show, status: :created, location: i }
      else
        errs = u.errors.full_messages.each { |message| "<li>#{ message }</li>" }.join('')
        format.html { redirect_to users_path, notice: "User failed to be created: #{errs}".html_safe }
        format.json { render json: u.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def update_resource(resource, params)
    if params[:password].blank? && params[:current_password].blank? && params[:password_confirmation].blank?
      params.delete(:current_password)
      params.delete(:password)
      params.delete(:password_confirmation)
      
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  private
  
  def account_creation_params
    if current_user.global_admin?
      params.require(:user).permit(:phone, :name, :email, :password, :password_confirmation, :current_password, :is_active, :global_admin)
    else
      params.require(:user).permit(:phone, :name, :email, :password, :password_confirmation, :current_password)
    end
  end

  def account_update_params
    if current_user.global_admin?
      params.require(:user).permit(:phone, :name, :email, :password, :password_confirmation, :current_password, :is_active, :global_admin)
    else
      params.require(:user).permit(:phone, :name, :email, :password, :password_confirmation, :current_password)
    end
  end

  def configure_account_update_params
    if current_user.global_admin?
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name,:email,:phone,:password, :password_confirmation, :current_password, :is_active, :global_admin])
    else
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name,:email,:phone,:password, :password_confirmation, :current_password])
    end
  end

end