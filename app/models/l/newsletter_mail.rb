module L
  class NewsletterMail < ActiveRecord::Base
    attr_accessible :mail, :confirm_token

    validates :mail, 
      presence: true, 
      uniqueness: true, 
      format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }


    def self.confirm(token)
      return false if token.blank?
      n = self.find_by_confirm_token(token)
      return false if n.nil?
      n.update_attribute(:confirm_token, nil)
    end
  end
end
