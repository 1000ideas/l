  has_role :admin, :user, default: :user
  
  devise :database_authenticatable, :timeoutable,
         :rememberable, :trackable, :registerable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :set_role

  validates :email, :presence => true
  validates :email, :uniqueness => true
  validates :email, :format => { :with => /\\A([^@\\s]+)@((?:[-a-z0-9]+\\.)+[a-z]{2,})\\Z/i }
  validates :password, :presence => true, :confirmation => true, :length => {:minimum => 5}, :on => :create
  validates :password, :allow_blank => true, :confirmation => true, :length => {:minimum => 5}, :on => :update
