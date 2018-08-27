class SgamesController < ApplicationController
  before_action :chk_login,only:[:update,:create,:destroy,:index,:edit]
  before_action :find_sgame,only:[:update,:destroy,:edit]
  
  def index
   @sgames = Sgame.where(user_id:current_user.id)
  end

  def new
    @sgames = Sgame.new
  end

  def edit
  #  @sgames = Sgame.find_by(id:params[:id],user_id:current_user.id)
  end

  def update
  #  @sgames = Sgame.find_by(id:params[:id],user_id:current_user.id)
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
   # @sgame = Sgame.find_by(id:params[:id],user_id:current_user.id)
    @sgames.destroy
    redirect_to sgames_path,notice: 'ゲームを削除しました'
  end

  def toggle
    @sgame = Sgame.find_by(id:params[:id],user_id:current_user.id)

    if @sgame.status == 'true'
      @sgame.update_attribute(:status, nil)
      redirect_to sgames_path,notice: @sgame.gname + 'の課金から我を取り戻しました。'
    else
      @sgame.update_attribute(:status, 'true')
      redirect_to sgames_path,notice: @sgame.gname + 'を課金する事にしてしまいました。'
    end
  end
 
  private 
  
   def sgame_params
    params.require(:sgame).permit(:gname,:status)
   end
   
   def find_sgame
    @sgames = Sgame.find_by(id:params[:id],user_id:current_user.id)
   end
 
 
end
