class Comfy::Cms::ContentController < Comfy::Cms::BaseController
  protect_from_forgery except: :expire_template

  # Authentication module must have `authenticate` method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize

  # Authorization module must have `authorize` method
  include ComfortableMexicanSofa.config.public_authorization.to_s.constantize

  before_action :load_fixtures
  before_action :load_cms_page,
                :authenticate,
                :authorize,
                :only => :show

  rescue_from ActiveRecord::RecordNotFound, :with => :page_not_found

  caches_page :show, if: lambda { !current_user }

  def show
    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url(:relative)
    else
      respond_to do |format|
        format.html { render_page }
        format.json { render :json => @cms_page }
      end
    end
  end

  def render_sitemap
    render
  end

  def expire_template
    expire_page(params[:path])

    render json: { message: "Expired #{params[:path]}" }
  end

  def admin_editable
    render json: current_user
  end
protected

  def render_page(status = 200)
    if @cms_layout = @cms_page.layout
      render  :inline       => @cms_page.content_cache,
              :layout       => @cms_layout.app_layout,
              :status       => status,
              :content_type => mime_type
    else
      render :text => I18n.t('comfy.cms.content.layout_not_found'), :status => 404
    end
  end

  # it's possible to control mimetype of a page by creating a `mime_type` field
  def mime_type
    mime_block = @cms_page.blocks.find_by_identifier(:mime_type)
    mime_block && mime_block.content || 'text/html'
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixture::Importer.new(@cms_site.identifier).import!
  end

  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")
  end

  def page_not_found
    @cms_page = @cms_site.pages.published.find_by_full_path!('/404')

    respond_to do |format|
      format.html { render_page(404) }
    end
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Page Not Found at: \"#{params[:cms_path]}\"")
  end
end
