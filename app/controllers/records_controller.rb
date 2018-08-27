class RecordsController < ApplicationController
  before_action :chk_login,only:[:mypage,:create,:monthinfo,:destroy,:update,:list,:detail,:event]
  before_action :find_record,only:[:edit,:update,:destroy]
  
  def index
    if logged_in?
      redirect_to mypage_records_path
    end
  end
  
  def mypage
    #@sgames = Records.find(current_user.id)
    @user = current_user
    @record = Record.new
    @record.recorddate = Time.now + 60 * 60 * 9
    @select = {}
    sgames =  @user.sgames.where(status:"true")
    
    if sgames.blank?
      redirect_to sgames_path,notice:  '1つ以上のゲームを登録して課金中の状態にして下さい。'
    else   
      sgames.each do |g|
        #next if g.status == 'false'
        @select[g.gname] = g.id
      end
    end  
  end
  
  def create
    
    @record = Record.new(record_params)
    @record.user_id = current_user.id
    if @record.recorddate.nil?
      @record.recorddate = Time.now + 60 * 60 * 9
    end   
    
    if @record.maxrate.nil?
      @record.maxrate = 0
    end  
    
    if @record.save
      redirect_to  mypage_records_path,notice: '記帳しました。'
    else
      @user = current_user
      @select = {}
      sgames =  @user.sgames.all
      sgames.each do |g|
        next if g.status == 'false'
        @select[g.gname] = g.id
      end
      render 'records/mypage'
    end
  end
  
  def edit
    #@record = Record.find(params[:id])
    @user = current_user
    @select = {}
    sgames =  @user.sgames.all
    sgames.each do |g|
      next if g.status == 'false'
      @select[g.gname] = g.id
    end
  end
  
  def monthinfo
    
    month = Time.strptime(params[:month]+' 1日', "%Y年 %m月 %d日")
    s = month.beginning_of_month.strftime('%Y-%m-%d %H:%M:%S')
    e = month.end_of_month.strftime('%Y-%m-%d %H:%M:%S')
    budgetmonth = month.strftime('%Y%m')
    
    sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        "SELECT
        sum(count) as t_count, sum(maxrate) as t_max, sum(outgo) as t_outgo
        FROM
        records 
        WHERE
        user_id = :id AND (recorddate >= :s AND recorddate <= :e)",
        id: current_user.id.to_i,
        s: s,
        e: e,
      ]
    )
    result = ActiveRecord::Base.connection.select_all(sql)
    @mrecord = result.to_hash
    
    ext_chk =  Budget.find_by(month:budgetmonth,user_id:current_user.id)
    
    returnval = {
      'budget'    => 0,
      'outgo'     => 0,
      'balance'   => 0,
      'rarecount' => 0,
      'count'     => 0,
    }
    if ext_chk.present?
      returnval['budget'] = ext_chk.budget
    end
    if @mrecord[0]['t_outgo'].present?
      returnval['outgo'] = @mrecord[0]['t_outgo']
    end
    if @mrecord[0]['t_count'].present?
      returnval['count'] =  @mrecord[0]['t_count']
    end
    if @mrecord[0]['t_max'].present?
      returnval['rarecount'] = @mrecord[0]['t_max']
    end
    
    returnval['balance'] = returnval['budget'] - returnval['outgo']
    
    sql2 = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        "with t0 as (
        SELECT
        sgame_id,
        gname,
        ROUND( count::NUMERIC / SUM(count) OVER (), 5) as ratio
        FROM
        records left join sgames on records.sgame_id = sgames.id
        WHERE
        records.user_id = :id AND (recorddate >= :s AND recorddate <= :e)
      )
      SELECT sum(ratio) as t_ratio, gname FROM t0 GROUP BY gname",
      id: current_user.id.to_i,
      s: s,
      e: e,
    ]
  )
  #  result2 = ActiveRecord::Base.connection.select_all(sql2)
  
  render :json => returnval
end

def update
  #@record = Record.find(params[:id])
  
  if @record.update(record_params)
    redirect_to list_records_path,notice:"編集しました"
  else
    @select = {}
    sgames =  current_user.sgames.all
    sgames.each do |g|
      next if g.status == 'false'
      @select[g.gname] = g.id
    end
    render 'edit'
  end
end
def destroy
  #@record = Record.find(params[:id])
  @record.destroy
  
  path = Rails.application.routes.recognize_path(request.referer)
  if path[:action] == 'list'
    redirect_to list_records_path,notice: '削除しました'
  elsif path[:action] == 'mypage'
    redirect_to  mypage_records_path,notice: '削除しました。'
  end
end

def list

    if params[:month]
      now = Time.parse("#{params[:month]}/01")
    else
      now = Time.now
    end
    s = now.beginning_of_month.strftime('%Y-%m-%d %H:%M:%S')
    e = now.end_of_month.strftime('%Y-%m-%d %H:%M:%S')
    @m = now.strftime('%Y-%m')
    sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        "SELECT records.id,outgo,count,result,gname,recorddate + '9 hours' AS recorddate FROM records LEFT JOIN sgames ON records.sgame_id = sgames.id WHERE records.user_id = :id AND (recorddate >= :s AND recorddate <= :e)",
        id: current_user.id.to_i,
        s: s,
        e: e,
      ]
    )
    result = ActiveRecord::Base.connection.select_all(sql)
    sql2 = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
          "SELECT
              sum(case when result = '勝利' OR result = '大勝利' OR result = '辛勝' then 1 else 0 end) as victory,
              count(*),sum(count)
          FROM
              records  WHERE records.user_id = :id AND (recorddate >= :s AND recorddate <= :e)",
        id: current_user.id.to_i,
        s: s,
        e: e,
      ]
    )
    result2 = ActiveRecord::Base.connection.select_all(sql2)

    @result =  result.to_hash
    @result2 =  result2.to_hash
    @result2[0]['rate'] = (@result2[0]['victory'].to_f / @result2[0]['count'].to_f).round(2) *100

end

def detail

  sql = ActiveRecord::Base.send(
    :sanitize_sql_array,
    [
      "SELECT outgo,purpose,count,routine,result,maxrate,gname,recorddate + '9 hours' AS recorddate FROM records LEFT JOIN sgames ON records.sgame_id = sgames.id WHERE records.id = :id",
      id: params[:id].to_i
    ]
  )
  result = ActiveRecord::Base.connection.select_one(sql)
  
  render :json => result.to_json

end

def event
  record= Record.where(recorddate: (params[:start])..(params[:end]),user_id:current_user.id)
  eventdata = []
  record.each do |r|
    next if r.recorddate == nil
    tmp = {
      title: "￥"+ r.outgo.to_s,
      id:r.id,
      start: r.recorddate.strftime("%Y-%m-%d")  ,
    end: r.recorddate.strftime("%Y-%m-%d") ,
    allday: true
  }
  eventdata.push(tmp)
  end

  render :json => eventdata

end

private 

   def record_params
    params.require(:record).permit(:sgame_id,:outgo,:count,:purpose,:routine,:result,:maxrate,:recorddate)
   end

   def find_record
    @record = Record.find_by(id:params[:id],user_id:current_user.id)
   end

end
