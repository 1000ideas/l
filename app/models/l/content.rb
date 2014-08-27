class L::Content < ActiveRecord::Base
  self.primary_key = :id

  class << self
    def set(id, value)
      (self.where(id: id).first || self.new).tap do |object|
        object.id = id
        object.value = value
      end.save!
    end

    def get(id)
      self.where(id: id).first || self.new
    end

    def value(id)
      get(id).try(:value)
    end
  end
end
