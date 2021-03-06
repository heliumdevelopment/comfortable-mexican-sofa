require 'rails/generators/active_record'

module Comfy
  module Generators
    class CmsGenerator < Rails::Generators::Base

      include Rails::Generators::Migration
      include Thor::Actions

      source_root File.expand_path('../../../../..', __FILE__)

      def generate_migration
        destination   = File.expand_path('db/migrate/01_create_cms.rb', self.destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, 'create_cms')

        if destination
          puts "\e[0m\e[31mFound existing cms_create.rb migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template 'db/migrate/01_create_cms.rb', 'db/migrate/create_cms.rb'
        end
      end

      def generate_initializer
        copy_file 'config/initializers/comfortable_mexican_sofa.rb',
          'config/initializers/comfortable_mexican_sofa.rb'
      end

      def generate_routing
        route_string  = "  comfy_route :cms_admin, :path => '/admin'\n\n"
        route_string << "  # Make sure this routeset is defined last\n"
        route_string << "  comfy_route :cms, :path => '/', :sitemap => false\n"
        route route_string[2..-1]
      end

      def generate_cms_seeds
        directory 'db/cms_fixtures', 'db/cms_fixtures'
      end

      def generate_assets
        copy_file 'app/assets/javascripts/comfy/admin/cms/custom.js.coffee',
          'app/assets/javascripts/comfy/admin/cms/custom.js.coffee'
        copy_file 'app/assets/stylesheets/comfy/admin/cms/custom.sass',
          'app/assets/stylesheets/comfy/admin/cms/custom.sass'
      end

      def install_devise
        generate("devise:install")
      end

      def install_redirector
        rake("redirector_engine:install:migrations")
      end

      def install_phrasing
        rake("phrasing:install")
      end

      def generate_users_migration
        destination   = File.expand_path('db/migrate/02_devise_create_comfy_users.rb', self.destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, '02_devise_create_comfy_users')

        if destination
          puts "\e[0m\e[31mFound existing devise_create_comfy_users.rb migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template 'db/migrate/02_devise_create_comfy_users.rb', 'db/migrate/devise_create_comfy_users.rb'
        end
      end

      def generate_settings_migration
        destination = File.expand_path('db/migrate/03_create_comfy_settings.rb', self.destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, '03_create_comfy_settings')

        if destination
          puts "\e[0m\e[31mFound existing create_comfy_settings.rb migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template 'db/migrate/03_create_comfy_settings.rb', 'db/migrate/create_comfy_settings.rb'
        end
      end

      def show_readme
        readme 'lib/generators/comfy/cms/README'
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

    end
  end
end
