class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(options = {})
    options[:path] ||= 'admin'

    devise_for 'comfy/users', :path => 'admin/users',
                 controllers: {
                   registrations: "users/registrations",
                   sessions: "users/sessions"
                  }

    scope :module => :comfy, :as => :comfy do

      scope options[:path], :module => 'admin' do
        controller :users do
          get 'users' => 'users#index'
          get 'new_user' => 'users#new'
          get 'users/account/:id' => 'users#show', as: :user
        end

        resources :redirect_rules

        controller :settings do
          get 'settings' => 'settings#index', as: :settings
          put 'settings' => 'settings#update'
          put 'settings/flush-page-cache' => 'settings#flush_pages_cache'
        end
      end


      scope :module => :admin do

        namespace :cms, :as => :admin_cms, :path => options[:path], :except => :show do
          get '/', :to => 'base#jump'
          resources :sites do
            resources :pages do
              get  :form_blocks,    :on => :member
              get  :toggle_branch,  :on => :member
              put :reorder,         :on => :collection
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :files do
              put :reorder, :on => :collection
            end
            resources :layouts do
              put :reorder, :on => :collection
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :snippets do
              put :reorder, :on => :collection
              resources :revisions, :only => [:index, :show, :revert] do
                patch :revert, :on => :member
              end
            end
            resources :categories
          end
        end
      end
    end
  end
end
