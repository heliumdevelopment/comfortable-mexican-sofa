class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, only: []
  
  def new
    authorize! :manage, :users
    @tmp_password = Faker::Internet.password(8)
    super
  end
  
  def create
    authorize! :manage, :users
    super
  end
  
  def edit
    @resource = User.find(params[:id])
    
    authorize! :manage, @resource
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "User not found!"
    redirect_to :admin_users
  end
  
  def update
    self.resource = User.find(account_update_params[:id])
    authorize! :manage, resource
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      # sign_in resource_name, resource, bypass: true
      flash[:notice] = "Successfully updated #{resource.first_name}"
      respond_with resource, location: admin_user_path(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  
  def destroy
    authorize! :manager, :users
    resource = User.find(params[:id])
    resource.destroy
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    if resource == current_comfy_user
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
    else
      flash[:notice] = "Snap, crackle, pop. That user is gone."
      redirect_to :admin_users
    end
  end
  
  protected
  
  def sign_up(resouce_name, resource)
    true
  end
  
  def after_sign_up_path_for(resource)
    admin_users_path
  end
  
  private
  
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :account_type)
  end

  def account_update_params
    params.require(:user).permit(:id, :first_name, :last_name, :email, :password, :password_confirmation, :account_type)
  end
  
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
  
end