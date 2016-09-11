class Api::V1::UpdateUserInfosController < Api::V1::BaseController

  # 处理携车
  def update_user_by_xiecheyangche
    ::UserSystem::UserInfo.update_user_by_xieche params[:id]
  end

  #意外险
  def yiwaixian
    json = UserSystem::UserInfo.yiwaixianjiekou params
    render :json => json, :layout => false
  end

  #获取城市代号
  def get_all_city_codes
    cities = UserSystem::RenRenCarUserInfo::CITY
    @hash = {}
    @hash[:che168] = []
    @hash[:wuba] = []
    @hash[:ganji] = []
    @hash[:baixing] = []
    @hash[:taoche] = []
    @hash[:wuba] = []
    cities.each do |city_name|
      @hash[:che168] << UserSystem::CarUserInfo::ALL_CITY.invert[city_name] unless UserSystem::CarUserInfo::ALL_CITY.invert[city_name].blank?
      @hash[:taoche] << UserSystem::CarUserInfo::PINYIN_CITY.invert[city_name] unless UserSystem::CarUserInfo::PINYIN_CITY.invert[city_name].blank?
      @hash[:baixing] << UserSystem::CarUserInfo::BAIXING_PINYIN_CITY.invert[city_name] unless UserSystem::CarUserInfo::BAIXING_PINYIN_CITY.invert[city_name].blank?
      @hash[:ganji] << UserSystem::CarUserInfo::GANJI_CITY.invert[city_name] unless UserSystem::CarUserInfo::GANJI_CITY.invert[city_name].blank?
      @hash[:wuba] << UserSystem::CarUserInfo::WUBA_CITY.invert[city_name] unless UserSystem::CarUserInfo::WUBA_CITY.invert[city_name].blank?
    end
  end

  def get_web_content
    areaid = params[:areaid]
    website_name = params[:website_name]
    content = CGI::unescape(params[:content_filter])
    case website_name
      when "wuba_citys"
        Wuba.get_car_user_list_v2 content, areaid
      when 'che168_citys'
        Che168.get_car_user_list_v2 content, areaid
      when 'taoche_citys'
        TaoChe.get_car_user_list_v2 content, areaid #未测试
      else
        ''
    end
  end


  # 更新用户信息， 主要是用于58提交过来。
  def update_car_user_info
    car_user_info = UserSystem::CarUserInfo.find params[:id]
    user_infos = UserSystem::CarUserInfo.where name: params[:name],
                                               phone: params[:phone]
    unless user_infos.length > 0
      car_user_info.name = params[:name]
      car_user_info.phone = params[:phone]
      car_user_info.note = params[:note]
      car_user_info.fabushijian = params[:fabushijian]
      car_user_info.price = params[:price]
    end
    car_user_info.need_update = false
    car_user_info.save!
  end


  #获取天天渠道需要提交的数据
  # def get_need_update_tt_info
  #   @user_infos = UploadTianTian.need_upload_tt
  # end

  # deceased , 以前用于更新更新天天这边的状态。
  def update_tt_info
    UploadTianTian.update_car_user_info params
  end

  #获取口令
  def get_cui_kouling
    @cui = UserSystem::KouLingCarUserInfo.get_wei_tijiao_kouling params[:deviceid]
  end


  def update_kouling_phone
    UserSystem::CarUserInfo.update_58_phone_detail params
  end

  #是否需要重启指定客户端
  def need_chongqi
    @is_need = UserSystem::DeviceAccessLog.need_restart params[:machine_name]
  end

end