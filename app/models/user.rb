class User < ActiveRecord::Base
  attr_accessible :email, :password

  has_secure_password

  validates_presence_of :password, :on => :create
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[a-zA-Z][\w\.-]*@[a-zA-Z0-9]/
  
  has_many :sessions
end
