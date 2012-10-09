module L
  module LightboxHelper

    def lightbox_tag(content, url, options = {})
      collection = options.delete(:collection)
      rel = 'lightbox'
      rel << "[#{collection}]" if collection
      options = {rel: rel}.merge(options)
      link_to content, url, options
    end
    
    def image_lightbox_tag(resource, options = {})
      raise ArgumentError.new("resource has to have :url method") unless resource.respond_to? :url
      thumb_style = options.delete(:thumb_style) || :thumb
      original_style = options.delete(:original_style) || :original
      lightbox_tag(image_tag(resource.url(thumb_style)), resource.url(original_style), options) 
    end

    def collection_lightbox_tag(resource, name = nil, options = {}) 
      options[:collection] = name || 'collection'
      image_lightbox_tag(resource, options)
    end

  end
end
