class ActionDispatch::Routing::Mapper

  def comfy_route_cms(options = {})

    ComfortableMexicanSofa.configuration.public_cms_path = options[:path]

    scope :module => :comfy, :as => :comfy do
      namespace :cms, :path => options[:path] do
        get 'cms-css/:site_id/:identifier(/:cache_buster)' => 'assets#render_css', :as => 'render_css'
        get 'cms-js/:site_id/:identifier(/:cache_buster)'  => 'assets#render_js',  :as => 'render_js'

        scope 'backend' do
          get '/admin_editable' => 'content#admin_editable',
            as: :admin_editable
          put '/expire_template' => 'content#expire_template',
            as: :expire_template
        end

        if options[:sitemap]
          get '(:cms_path)/sitemap' => 'content#render_sitemap',
            :as           => 'render_sitemap',
            :constraints  => {:format => /xml/},
            :format       => :xml
        end

        get '/:format' => 'content#show', :as => 'render_page', :path => "(*cms_path)"
      end
    end
  end
end
