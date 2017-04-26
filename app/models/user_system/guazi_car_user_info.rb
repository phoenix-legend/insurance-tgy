class UserSystem::GuaziCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'
  GZAPPKEY = '58886888'
  GZAPPSECRET = 'pi8E45Vft2sJ'
  GZSCODE = '204003368020000'
  RANDSTR = 'kkkkksdflksdfjlskdfjsdlkfjsdlkfj'

  CITY = ['苏州', "杭州", "上海", "合肥",
          "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京", "成都",
          '天津', '武汉', '重庆',
          "郑州", "长沙", "西安", "青岛", "威海", "烟台",
          "潍坊", "无锡", "常州", "徐州", "南通", "扬州", "济南",
          "石家庄", "唐山", "太原", "宝鸡", "洛阳", "南阳", "新乡", "湘潭", "株洲", "常德",
          "岳阳", "沈阳", "大连", "营口", "泉州", "长春", "哈尔滨", "大庆", "芜湖", "南宁", "南昌",

          "运城", "晋中", "临汾", "大同", "遵义", "兰州", "呼和浩特",
          "贵阳", "惠州", "嘉兴", "中山", "肇庆", "绵阳", "襄阳", "宜昌",
          "滨州", "德州", "东营", "济宁", "临沂", "日照", "泰安", "枣庄", "宁波", "宿迁", "泰州", "盐城", "镇江",

          "自贡", "淄博", "资阳", "驻马店", "珠海", "长治", "漳州", "张家口", "玉林", "益阳", "义乌", "宜春",
          "宜宾", "盐城", "延边", "雅安", "许昌", "邢台", "信阳", "孝感", "咸宁", "温州", "通辽", "铁岭",
          "台州", "遂宁", "随州", "松原", "四平", "十堰", "绍兴", "上饶", "商丘", "汕头", "三明", "曲靖",
          "衢州", "秦皇岛", "钦州", "齐齐哈尔", "莆田", "平顶山", "攀枝花", "宁德", "内江", "南充", "牡丹江",
          "眉山", "马鞍山", "漯河", "泸州", "龙岩", "六盘水", "六安", "柳州", "辽阳", "连云港", "乐山", "廊坊",
          "昆明", "开封", "九江", "景德镇", "荆州", "荆门", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林",
          "吉安", "黄石", "淮安", "湖州", "呼和浩特", "衡水", "邯郸", "桂林", "广元", "广安", "赣州", "阜阳",
          "抚州", "抚顺", "福州", "恩施", "鄂尔多斯", "德阳", "大理", "达州", "楚雄", "赤峰", "承德", "沧州", "北海",
          "保定", "包头", "百色", "巴中", "鞍山", "安阳", "安庆", "红河", "蚌埠", "丽水",
          "咸阳", "乌鲁木齐", "银川", "西宁", "菏泽", "铜陵", "黄冈", "鄂州", "阳泉"
  ]


  # UserSystem::GuaziCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info


    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::GuaziCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin

        UserSystem::GuaziCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
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
                                                     guazi_upload_status: '未上传',
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

    cui = UserSystem::GuaziCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::GuaziCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::GuaziCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::GuaziCarUserInfo.upload_guazi cui
  end


  def self.upload_guazi yc_car_user_info

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.guazi_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    # if yc_car_user_info.name.blank?
    #   yc_car_user_info.guazi_upload_status = '姓名不对'
    #   yc_car_user_info.save!
    #   return
    # end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '手机号不正确'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.guazi_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.guazi_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.guazi_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.guazi_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end


    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end


    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
        yc_car_user_info.guazi_upload_status = '疑似走私车或车商'
        yc_car_user_info.save!
        return
      end
    end


    if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    # 还有用手机号，QQ号做名字的。
    if /[0-9]+/.match yc_car_user_info.name
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end

    # 车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end


    # 2017-04-26  进一步放宽条件
    cui = yc_car_user_info.car_user_info
    cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    cui.save!
    if not cui.phone_city.blank?
      unless cui.city_chinese == cui.phone_city
        yc_car_user_info.guazi_upload_status = '非本地车'
        yc_car_user_info.save!
        return
      end
    end


    if cui.note.match /^出售/
      yc_car_user_info.guazi_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end

    if cui.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车/
      yc_car_user_info.guazi_upload_status = '疑似车商'
      yc_car_user_info.save!
      return
    end


    # 2017-04-26  进一步放宽条件
    config_key_words = 0
    ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
     "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
     "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
     "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
      config_key_words+=1 if cui.note.include? kw
    end
    # 过多配置描述，一般车商
    if config_key_words > 6
      yc_car_user_info.guazi_upload_status = '疑似车商，'
      yc_car_user_info.save!
      return
    end

    host_name = "http://commapi.guazi.com/clue/carClue/AddCarSource" #正式环境

    param = {
        appkey: UserSystem::GuaziCarUserInfo::GZAPPKEY,
        app_secret: UserSystem::GuaziCarUserInfo::GZAPPSECRET,
        nonce: UserSystem::GuaziCarUserInfo::RANDSTR,
        expires: Time.now.to_i+6000,
        phoneNum: cui.phone,
        scode: UserSystem::GuaziCarUserInfo::GZSCODE,
        cityName: cui.city_chinese,
    }

    param[:signature] = UserSystem::GuaziCarUserInfo.sign_params param



    response = RestClient.post host_name, param
    pp response.body
    response = JSON.parse(response.body)
    yc_car_user_info.guazi_upload_status = response["code"]
     if response["code"].to_i == 0
       yc_car_user_info.guazi_status = 1
     end
    yc_car_user_info.save!
  end


  # UserSystem::GuaziCarUserInfo.query_guazi
  def self.query_guazi
    host_name = "http://commapi.guazi.com/clue/carClue/GuaZiGetCarClueStatus" #正式环境


    gcui = UserSystem::GuaziCarUserInfo.where("guazi_yaoyue is null and created_at > ? and guazi_upload_status = '0'", Time.now - 15.days)
    gcui.find_each do |cui|
      next if cui.guazi_upload_status.blank?
      param = {
          appkey: UserSystem::GuaziCarUserInfo::GZAPPKEY,
          app_secret: UserSystem::GuaziCarUserInfo::GZAPPSECRET,
          nonce: UserSystem::GuaziCarUserInfo::RANDSTR,
          expires: Time.now.to_i+6000,
          phone: cui.phone,
          source_type_code: UserSystem::GuaziCarUserInfo::GZSCODE
      }

      param[:signature] = UserSystem::GuaziCarUserInfo.sign_params param


      # 失败  2，6，14
      # 成功  9
      # 待定  其它状态码


      response = RestClient.post host_name, param
      response = JSON.parse(response.body)
      pp response
      if response["code"].to_i == 11209
        cui.guazi_id = response["code"]
        cui.guazi_upload_status = '重复'
        cui.save!
        next
      end

      if response["code"].to_i == 0
        if [2,6,14].include? response["data"]["statusCode"].to_i
          cui.guazi_id = response["code"]
          cui.guazi_jiance = response["data"]["statusCode"].to_i
          cui.guazi_yaoyue = '失败'
          cui.save!
          next
        end

        if [9].include? response["data"]["statusCode"].to_i
          cui.guazi_id = response["code"]
          cui.guazi_yaoyue = '成功'
          cui.guazi_jiance = response["data"]["statusCode"].to_i
          cui.yaoyue_time = Time.now
          cui.yaoyue_day = Date.today
          cui.save!
          next
        end
      end

    end

  end



  # UserSystem::GuaziCarUserInfo.sign_params param
  def self.sign_params params
    k = ""
    params = params.sort
    params.each_with_index  do |param,i|
      k << param[0].to_s
      k << "="
      k << CGI::escape(param[1].to_s)
      k << "&" if params.length > i+1
    end
    pp k

    require 'base64'
    require 'cgi'
    require 'openssl'
    require 'digest/md5'


    sign = (Digest::MD5.hexdigest(Base64.encode64("#{OpenSSL::HMAC.digest('sha256', UserSystem::GuaziCarUserInfo::GZAPPSECRET, k)}").gsub("\n",'')))[5,10]

    pp sign
    return sign
    # puts CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',k, GZAPPSECRET)}\n"))
  end

end
__END__


