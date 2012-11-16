module L
  # Moduł helpera dodającego metody do generowania linków lightboksa.
  module LightboxHelper

    # Generuj link do treści wyświetlanej w lightboksie.
    #
    # * *Argumenty*:
    #
    #   - +content+ - treść linka
    #   - +url+ - url do treści wyświetlanej w lighboksie
    #   - +options+ - opcje linku. Jeśli link ma należeć do kolekcji należy
    #     ustawić opcję +:collection+ na nazwę kolekcji.
    #
    def lightbox_tag(content, url, options = {})
      collection = options.delete(:collection)
      rel = 'lightbox'
      rel << "[#{collection}]" if collection
      options = {rel: rel}.merge(options)
      link_to content, url, options
    end
    
    # Generuj link do obrazka wyświetlanego w lightboksie.
    #
    # * *Argumenty*:
    #
    #   - +resource+ - Obiekt załącznika modelu (Paperclip::Attachment),
    #   - +options+ - opcje linka. Dodatkowo można ustawić opcje +:collection+
    #     na nazwę kolekcji jeśli obrazek ma należeć zbioru elementów
    #     wyświetlanych w lightboksie. Opcje +:thumb_style+ i +:original_style+
    #     to nazwy stylów załacznika które mają być wyświetlane w podglądzie i
    #     jako treść wyświetlana w lightboksie.
    #
    def image_lightbox_tag(resource, options = {})
      raise ArgumentError.new("resource has to have :url method") unless resource.respond_to? :url
      thumb_style = options.delete(:thumb_style) || :thumb
      original_style = options.delete(:original_style) || :original
      lightbox_tag(image_tag(resource.url(thumb_style)), resource.url(original_style), options) 
    end

    # Generuj link do kolekcji obrazków wyświetlanej w lightboksie.
    #
    # * *Argumenty*:
    #
    #   - +resource+ - Obiekt załącznika modelu (Paperclip::Attachment),
    #   - +name+ - nazwa kolekcji, domyslnie 'collection',
    #   - +options+ - opcje linka. Dodatkowo można ustawić opcje +:thumb_style+
    #     oraz +:original_style+, tak samo jak w image_lightbox_tag.
    def collection_lightbox_tag(resource, name = nil, options = {}) 
      options[:collection] = name || 'collection'
      image_lightbox_tag(resource, options)
    end

  end
end
