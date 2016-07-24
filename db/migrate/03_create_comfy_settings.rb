class CreateComfySettings < ActiveRecord::Migration
  def change
    create_table :comfy_settings do |t|
      enable_extension "hstore"

      t.hstore :fields

      t.timestamps null: false
    end
  end
end
