class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy

  def index
	@title = "All users"
	@users = User.order("email").page(params[:page]).per(30)
  end

  def show
	  @user = User.find(params[:id])
	  @microposts = @user.microposts.page(params[:page]).per(30)
	  @title = @user.name
  end
      
  def new
	  if current_user.nil?
		  @user = User.new
		  @title = "Sign up"
	 else
		 redirect_to(root_path)
	 end

  end

  def create
    if current_user.nil?

	    @user = User.new(params[:user])
	    if @user.save
		    sign_in @user
		    flash[:success] = "Welcome to the Sample App!"
		    redirect_to @user
	    else
		    @title = "Sign up"
		    render 'new'
	    end
   else
	   redirect_to(root_path)
   end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
	    flash[:success] = "Profile updated"
	    redirect_to @user
    else
	    @title = "Edit user"
	    render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user?(user)
    	flash[:failure] = "Cannot delete yourself."
    else
	user.destroy
	flash[:success] = "User destroyed."
    end
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private
  
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_path) unless current_user?(@user)
	end

	def admin_user
		redirect_to(root_path) unless current_user.admin?
	end
end
