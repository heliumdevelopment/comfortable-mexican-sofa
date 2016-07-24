class Comfy::Admin::SettingsController < Comfy::Admin::Cms::BaseController
  before_filter :authorize

  def index
    @setting = Comfy::Setting.first || Comfy::Setting.create
  end

  def update
    @setting = Comfy::Setting.first

    if @setting.update(setting_params)
      flash[:notice] = "Updated settings"
      render 'index'
    else
      flash[:alert] = "#{setting.display_errors}"
      render 'index'
    end
  end

  def flush_pages_cache
    Comfy::Cms::Page.all.each do |page|
      page.clear_page_cache
    end

    flash[:notice] = "Cache flushed"
    redirect_to :back
  end

  private

  def authorize
    authorize! :read, :settings
  end

  def setting_params
    params.require(:comfy_setting).permit(*Comfy::Setting.field_keys)
  end
end
