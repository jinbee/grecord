class BudgetsController < ApplicationController
  before_action :chk_login,only:[:list,:create,:destroy,:update,:edit,:list]
  before_action :find_budget,only:[:destroy,:update,:edit]
  
  def index
    redirect_to list_budgets_path
  end
  
  def list
    @budgets = Budget.where(user_id:current_user.id )
    p @budgets
    p '-----'
  end
  
  def destroy
    #@sgame = Budget.find_by(month:params[:id],user_id:current_user.id)
    @budget.destroy
    redirect_to list_budgets_path,notice: '削除しました'
  end
  
  def create
    ext_chk =  Budget.find_by(month:budget_params[:month],user_id:current_user.id)
    
    if ext_chk.present?
      if ext_chk.update(budget_params)
        redirect_to list_budgets_path,notice:"編集しました"
      else
        @budget = ext_chk
        render 'edit'
      end
    else  
      @budget = Budget.new(budget_params)
      @budget.user_id = current_user.id
      if @budget.save
        redirect_to list_budgets_path  ,notice: @budget.month.to_s+'月予算を設定しました。'
      else
        render 'new' 
      end
    end
    
  end
  
  def new
    @budget = Budget.new
  end
  
  def update
    #@budget = Budget.find(params[:id])
    #@budget = Budget.find_by(id:params[:id],user_id:current_user.id)
    
    if @budget.update(budget_params)
      redirect_to list_budgets_path,notice:"編集しました"
    else
      render 'edit'
    end
  end
  
  def edit
    #record = Budget.find_by(id:params[:id],user_id:current_user.id)
    #@budget = record
  end
  
  private 
  
  def budget_params
    params.require(:budget).permit(:budget,:month)
  end
  
   def find_budget
    @budget = Budget.find_by(id:params[:id],user_id:current_user.id)
   end  
  
end
