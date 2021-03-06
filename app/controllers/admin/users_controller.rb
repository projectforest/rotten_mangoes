class Admin::UsersController < ApplicationController
  before_action :require_admin

  def require_admin
    if !current_user.try(:admin)
      flash[:error] ="Unauthorized Access"
      redirect_to movies_path
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:id] = @user.id
      redirect_to movies_path, notice: "Welcome aboard, #{@user.firstname}!"
    else
      render :new
    end
  end

  def index
    @users = User.order("lastname").page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      UserMailer.delete_email(@user).deliver
      redirect_to admin_users_path, notice: "User deleted from database"
    else
      redirect_to admin_users_path, notice: "can't get rid of me bruh"
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :firstname, :lastname, :admin, :password, :password_confirmation)
  end

end
