class User < ActiveRecord::Base
  
  attr_accessor :password
  before_save :encypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create, :message => "Salasana vaaditaan!"
  validates_presence_of :username
  validates_uniqueness_of :username
  
  def encypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def self.auth (email, password)
    user = find_by_email(email)
    if user && user.password_hash ==
        BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    end

  end
  
  
  def priv_level_user;   1 end # Can comment
  def priv_level_writer; 2 end # Can publish articles
  def priv_level_admin;  3 end # Can modify other users' information
end
