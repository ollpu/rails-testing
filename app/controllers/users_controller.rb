class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def index
    if current_user && current_user.privileges >= User.priv_level_admin
      @users = User.all
    else
      redirect_to root_url, :notice => "Sinulla ei ole oikeuksia sivulle /users."
    end
  end
  
  def create
    @user = User.new(user_params)
    @user.privileges = User.priv_level_user
    if @user.save
      redirect_to log_in_url, :notice => "Uusi käyttäjä luotiin!"
    else
      render "new"
    end
  end
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
  end
end
