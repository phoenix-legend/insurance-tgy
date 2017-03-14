class UserSystem::PengyoucheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ['上海', '苏州', '杭州', '南京', '济南', '深圳']

  # UserSystem::PengyoucheCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::PengyoucheCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin

        UserSystem::PengyoucheCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
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
                                                          pengyou_upload_status: '未上传',
                                                          site_name: car_user_info.site_name,
                                                          created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新朋友E车异常'
        pp e
      end
    end
  end

  # 创建优车车主信息
  def self.create_car_info options

    cui = UserSystem::PengyoucheCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::PengyoucheCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::PengyoucheCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::PengyoucheCarUserInfo.upload_pengyouche cui
  end


  def self.upload_pengyouche yc_car_user_info

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.pengyou_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.name.blank?
      yc_car_user_info.pengyou_upload_status = '姓名不对'
      yc_car_user_info.save!
      return
    end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.pengyou_upload_status = '手机号不正确'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.pengyou_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.pengyou_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.pengyou_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.pengyou_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end

    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.pengyou_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end
    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.pengyou_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
        yc_car_user_info.pengyou_upload_status = '疑似走私车或车商'
        yc_car_user_info.save!
        return
      end
    end

    if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
      yc_car_user_info.pengyou_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #还有用手机号，QQ号做名字的。
    if /[0-9]+/.match yc_car_user_info.name
      yc_car_user_info.pengyou_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.pengyou_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end


    cui = yc_car_user_info.car_user_info
    cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    cui.save!
    if not cui.phone_city.blank?
      unless cui.city_chinese == cui.phone_city
        yc_car_user_info.pengyou_upload_status = '非本地车'
        yc_car_user_info.save!
        return
      end
    end


    if cui.note.match /^出售/
      yc_car_user_info.pengyou_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end

    if cui.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车/
      yc_car_user_info.pengyou_upload_status = '疑似车商'
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
      yc_car_user_info.pengyou_upload_status = '疑似车商，'
      yc_car_user_info.save!
      return
    end



    host_name = "http://api.fecar.com/msg/sell" #正式环境

    # response = RestClient.post "http://api.fecar.com/msg/sell", params.to_json, :content_type => 'application/json'

    response = RestClient.post host_name, {
        token: '24c81a87a1e97ea3f3b83aff71e2b184',
        phone: yc_car_user_info.phone,
        car_area: yc_car_user_info.city_chinese
    }

    response = JSON.parse response.body

    yc_car_user_info.pengyou_upload_status = '已上传'
    if response["status_code"] == 1
      yc_car_user_info.pengyou_id = response["data"]["id"]
    else
      yc_car_user_info.pengyou_status_message = response['status_msg']
    end
    yc_car_user_info.save!

  end


  # UserSystem::PengyoucheCarUserInfo.query_result
  def self.query_result
    shangjianumber = 0
    youxiaonumber = 0
    UserSystem::PengyoucheCarUserInfo.where("pengyou_id is not null ").each do |cui|
      host_name =  "http://api.fecar.com/msg/query"
      response = RestClient.post host_name, {
          token: '24c81a87a1e97ea3f3b83aff71e2b184',
          id: cui.pengyou_id.to_i
      }
      response = JSON.parse response.body
      next if response["data"]["car_status_msg"] == '暂无卖车信息'
      youxiaonumber += 1
      shangjianumber += 1 if  response["data"]["car_status_msg"] == '上架成功'
      pp response
    end
    pp shangjianumber
    pp youxiaonumber
  end

end
__END__
