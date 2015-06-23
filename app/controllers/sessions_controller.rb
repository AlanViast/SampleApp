class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
        # Login
    else
        flash[:danger] = "Invalid email/password combination"
        render 'new'
    end
  end

  def destory

  end
end