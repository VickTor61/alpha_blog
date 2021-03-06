class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :show]
  before_action :require_current_user, only: [:edit, :update, :destroy]
  before_action :require_admin, only: [:destroy]
  
  def index
    @pagy, @users = pagy(User.all, items: 5)
  end

  def show
    @pagy, @user_articles = pagy(@user.articles, items: 3)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id

      flash[:success] = "Welcome to the alpha blog #{ @user.username }"
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = 'User was successfully updated'
      redirect_to articles_path
    else
      render :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:danger] = "Sucessfully deleted user and all user articles"
    redirect_to users_path
  end


  private
  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def require_current_user
    if current_user != @user && !current_user.admin?
      flash[:danger] = 'You can only edit your account'
      redirect_to root_path
    end
  end
  
  def require_admin
    if logged_in? && !current_user.admin?
      flash[:danger] = 'Only admin users can perform that action'
      redirect root_path
    end
  end
end