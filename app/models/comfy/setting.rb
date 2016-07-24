class Comfy::Setting < ActiveRecord::Base
  self.table_name = "comfy_settings"

  after_initialize :set_fields

  store_accessor :fields

  def self.field_keys
    ComfortableMexicanSofa.config.settings
  end

  private

  def set_fields
    self.fields ||= {}

    self.class.field_keys.each do |field|
      define_singleton_method(field) do
        fields[field]
      end

      define_singleton_method(field + "=") do |value|
        fields[field] = value
      end
    end
  end
end
