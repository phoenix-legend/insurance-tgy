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
    if params[:content_filter].blank?
      render ''
    else
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
        when 'baixing_citys'
          Baixing.get_car_user_list_v2 content, areaid
        when 'ganji_citys'
          Ganji.get_car_user_list_v2 content, areaid
        else
          ''
      end
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
    # @is_need = UserSystem::DeviceAccessLog.need_restart params[:machine_name]

    redis = Redis.current
    if redis["#{params[:machine_name]}_need_chongqi"].blank?
      redis["#{params[:machine_name]}_need_chongqi"] = "#{Time.now.to_i}"
      @is_need = false
    else
      if Time.now.to_i - redis["#{params[:machine_name]}_need_chongqi"].to_i > 60*10
        @is_need = true
      else
        @is_need = false
      end
    end
  end

  # def upload_youyiche
  #   cui = UserSystem::YouyicheCarUserInfo.find_by_id params[:id]
  #   UserSystem::YouyicheCarUserInfo.upload_youyiche cui,2
  # end

  # 百姓单独使用VPS在外网运行解析, 解析后的数据通过api方式提交进来。
  # 此接口用于获取新的链接
  def vps_urls
    string_urls = params[:urls]
    urls = string_urls.split('!!!')
    pp urls.length
    @return_urls = Baixing.get_detail_urls_for_vps urls
  end

  # 百姓单独使用VPS在外网运行解析, 解析后的数据通过api方式提交进来。
  # 此接口用于获取更新数据详情
  def vps_create_and_upload
    Baixing.create_car_user_infos_from_vps params[:cui]
  end

  #  给客服提取口令, 接收信息包含: openid, nickname
  # 制作view
  def get_kouling_for_kefu
    @cui = UserSystem::KouLingCarUserInfo.get_kouling_for_kefu params[:openid], params[:nickname], params[:city]
  end

  def shouche
    UserSystem::CarUserInfo.shouche_guazi params
  end

  #小渠道收车业绩
  def shoucheyj
    @date = params[:date]
    @result = UserSystem::GuaziCarUserInfo.shouche_yeji params[:date], params[:time], params[:sign]
  end

  def shouchexiaopeng
    @userid = UserSystem::CarUserInfo.shouche_xiaopeng params
  end

  # url为:  http://che.uguoyuan.cn/api/v1/update_user_infos/proxy_info
  def proxy_info
    redis = Redis.current
    redis["#{params[:machine_name]}_need_chongqi"] = "#{Time.now.to_i}"
    OrderSystem::WeizhangLog.add_baixing_json_body params[:proxy_info], 'baixing'
  end

  def check_guazi_shangjia
    cuis = UserSystem::GuaziCarUserInfo.where("phone = ? and guazi_yaoyue = '成功'", params[:phone]).order(id: :desc).limit(1)

    # cuis = UserSystem::GuaziCarUserInfo.where("phone = ? and guazi_yaoyue = '成功'", '13993156253').order(id: :desc).limit(1)
    @result = if cuis.blank?
       'none'
     else
       cuis[0].car_user_info.created_at.chinese_format
     end

  end

end