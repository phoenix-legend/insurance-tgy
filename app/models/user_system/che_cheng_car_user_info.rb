class UserSystem::CheChengCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ["上海"]

  # car_user_info = UserSystem::CarUserInfo.find 2260527
  # UserSystem::CheChengCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info
    return if not UserSystem::CheChengCarUserInfo::CITY.include?(car_user_info.city_chinese)
    return if car_user_info.name.blank?
    return if car_user_info.phone.blank?
    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::CheChengCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        #数据回传到优车
        UserSystem::CheChengCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
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
                                                        checheng_upload_status: '未上传',
                                                        site_name: car_user_info.site_name,
                                                        created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新 车城异常'
        pp e
        pp $@
      end
    end
  end


  # 创建优车车主信息
  def self.create_car_info options

    # sleep_time = rand(3)
    # sleep sleep_time

    cui = UserSystem::CheChengCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::CheChengCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::CheChengCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::CheChengCarUserInfo.upload_checheng cui
  end


  # yc_car_user_info = UserSystem::CheChengCarUserInfo.find 1823159
  # UserSystem::CheChengCarUserInfo.upload_youyiche yc_car_user_info
  def self.upload_checheng yc_car_user_info

    if yc_car_user_info.name.blank?
      yc_car_user_info.checheng_upload_status = '姓名为空'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.brand.blank?
      yc_car_user_info.checheng_upload_status = '品牌未知'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.car_user_info.che_ling.to_i < 2002
      yc_car_user_info.checheng_upload_status = '车太老'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.car_user_info.milage.to_i > 15
      yc_car_user_info.checheng_upload_status = '里程太多'
      yc_car_user_info.save!
      return
    end


    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.checheng_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.checheng_upload_status = '手机号格式不对'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.checheng_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.checheng_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.checheng_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.checheng_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end

    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.checheng_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.checheng_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
        yc_car_user_info.checheng_upload_status = '疑似走私车或车商'
        yc_car_user_info.save!
        return
      end
    end

    if yc_car_user_info.name.match /^小/ and yc_car_user_info.name.length == 2
      yc_car_user_info.checheng_upload_status = '疑似走私车或车商'
      yc_car_user_info.save!
      return
    end


    if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
      yc_car_user_info.checheng_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #还有用手机号，QQ号做名字的。
    if /[0-9]+/.match yc_car_user_info.name
      yc_car_user_info.checheng_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.checheng_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    # if ['金杯', '五菱汽车', "五菱", '五十铃', '昌河',  '宾利',  '保时捷', '东风小康', '依维柯', '长安商用', '福田', '东风风神', '东风'].include? yc_car_user_info.brand
    #   yc_car_user_info.checheng_upload_status = '品牌外车，暂排除'
    #   yc_car_user_info.save!
    #   return
    # end

    # ['QQ', '求购', '牌照', '批发', '私家一手车', '一手私家车', '身份', '身 份', '身~份', '个体经商', '过不了户', '帮朋友', '外地',
    #  '贷款', '女士一手', '包过户', '原漆', '原版漆', '当天开走', '美女', '车辆说明', '车辆概述', '选购', '一个螺丝',
    #  '精品', '驾驶证', '驾-驶-证', '车况原版', '随时过户', '来电有惊喜', '值得拥有', '包提档过户',
    #  '车源', '神州', '分期', '分 期', '必须过户', '抵押', '原车主', '店内服务', '选购', '微信', 'wx', '微 信',
    #  '威信', '加微', '评估师点评', '车主自述', "溦 信", '电话量大', '包你满意', '刷卡', '办理', '纯正', '抢购', '心动', '本车', '送豪礼'].each do |kw|
    #   if yc_car_user_info.car_user_info.note.include? kw
    #     yc_car_user_info.checheng_upload_status = '疑似车商'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end

    # 用手机号归属地的时候，最好先去表中查询一下，看看有没有外地号
    # yc_car_user_info = yc_car_user_info.car_user_info
    # yc_car_user_info.phone_city = UserSystem::YoucheCarUserInfo.get_city_name(yc_car_user_info.phone)
    # yc_car_user_info.save!
    # unless yc_car_user_info.city_chinese == yc_car_user_info.phone_city
    #   yc_car_user_info.checheng_upload_status = '非本地车'
    #   yc_car_user_info.save!
    #   return
    # end


    if yc_car_user_info.car_user_info.note.match /^出售/
      yc_car_user_info.checheng_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.car_user_info.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车|联系|处理|过户|包你/
      yc_car_user_info.checheng_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end


    config_key_words = 0
    ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
     "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
     "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
     "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
      config_key_words+=1 if yc_car_user_info.car_user_info.note.include? kw
    end


    # 过多配置描述，一般车商
    if config_key_words > 6
      yc_car_user_info.checheng_upload_status = '疑似车商，'
      yc_car_user_info.save!
      return
    end
    config_key_words = 0


    token = '049cfd502c74cafac9cde1a4161f5352'

    data = [{"name" => yc_car_user_info.name,
             "mobile" => yc_car_user_info.phone,
             "cityName" => yc_car_user_info.city_chinese,
             "carType" => yc_car_user_info.brand}]

    data_json = data.to_json


    response = RestClient.post "https://api.che.com/che_service/customer/addCustomer",
                               token: token,
                               data: data_json


    response = JSON.parse response.body
    pp response

    yc_car_user_info.checheng_upload_status = '已上传'
    if response["code"].to_i == 2
      yc_car_user_info.checheng_id = response["customerList"][0]["id"]
      yc_car_user_info.checheng_status_message = response["remark"]
      # yc_car_user_info.checheng_yaoyue = '重复' if response["data"]["is_repeat"]
    else
      yc_car_user_info.checheng_status_message = response["remark"]
    end
    yc_car_user_info.save!

  end


  def self.query_checheng
    UserSystem::CheChengCarUserInfo.where("checheng_id is not null").find_each do |cui|
      response = RestClient.post 'https://api.che.com/che_service/che/queryCarStatus',
                                 token: '049cfd502c74cafac9cde1a4161f5352',
                                 customer_id: cui.checheng_id
      response = JSON.parse response.body
      pp response

    end
  end


end
__END__
