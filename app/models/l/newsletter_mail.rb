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
    self.per_page = 15

    attr_accessible :mail, :confirm_token
    before_create :set_token

    scope :unconfirmed, lambda { where("`#{table_name}`.`confirm_token` IS NOT NULL") }
    scope :confirmed, lambda { where(confirm_token: nil) }

    set_mass_actions :destroy, :confirm
    define_perform_action(:confirm) { update_all(confirm_token: nil) }

    validates :mail,
      presence: true,
      uniqueness: true,
      format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

    scope :filter_by_mail, lambda{|title| where("`#{table_name}`.`mail` LIKE ?", "%#{title}%")}
    scope :filter_by_created_before, lambda{|date| where("`#{table_name}`.`created_at` < ?", Date.parse(date))}
    scope :filter_by_created_after, lambda{|date| where("`#{table_name}`.`created_at` > ?", Date.parse(date))}

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

    def confirmed?
      confirm_token.nil?
    end

    protected

    # Przy tworzeniu nowego adresu (zapisaniu się użytkownika) uzupełnij pole
    # +token+.
    def set_token
      require 'digest/sha1'
      self.confirm_token = Digest::SHA1.hexdigest(Time.now.to_s)
    end
  end
end
