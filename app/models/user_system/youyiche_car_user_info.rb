class UserSystem::YouyicheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ['上海']

  # UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and UserSystem::YouyicheCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        #数据回传到优车
        UserSystem::YouyicheCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
                                                        phone: car_user_info.phone,
                                                        brand: car_user_info.brand,
                                                        city_chinese: car_user_info.city_chinese,
                                                        che_ling: car_user_info.che_ling,
                                                        car_user_info_id: car_user_info.id,
                                                        milage: car_user_info.milage,
                                                        price: car_user_info.price,
                                                        is_real_cheshang: car_user_info.is_real_cheshang,
                                                        is_city_match: car_user_info.is_city_match,
                                                        is_pachong: car_user_info.is_pachong,
                                                        is_repeat_one_month: car_user_info.is_repeat_one_month,
                                                        youyiche_upload_status: '未上传',
                                                        site_name: car_user_info.site_name,
                                                        created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新又一车异常'
        pp e
      end
    end
  end

  # 创建优车车主信息
  def self.create_car_info options

    sleep_time = rand(3)
    sleep sleep_time

    cui = UserSystem::YouyicheCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::YouyicheCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::YouyicheCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::YouyicheCarUserInfo.upload_youyiche cui
  end

  def self.upload_youyiche yc_car_user_info

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.youyiche_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    return unless yc_car_user_info.phone.match /\d{11}/

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.youyiche_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.youyiche_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.youyiche_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.youyiche_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end
    if yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
        yc_car_user_info.youyiche_upload_status = '疑似走私车或车商'
        yc_car_user_info.save!
        return
      end
    end

    if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #还有用手机号，QQ号做名字的。
    if /[0-9]+/.match yc_car_user_info.name
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    params = {
        "name" => yc_car_user_info.name,
        "phone" => yc_car_user_info.phone,
        "isSell" => 1,
        "city" => yc_car_user_info.city_chinese,
        "type" => "线上合作-数据合作",
        "origin" => "xuzuo",
        "brand" => yc_car_user_info.brand
    }

    # host_name = 'uat.youyiche.com' #测试环境
    host_name = "b.youyiche.com" #正式环境

    response = RestClient.post "http://#{host_name}/webapi/public/register_carneed", params.to_json, :content_type => 'application/json'

    response = JSON.parse response.body

    yc_car_user_info.youyiche_upload_status = '已上传'
    if response["success"]
      yc_car_user_info.youyiche_id = response["id"]
    else
      yc_car_user_info.youyiche_status_message = response["message"]
    end
    yc_car_user_info.save!

  end


  # UserSystem::YouyicheCarUserInfo.query_youyiche
  def self.query_youyiche
    # host_name = 'uat.youyiche.com' #测试环境
    host_name = "b.youyiche.com" #正式环境
    UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and (youyiche_yaoyue is null or youyiche_yaoyue in ('未拨通','失败'))").each do |cui|
      response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", {"0" => cui.youyiche_id}.to_json, :content_type => 'application/json'
      response = JSON.parse response.body
      status = response[0]["status"].strip
      next if ['待跟进', '跟进中'].include? status
      next if status.blank?
      if status == '竞拍中'
        cui.youyiche_jiance = status
      end

      cui.youyiche_yaoyue = status
      cui.yaoyue_time = Time.now.chinese_format
      cui.yaoyue_day = Time.now.chinese_format_day
      cui.save!
    end


    UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and youyiche_jiance is null").each do |cui|
      response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", {"0" => cui.youyiche_id}.to_json, :content_type => 'application/json'
      response = JSON.parse response.body
      status = response[0]["status"].strip
      if status == '竞拍中'
        cui.youyiche_jiance = status
        cui.save!
      end
    end
    #
    #
    # #多次更新所有数据   最终结果
    # host_name = "b.youyiche.com" #正式环境
    # UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null").each do |cui|
    #   response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", {"0" => cui.youyiche_id}.to_json, :content_type => 'application/json'
    #   response = JSON.parse response.body
    #   status = response[0]["status"].strip
    #   cui.youyiche_chengjiao = status
    #   cui.save!
    # end
    #
    #
    #
    # 查看报价
    # host_name = "b.youyiche.com" #正式环境
    # UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and id in (84,589,472,486,1186,866)").each do |cui|
    #   response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", {"0" => cui.youyiche_id}.to_json, :content_type => 'application/json'
    #   response = JSON.parse response.body
    #   pp response
    # end

  end

  # UserSystem::YouyicheCarUserInfo.yxl
  def self.yxl
    #一次更新所有数据   最终结果
    host_name = "b.youyiche.com" #正式环境
    p = {}
    cuis = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null").each_with_index do |cui, i|
      p["#{i}"] = cui.youyiche_id
    end
    response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", p.to_json, :content_type => 'application/json'
    response = JSON.parse response.body
    response.each do |xx|
      cui = cuis.select { |cui| cui.youyiche_id == "#{xx["need_id"]}" }
      cui = cui[0]
      cui.youyiche_chengjiao = xx["status"]
      cui.save!
    end



    youxiao = 0
    wuxiao = 0
    weizhi = 0
    jingpai = 0
    chengjiao = 0
    UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and id > 0 and id < 741").each do |cui|
      jingpai += 1 if cui.youyiche_jiance == '竞拍中'
      chengjiao += 1 if cui.youyiche_chengjiao == '成交'
      next wuxiao += 1 if ["失败", '未拨通'].include? cui.youyiche_yaoyue
      next youxiao += 1 if ["已预约检测", "待预约"].include? cui.youyiche_yaoyue
      next if cui.youyiche_yaoyue == '重复'
      weizhi += 1
    end
    pp "有效率为：#{youxiao.to_f/(youxiao+wuxiao)}"
    pp "竞拍率为：#{jingpai.to_f/(youxiao)}"
    pp "竞拍成交率为：#{chengjiao.to_f/(jingpai)}"

  end



end
__END__
