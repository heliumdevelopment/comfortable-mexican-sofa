class Comfy::Admin::UsersController < Comfy::Admin::Cms::BaseController
  def index
    @users = Comfy::User.all
    authorize! :read, :users
  end

  def show
    authorize! :read, Comfy::User

    if params[:id]
      @user = Comfy::User.find(params[:id])
    else
      @user = current_account
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Couldn't find that user"
    redirect_to :back
  end
end
