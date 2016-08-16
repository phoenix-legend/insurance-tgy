class Wz::Weizhang::ChaxunController < Wz::WangzhanController

  def car_user_info

  end

  def test_car_user_info

  end

  def citycar_user_info

  end

  def ztx_car_user_infos
    begin
      if request.post?
        BusinessException.raise '请提交文件' if params[:excel].blank?
        UserSystem::ZtxCarUserInfo.save_and_post_car_user_infos params[:excel], Time.now.to_date
        flash[:success] = '上传完毕'
        redirect_to action: :ztx_car_user_infos
      else
        @group_car_user_infos = UserSystem::GroupCarUserInfo.all.order(created_at: :desc)
      end
    rescue Exception => e
      dispose_exception e
      flash[:alert] = get_notice
      redirect_to action: :ztx_car_user_infos
    end
  end


  def group_ztx_car_user_infos
    @group_car_user_infos = UserSystem::GroupCarUserInfo.all.order(created_at: :desc)
  end

  def ztx_car_user_infos_download
    begin
    if params[:password] == "146098"
      file_name = UserSystem::GroupCarUserInfo.find(params[:id]).download
      send_file file_name
    else
      BusinessException.raise '密码不对'
    end

    rescue Exception => e
      dispose_exception e
      flash[:alert] = get_notice
      redirect_to action: :ztx_car_user_infos
    end
  end

  def index
    product_id = ::OrderSystem::Product.find_by_server_name("weizhang").id
    @product = ::OrderSystem::Product.find product_id
    city = ::OrderSystem::IpRegion.get_city_name get_ip
    city.gsub!('市', '')
    @car_number = ::OrderSystem::Region.find_by_name(city).car_number_prefix rescue ''
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
