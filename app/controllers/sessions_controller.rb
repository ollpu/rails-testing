class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.auth(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Tervetuloa, " + user.full_name + "!"
    else
      flash[:notice] = "Sähköposti tai salasana on väärä."
      render "new"
    end
  end

  def destroy
    unless session[:user_id] == nil
      session[:user_id] = nil
      redirect_to root_url, :notice => "Kirjauduit ulos!"
    else
      redirect_to root_url, :notice => "Et ole kirjautunut sisään."
    end
  end
end
