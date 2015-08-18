class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]


  def new
  end

  # 用户重置密码
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # 创建重置密码 Token
    	@user.create_reset_digest
      # 发送重置密码邮件
    	@user.send_password_reset_email

    	flash[:info] = "Email sent with password reset instructions"
    	redirect_to root_url
    else
    	flash.now[:danger] = "Email address not found"
    	redirect_to 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash[:danger] = "Password can't be empty"
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless ( @user && @user.activated? && @user.authenticated?(:reset, params[:id] ) )
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
