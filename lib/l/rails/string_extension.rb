String.class_eval do
  def urlize
    ActiveSupport::Inflector.transliterate(self).downcase.gsub(/[^a-z0-9]/, '-')
  end
end
