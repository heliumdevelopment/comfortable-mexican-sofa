class Comfy::Admin::RedirectRulesController < Comfy::Admin::Cms::BaseController
  before_filter :authorize

  def index
    @redirects = RedirectRule.paginate(page: params[:page])
  end

  def new
    @redirect = RedirectRule.new
    @path = "//" + request.host_with_port + "/"
  end

  def create
    @redirect = RedirectRule.new(redirect_params)

    if @redirect.save
      flash[:notice] = "Created Redirect"
      redirect_to :comfy_redirect_rules
    else
      flash[:error] = "Ah snap! #{@redirect.display_errors}"
      render 'new'
    end
  end

  def edit
    @redirect = RedirectRule.find(params[:id])
    @path = request.protocol + request.host + "/"
  end

  def update
    @redirect = RedirectRule.find(params[:id])

    if @redirect.update(redirect_params)
      flash[:notice] = "Updated Redirect"
      redirect_to edit_comfy_redirect_rule_path(@redirect)
    else
      flash[:error] = "Ah snap! #{@redirect.display_errors}"
      render 'edit'
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = "RedirectRule not found!"
    redirect_to :comfy_redirect_rules
  end

  def destroy
    @redirect = RedirectRule.find(params[:id])

    if @redirect.destroy
      flash[:notice] = "Snap crackel pop. Redirect is gone."
      redirect_to :comfy_redirect_rules
    else
      flash[:error] = "Ah snap! #{@redirect.display_errors}"
      render 'edit'
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = "RedirectRule not found!"
    redirect_to :comfy_redirect_rules
  end

  private

  def authorize
    authorize! :manage, RedirectRule
  end

  def redirect_params
    p = params.require(:redirect_rule).permit(:source, :destination, :active,
                        :source_is_regex)
    p[:source] = "/" + p[:source].gsub(/^\//,"")
    p[:destination] = "/" + p[:destination].gsub(/^\//,"")
    p
  end
end
