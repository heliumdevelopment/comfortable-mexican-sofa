class ActionDispatch::Routing::Mapper

  def comfy_route_cms_admin(options = {})
    options[:path] ||= 'admin'

    devise_for :users, path: 'admin/users',
                 controllers: {
                   registrations: "users/registrations",
                   sessions: "users/sessions"
                  }

    scope :module => :comfy, :as => :comfy do
      scope :module => :admin do
        controller :users do
          get 'users' => 'users#index'
          get 'new_user' => 'users#new'
          get 'users/account/:id' => 'users#show', as: :user
        end
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
