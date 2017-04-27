class UserSystem::RenRenCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  # CITY = ["深圳", "广州", "南京", "成都", "东莞", "重庆", "苏州", "上海", "郑州", "威海", "石家庄", "武汉", "沈阳", "西安", "青岛", "长沙", "哈尔滨", "长春", "杭州", "潍坊", "厦门", "佛山", "大连", "合肥", "天津", "绵阳", "徐州", "无锡", "湘潭", "株洲", "宜昌", "肇庆", "洛阳 ", "济南 ", "贵阳 ", "南宁 ", "福州", "咸阳", "南阳", "惠州", "太原", "常德", "泉州", "襄阳", "宝鸡", "中山", "德阳", "常州", "南通", "扬州", "新乡", "烟台", "嘉兴", "大庆", "营口", "呼和浩特", "芜湖", "唐山", "遵义", "乌鲁木齐", "南昌", "岳阳"]
  # CITY = ["北京","厦门","太原","烟台","潍坊","青岛","济南","廊坊","保定","大连","大庆","长春","哈尔滨","沈阳","天津","唐山","石家庄","郑州","洛阳","南阳","新乡","上海","苏州","南通","昆明","重庆","西安","咸阳","乌鲁木齐","银川","兰州","成都","贵阳","遵义","绵阳","德阳","南充","乐山","东莞","南宁","惠州","深圳","广州","佛山","肇庆","中山","南京","扬州","合肥","徐州","杭州","无锡","常州","武汉","株洲","湘潭","长沙","宜昌","福州","襄阳","常德","南昌","呼和浩特","嘉兴","宁波","西宁","珠海"]
  #  有人喊，就把这几个城市去了  ["遵义", "南充", "乐山", "宜昌", "襄阳", "常德", "南昌"]
  # CITY = []
  CITY = ["北京" ,"东莞","佛山" ,"深圳", "南宁" ,"杭州" ,"南京" ,"长沙" ,"合肥" ,"厦门", "太原",
  "青岛", "济南", "大连", "长春", "哈尔滨", "沈阳", "天津", "石家庄", "徐州", "无锡", "武汉", "广州", "惠州", "上海", "郑州", "洛阳", "昆明", "重庆",
  "西安", "兰州", "成都", "贵阳", "苏州", "南通", "乌鲁木齐"]


  # car_user_info = UserSystem::CarUserInfo.find 2127639
  # UserSystem::RenRenCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info
    return if car_user_info.name.blank?
    return if car_user_info.phone.blank?
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
                                                      renren_upload_status: '未上传',
                                                      site_name: car_user_info.site_name,
                                                      created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新 人人车异常'
        pp e
        pp $@
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

    UserSystem::RenRenCarUserInfo.upload_renren cui
  end


  # yc_car_user_info = UserSystem::RenRenCarUserInfo.find 1823159
  # UserSystem::RenRenCarUserInfo.upload_youyiche yc_car_user_info
  def self.upload_renren yc_car_user_info

    if yc_car_user_info.name.blank?
      yc_car_user_info.renren_upload_status = '姓名为空'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.brand.blank?
      yc_car_user_info.renren_upload_status = '品牌未知'
      yc_car_user_info.save!
      return
    end

     # if yc_car_user_info.car_user_info.che_ling.to_i < 2008
     #   yc_car_user_info.renren_upload_status = '车太老'
     #   yc_car_user_info.save!
     #   return
     # end

    # if yc_car_user_info.car_user_info.milage.to_i > 12
    #   yc_car_user_info.renren_upload_status = '里程太多'
    #   yc_car_user_info.save!
    #   return
    # end



    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.renren_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.renren_upload_status = '手机号格式不对'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      # yc_car_user_info.renren_upload_status = '城市不对'
      # yc_car_user_info.save!

      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.renren_upload_status = '车商'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.renren_upload_status = '爬虫'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.renren_upload_status = '城市不匹配'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.renren_upload_status = '疑似走私车'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.renren_upload_status = '疑似走私车'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
        yc_car_user_info.renren_upload_status = '疑似走私车或车商'
        yc_car_user_info.save!
        UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
        return

      end

    end

    if yc_car_user_info.name.match /^小/ and yc_car_user_info.name.length == 2
      yc_car_user_info.renren_upload_status = '疑似走私车或车商'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end


    if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
      yc_car_user_info.renren_upload_status = '疑似走私车'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    #还有用手机号，QQ号做名字的。
    if /[0-9]+/.match yc_car_user_info.name
      yc_car_user_info.renren_upload_status = '疑似走私车'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.renren_upload_status = '疑似走私车'
      yc_car_user_info.save!
      UserSystem::RenRenCarUserInfo.upload_renren_xxx yc_car_user_info
      return
    end

    # 2017-04-23 去除条件
    # if ['金杯', '五菱汽车', "五菱", '五十铃', '昌河',  '宾利',  '保时捷', '东风小康', '依维柯', '长安商用', '福田', '东风风神', '东风'].include? yc_car_user_info.brand
    #   yc_car_user_info.renren_upload_status = '品牌外车，暂排除'
    #   yc_car_user_info.save!
    #   return
    # end

    # 2017-04-23 去除条件
    # ['QQ', '求购', '牌照', '批发', '私家一手车', '一手私家车', '身份', '身 份', '身~份', '个体经商', '过不了户', '帮朋友', '外地',
    #  '贷款', '女士一手', '包过户', '原漆', '原版漆', '当天开走', '美女', '车辆说明', '车辆概述', '选购', '一个螺丝',
    #  '精品', '驾驶证', '驾-驶-证', '车况原版', '随时过户', '来电有惊喜', '值得拥有', '包提档过户',
    #  '车源', '神州', '分期', '分 期', '必须过户', '抵押', '原车主', '店内服务', '选购', '微信', 'wx', '微 信',
    #  '威信', '加微', '评估师点评', '车主自述', "溦 信", '电话量大', '包你满意', '刷卡', '办理', '纯正', '抢购', '心动', '本车', '送豪礼'].each do |kw|
    #   if yc_car_user_info.car_user_info.note.include? kw
    #     yc_car_user_info.renren_upload_status = '疑似车商'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end

    # 用手机号归属地的时候，最好先去表中查询一下，看看有没有外地号
    # yc_car_user_info = yc_car_user_info.car_user_info
    # yc_car_user_info.phone_city = UserSystem::YoucheCarUserInfo.get_city_name(yc_car_user_info.phone)
    # yc_car_user_info.save!
    # if not cui.phone_city.blank?
    #   unless yc_car_user_info.city_chinese == yc_car_user_info.phone_city
    #     yc_car_user_info.renren_upload_status = '非本地车'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end

    # 2017-04-23 去除条件
    # cui = yc_car_user_info.car_user_info
    # cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    # cui.save!
    # if not cui.phone_city.blank?
    #   unless cui.city_chinese == cui.phone_city
    #     yc_car_user_info.renren_upload_status = '非本地车'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end


    # if yc_car_user_info.car_user_info.note.match /^出售/
    #   yc_car_user_info.renren_upload_status = '疑似车商'
    #   yc_car_user_info.save!
    #   return
    # end

    # if yc_car_user_info.car_user_info.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车|联系|处理|过户|包你/
    #   yc_car_user_info.renren_upload_status = '疑似车商'
    #   yc_car_user_info.save!
    #   return
    # end


    # 2017-04-23 去除条件
    # config_key_words = 0
    # ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
    #  "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
    #  "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
    #  "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
    #   config_key_words+=1 if yc_car_user_info.car_user_info.note.include? kw
    # end
    #
    #
    # # 过多配置描述，一般车商
    # if config_key_words > 6
    #   yc_car_user_info.renren_upload_status = '疑似车商，'
    #   yc_car_user_info.save!
    #   return
    # end
    config_key_words = 0




    token = 'J8UkigIBffy0xZen'
    # domain = '123.56.187.192:2872'
    domain = '60.205.108.209'
    require 'digest/md5'
    time = Time.now.to_i
    data = {
        "name" => yc_car_user_info.name,
        "mobile" => yc_car_user_info.phone,
        "city" => yc_car_user_info.city_chinese,
        "brand" => yc_car_user_info.brand,
        "series" => yc_car_user_info.car_user_info.cx,
        "model" => "未知",
        "kilometer" => yc_car_user_info.car_user_info.milage,
        "licensed_date_year" => yc_car_user_info.che_ling,
        "is_operation" => 0,
        "seat_number" => "5座",
        "is_accidented" =>  0
    }

    data_json = data.to_json
    params = {
        "token" => token,
        "time" => time,
        "sign" => Digest::MD5.hexdigest("#{data_json}#{token}#{time}"),
        "data" => data_json
    }



    response = RestClient.post "#{domain}/v1/clue/saler", params#, :content_type => 'application/json'


    response = JSON.parse response.body


    yc_car_user_info.renren_upload_status = '已上传'
    if response["status"] == 200
      yc_car_user_info.renren_id = response["data"]["renrenche_infoid"]
      yc_car_user_info.renren_status_message = response["msg"]
      yc_car_user_info.renren_yaoyue = '重复' if response["data"]["is_repeat"]
    else
      yc_car_user_info.renren_status_message = response["msg"]
    end
    yc_car_user_info.save!

  end

  #给到瓜子介绍的人人渠道
  def self.upload_renren_xxx yc_car_user_info
    token = 'd77d7c44bdeb8425'

    domain = '60.205.108.209'
    require 'digest/md5'
    time = Time.now.to_i
    data = {
        "name" => yc_car_user_info.name,
        "mobile" => yc_car_user_info.phone,
        "city" => yc_car_user_info.city_chinese,
        "brand" => yc_car_user_info.brand,
        "series" => yc_car_user_info.car_user_info.cx,
        "model" => "待定",
        "kilometer" => yc_car_user_info.car_user_info.milage,
        "licensed_date_year" => yc_car_user_info.che_ling,
        "is_operation" => 0,
        "seat_number" => "5",
        "is_accidented" =>  0
    }

    data_json = data.to_json
    params = {
        "token" => token,
        "time" => time,
        "sign" => Digest::MD5.hexdigest("#{data_json}#{token}#{time}"),
        "data" => data_json
    }



    response = RestClient.post "#{domain}/v1/clue/saler", params#, :content_type => 'application/json'


    response = JSON.parse response.body


    yc_car_user_info.renren_upload_status = '已上传'
    yc_car_user_info.renren_chengjiao = token
    if response["status"] == 200
      yc_car_user_info.renren_id = response["data"]["renrenche_infoid"]
      yc_car_user_info.renren_status_message = response["msg"]
      yc_car_user_info.renren_yaoyue = '重复' if response["data"]["is_repeat"]
    else
      yc_car_user_info.renren_status_message = response["msg"]
    end
    yc_car_user_info.save!
  end

  def self.tongji_renren_che
    require 'digest/md5'
    token = 'J8UkigIBffy0xZen'
    domain = '60.205.108.209'
    time = Time.now.chinese_format

    data = {"day" => "2016-09-30"}
    data_json = data.to_json
    params = {
        "token" => token,
        "time" => time,
        "sign" => Digest::MD5.hexdigest("#{token}#{time}"),
        "data" => data_json
    }

    response = RestClient.post "#{domain}/v1/clue/saler", params
    response = JSON.parse response.body
  end


end
__END__
