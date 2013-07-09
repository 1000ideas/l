module L
  # Model reprezentujący adres email zapisany na newsletter.
  #
  # * *Atrybuty*:
  #
  #   - +mail+ - adres email osoby zapisanej
  #   - +confirm_token+ - token używany do potwierdzenia prawdziwości adresu
  #     email. Potwierdzony adres email ma token równy +nil+.
  class NewsletterMail < ActiveRecord::Base
    scope :ordered, order("`#{table_name}`.`created_at` DESC")
    self.per_page = 10

    attr_accessible :mail, :confirm_token
    before_create :set_token

    validates :mail, 
      presence: true, 
      uniqueness: true, 
      format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }


    # Metoda klasy pozwalająca potwierdzić adres email z użyciem tokena.
    #
    # * *Argumenty*:
    #
    #   - +token+ - token słuzący do potwierdzenia. 
    #
    # * *Zwraca*:
    #
    #   - (Boolean) prawda gdy adres email z podanym tokenem istnieje w bazie i
    #     udało się do zaktualizować, w przeciwnym przypadku fałsz.
    #
    def self.confirm(token)
      return false if token.blank?
      n = self.find_by_confirm_token(token)
      return false if n.nil?
      n.update_attribute(:confirm_token, nil)
    end

    def confirm
      self.update_attribute(:confirm_token, nil)
    end

    protected

    # Przy tworzeniu nowego adresu (zapisaniu się użytkownika) uzupełnij pole
    # +token+.
    def set_token
      require 'digest/sha1'
      self.token = Digest::SHA1.hexdigest(Time.now.to_s)
    end
  end
end
