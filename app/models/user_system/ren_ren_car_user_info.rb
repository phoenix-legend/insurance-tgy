class UserSystem::RenRenCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ['上海', '杭州', '苏州', '成都']


  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::RenRenCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        #数据回传到优车
        UserSystem::RenRenCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
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
                                                      renren_upload_status: '未上传',
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

    # sleep_time = rand(3)
    # sleep sleep_time

    cui = UserSystem::RenRenCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::RenRenCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::RenRenCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::RenRenCarUserInfo.upload_youyiche cui
  end


  # yc_car_user_info = UserSystem::RenRenCarUserInfo.find id
  # UserSystem::RenRenCarUserInfo.upload_youyiche yc_car_user_info
  def self.upload_renren yc_car_user_info

    if yc_car_user_info.name.blank?
      yc_car_user_info.youyiche_upload_status = '姓名不对'
      yc_car_user_info.save!
      return
    end

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

    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.youyiche_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
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

    # cui = yc_car_user_info.car_user_info
    # cui.phone_city = UserSystem::YoucheCarUserInfo.get_city_name(yc_car_user_info.phone)
    # cui.save!
    # unless cui.city_chinese == cui.phone_city
    #   yc_car_user_info.youyiche_upload_status = '非本地车'
    #   yc_car_user_info.save!
    #   return
    # end

    # 针对苏，杭，成都 进行严格限制量。


    if cui.note.match /^出售/
      yc_car_user_info.youyiche_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end

    if cui.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车/
      yc_car_user_info.youyiche_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end


    config_key_words = 0
    ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
     "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
     "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
     "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
      config_key_words+=1 if cui.note.include? kw
    end


    # 过多配置描述，一般车商
    if config_key_words > 6
      yc_car_user_info.youyiche_upload_status = '疑似车商，'
      yc_car_user_info.save!
      return
    end


    token = 'XX'
    domain = 'XXx'
    require 'digest/md5'
    time = Time.now.chinese_format
    data = {
        "name" => yc_car_user_info.name,
        "mobile" => yc_car_user_info.phone,
        "city" => yc_car_user_info.city_chinese,
        "brand" => yc_car_user_info.brand,
        "series" => yc_car_user_info.car_user_info.cx,
        "model" => "未知",
        "kilometer" => yc_car_user_info.car_user_info.milage,
        "licenced_date_year" => yc_car_user_info.che_ling,
        "is_operation" => 0,
        "seat_number" => 5,
        "is_accidented" =>  0
    }
    data_json = data.to_json
    params = {
        "token" => "",
        "time" => time,
        "sign" => Digest::MD5.hexdigest("#{data_json}#{token}#{time}")
    }



    response = RestClient.post "XXX", params.to_json, :content_type => 'application/json'

    response = JSON.parse response.body

    yc_car_user_info.youyiche_upload_status = '已上传'
    if response["status"] == "200"
      yc_car_user_info.renren_id = response["id"]
    else
      yc_car_user_info.renren_status_message = response["msg"]
    end
    yc_car_user_info.save!

  end


end
__END__
