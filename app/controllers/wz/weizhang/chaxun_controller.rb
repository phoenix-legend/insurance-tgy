class Wz::Weizhang::ChaxunController < Wz::WangzhanController
  def index

  end

  def no_weizhang

  end

  def result

    begin
      session[:phone] = params[:query][:phone]
      session[:car_number] = params[:query][:car_number]
      @result = ::OrderSystem::WeizhangResult.weizhang_query params[:query]
      session[:engine_no] = params[:query][:engine_no]
      session[:vin_no] = params[:query][:vin_no]
    rescue Exception => e
      dispose_exception e
      str = get_notice_str true
      if str.split('|')[1].to_s == 'right'
        redirect_to '/wz/weizhang/chaxun/no_weizhang'
        return
      end
      set_notice str
      id = set_session_content
      redirect_to action: 'index', session_content_id: id


    end
  end
end
