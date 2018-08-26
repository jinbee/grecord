class UsersController < ApplicationController


  def signup
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path ,notice: 'アカウントを登録しました。'
    else
      render 'signup' 
    end
  end

  def info
  end

  def editpw
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    
    @user = User.find(params[:id])

    path = Rails.application.routes.recognize_path(request.referer)
    if path[:action] == 'edit'
      @user.attributes = params[:user].permit(:name, :email)
      if @user.save()
       redirect_to info_users_path , notice:"編集しました"
      else
       render 'edit'
      end
    elsif path[:action] == 'editpw'
      @user.attributes = params[:user].permit(:password_confirmation, :password)
      if @user.save(context: :editpw)
       redirect_to info_users_path , notice:"編集しました"
      else
       render 'editpw'
      end
    end    
    

  end
  
  def destroy
    session.delete(:user_id)
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = 'アカウントを削除しました'
    redirect_to root_path    
    
  end
  
  private
  def user_params
   params.require(:user).permit(:name,:email,:password,:password_confirmation,:user_id)
  end

  def useredit_params
   params.require(:user).permit(:name,:email)
  end

end
