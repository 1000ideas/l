class L::Settings
  include Singleton
  include ActiveModel::Validations
  include ActiveModel::Translation
  extend ActiveModel::Translation

  @@fields = []
  cattr_accessor :fields

  def attributes=(attrs = {})
    attrs.each do |k, v|
      send(:"#{k}=", v) if respond_to?(:"#{k}=")
    end
  end

  def update_attributes(attrs = {})
    self.attributes = attrs
    self.save
  end

  def to_key
    nil
  end

  def save
    if valid?
      begin
        L::Content.transaction do
          self.class.fields.each do |f|
            value = if respond_to?(:"#{f}_for_save")
              send :"#{f}_for_save"
            else
              send f
            end
            L::Content.set("settings:#{f.to_s.dasherize}", value )
          end
        end
        true
      rescue
        false
      end
    else
      false
    end
  end

  def persisted?
    true
  end

  def from_db(name)
    L::Content.value("settings:#{name.to_s.dasherize}")
  end

  class << self
    def create_text_field(*names)
      names = names.first if names.first.is_a?(Hash)
      names.each do |name, default|
        fields << name
        define_method(name) do
          instance_variable_get("@#{name}") || from_db(name) || default
        end
        define_method(:"#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end
      end
    end

    def create_boolean_field(*names)
      names = names.first if names.first.is_a?(Hash)
      names.each do |name, default|
        fields << name
        define_method(name) do
          v = instance_variable_get("@#{name}")
          if v.nil?
            bdv = from_db(name)
            v = (dbv && bdv.to_i == 1) || default
          else
            v
          end
        end
        define_method(:"#{name}_for_save") do
          if send(:"#{name}") == true
            '1'
          elsif send(:"#{name}") == false
            '0'
          end
        end
        define_method(:"#{name}=") do |value|
          instance_variable_set("@#{name}", value && value.to_i == 1)
        end
      end
    end

    def create_time_field(*names)
      names = names.first if names.first.is_a?(Hash)
      names.each do |name, default|
        fields << name
        define_method(name) do
          if instance_variable_get("@#{name}").nil?
            instance_variable_set("@#{name}", from_db(name))
          end
          (instance_variable_get("@#{name}") && Time.at(instance_variable_get("@#{name}")).utc) || default
        end

        define_method(:"#{name}_for_save") do
          send(:"#{name}").try(:to_i)
        end

        define_method(:"#{name}=") do |value|
          current_value = if value.blank?
            nil
          elsif String === value
            /\A\d+\Z/ === value ? value.to_i : Time.parse(value).utc.to_i
          elsif value.respond_to(:to_time)
            value.to_time.utc.to_i
          else
            value
          end

          instance_variable_set("@#{name}", current_value)
        end
      end
    end

    def configure
      yield self
    end
  end



end
