class Comfy::Admin::UsersController < Comfy::Admin::Cms::BaseController
  def index
    @users = User.all
    authorize! :read, :users
  end

  def show
    authorize! :read, User

    if params[:id]
      @user = User.find(params[:id])
    else
      @user = current_account
    end

    @events = @user.events.paginate({
      page: params[:page]
    })
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Couldn't find that user"
    redirect_to :back
  end
end
