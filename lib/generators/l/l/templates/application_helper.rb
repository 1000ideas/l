    def short(value, length=50)
      v = strip_tags(value)
      if v.mb_chars.length > length
        v.mb_chars.slice(0,length-3).to_s + "..."
      else
        v
      end
    end

    def selection_tag(object, options = {})
      options.merge! :class => 'selection'
      check_box_tag 'selected[]', object.id, false, options 
    end

    def breadcrumbs(*value)
      bread = ['<a href="/">'+I18n.t('breadcrumbs.home')+'</a>']
      bread += value
      instantiate_yield :breadcrumbs, bread.join('<img src="/images/layout/arrow-right.png" />')
    end

    def breadcrumbs_admin(*value)
      bread = ['<a href="/admin">'+I18n.t('admins.show.title')+'</a>']
      bread += value
      instantiate_yield :breadcrumbs, bread.join(' <span class="separator">&rsaquo;</span> ')
    end

    def title(value)
      instantiate_yield :title, value
    end

    def keywords(value)
      instantiate_yield :keywords, value
    end

    def description(value)
      instantiate_yield :description, value
    end

    def yield_breadcrumbs
      raw @value_for_meta_breadcrumbs
    end

    def yield_description
      @value_for_meta_description||t('meta.description')
    end

    def yield_keywords
      @value_for_meta_keywords||t('meta.keywords')
    end

    def yield_title
      @value_for_meta_title||t('meta.title')
    end

    private
    def instantiate_yield key, value
      value = t("meta.#{key}") if value.blank?
      if instance_variable_defined?("@value_for_meta_#{key}")
        v = instance_variable_get("@value_for_meta_#{key}")
        instance_variable_set("@value_for_meta_#{key}", v + value)
      else
        instance_variable_set("@value_for_meta_#{key}", value)
      end
    end
