class SgamesController < ApplicationController
  before_action :chk_login,only:[:update,:create,:destroy,:index,:edit] 
  def index
   @sgames = Sgame.where(user_id:current_user.id)
  end

  def new
    @sgames = Sgame.new
  end

  def edit
    @sgames = Sgame.find(params[:id])
  end

  def update
    @sgames = Sgame.find(params[:id])

    if @sgames.update(sgame_params)
     redirect_to sgames_path,notice:"編集しました"
    else
     render 'edit'
    end
  end

  def create
    @sgames = Sgame.new(sgame_params)
    @sgames.user_id = current_user.id
    if @sgames.save

      redirect_to sgames_path  ,notice: 'ゲームを追加しました。'
    else

      render 'new' 
    end
  end

  def destroy
    @sgame = Sgame.find(params[:id])
    @sgame.destroy
    redirect_to sgames_path,notice: 'ゲームを削除しました'
  end

  def toggle
    @sgame = Sgame.find(params[:id])

    if @sgame.status == 'true'
      @sgame.update_attribute(:status, nil)
      redirect_to sgames_path,notice: @sgame.gname + 'を無効にしました。'
    else
      @sgame.update_attribute(:status, 'true')
      redirect_to sgames_path,notice: @sgame.gname + 'を有効にしました。'
    end


  end
 
  private 
  
   def sgame_params
    params.require(:sgame).permit(:gname,:status)
   end
 
 
end
