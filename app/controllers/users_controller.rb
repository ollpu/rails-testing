class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.privileges = User.priv_level_user
    if @user.save
      redirect_to root_url, :notice => "Uusi käyttäjä luotiin!"
    else
      render "new"
    end
  end
  
  def user_params
    params.require(:user).permit(:email, :password, :whole_name)
  end
end
