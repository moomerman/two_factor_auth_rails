class User < ActiveRecord::Base
  attr_accessible :email, :password

  has_secure_password

  validates_presence_of :password, :on => :create
  validates_presence_of :auth_secret
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[a-zA-Z][\w\.-]*@[a-zA-Z0-9]/
  
  before_validation :assign_auth_secret, :on => :create
  
  has_many :sessions
  
  private
    def assign_auth_secret
      self.auth_secret = ROTP::Base32.random_base32
    end
end
