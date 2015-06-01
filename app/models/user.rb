class User < ActiveRecord::Base
  
  attr_accessor :password, :password_confirmation
  before_save :encypt_password
  
  validates :password_confirmation,
    presence: { :message => "Vahvista salasana." }
  validates :password,
    presence: { :message => "Salasana vaaditaan!" },
    confirmation: { :on => :create, :message => "Salasanat eivät täsmää." }
  validates :email,
    presence: { :message => "Sähköpostiosoite vaaditaan!" },
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create,
      :message => "Sähköpostiosoite ei kelpaa." },
    uniqueness: { :message => "Sähköpostiosoite on jo käytössä.", case_sensitive: false }
  validates :full_name,
    presence: { :message => "Syötä jokin nimi." }
  
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
  
  
  def self.priv_level_user;   1 end # Can comment
  def self.priv_level_writer; 2 end # Can publish articles
  def self.priv_level_admin;  3 end # Can modify other users' information
end
