module L
  class Page < ActiveRecord::Base
    validates :title, presence: true
    validates :url, presence: true
    validates :url, uniqueness: true

    attr_accessible :title, :url, :content, :meta_description, :meta_keywords,
      :position, :parent_id, :hidden_flag, :translations_attributes

    translates :title, :content
    accepts_nested_attributes_for :translations

    acts_as_tree order: "position"
  
    after_save :set_default_position

    def unhidden_children
      self.children.delete_if { |ch| ch.hidden_flag == 1 }
    end
    
    def self.search(search, hidden = 1)
      find :all,
        joins: :translations,
        conditions:
        ['(page_translations.title LIKE :pattern OR page_translations.content LIKE :pattern) AND locale = :locale AND hidden_flag <> :flag',
        {
          pattern: "%#{search}%",
          locale: I18n.locale,
          flag: hidden
        }
      ]
    end

    def ancestor?(page)
      not ancestors.find {|p| p.id == page.id}.nil?
    end

    def drop_after(where_page)
      if position > where_page.position
        n_pos = where_page.position + 1
        L::Page.where(['position >= ? and position < ?', n_pos, position]).each do |p|
          p.update_attribute :position, p.position + 1
        end
        update_attribute :position, n_pos
      else
        n_pos = where_page.position
        L::Page.where(['position > ? and position <= ?', position, n_pos]).each do |p|
          p.update_attribute :position, p.position - 1
        end
        update_attribute :position, n_pos
      end
    end

    def change_parent(p)
      pid = p ? p.id : nil
      fc = p.children.order('position').first unless p.nil?
      fcp = fc ? fc.position : 1
      update_attributes position: (fcp - 1), parent_id: pid
    end

    def set_sibling_and_drop_after(where_page)
      change_parent(where_page.parent)
      drop_after(where_page)
    end

    def get_token
      (ancestors.reverse.map { |p| p.url } + [url]).join('/')
    end

    private
    def set_default_position
      if position.nil?
        update_attribute :position, id
      end
    end

  end
end
