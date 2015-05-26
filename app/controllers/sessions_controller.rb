class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Tervetuloa, " + user.full_name + "!"
    else
      flash.alert[:notice] = "Sähköposti tai salasana on väärä."
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Kirjauduit ulos!"
  end
end
