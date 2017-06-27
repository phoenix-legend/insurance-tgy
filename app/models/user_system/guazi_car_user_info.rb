class UserSystem::GuaziCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'
  GZAPPKEY = '58886888'
  GZAPPSECRET = 'pi8E45Vft2sJ'
  GZSCODE = '204003368020000'
  GZSCODE_SHOUCHE = '204003133020000'
  RANDSTR = 'kkkkksdflksdfjlskdfjsdlkfjsdlkfj'

  # CITY = ['苏州', "杭州", "上海", "合肥",
  #         "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京", "成都",
  #         '天津', '武汉', '重庆',
  #         "郑州", "长沙", "西安", "青岛", "威海", "烟台",
  #         "潍坊", "无锡", "常州", "徐州", "南通", "扬州", "济南",
  #         "石家庄", "唐山", "太原", "宝鸡", "洛阳", "南阳", "新乡", "湘潭", "株洲", "常德",
  #         "岳阳", "沈阳", "大连", "营口", "泉州", "长春", "哈尔滨", "大庆", "芜湖", "南宁", "南昌",
  #
  #         "运城", "晋中", "临汾", "大同", "遵义", "兰州", "呼和浩特",
  #         "贵阳", "惠州", "嘉兴", "中山", "肇庆", "绵阳", "襄阳", "宜昌",
  #         "滨州", "德州", "东营", "济宁", "临沂", "日照", "泰安", "枣庄", "宁波", "宿迁", "泰州", "盐城", "镇江",
  #
  #         "自贡", "淄博", "资阳", "驻马店", "珠海", "长治", "漳州", "张家口", "玉林", "益阳", "义乌", "宜春",
  #         "宜宾", "盐城", "延边", "雅安", "许昌", "邢台", "信阳", "孝感", "咸宁", "温州", "通辽", "铁岭",
  #         "台州", "遂宁", "随州", "松原", "四平", "十堰", "绍兴", "上饶", "商丘", "汕头", "三明", "曲靖",
  #         "衢州", "秦皇岛", "钦州", "齐齐哈尔", "莆田", "平顶山", "攀枝花", "宁德", "内江", "南充", "牡丹江",
  #         "眉山", "马鞍山", "漯河", "泸州", "龙岩", "六盘水", "六安", "柳州", "辽阳", "连云港", "乐山", "廊坊",
  #         "昆明", "开封", "九江", "景德镇", "荆州", "荆门", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林",
  #         "吉安", "黄石", "淮安", "湖州", "呼和浩特", "衡水", "邯郸", "桂林", "广元", "广安", "赣州", "阜阳",
  #         "抚州", "抚顺", "福州", "恩施", "鄂尔多斯", "德阳", "大理", "达州", "楚雄", "赤峰", "承德", "沧州", "北海",
  #         "保定", "包头", "百色", "巴中", "鞍山", "安阳", "安庆", "红河", "蚌埠", "丽水",
  #         "咸阳", "乌鲁木齐", "银川", "西宁", "菏泽", "铜陵", "黄冈", "鄂州", "阳泉"
  # ]

  # 2017-06-21 更新瓜子最新城市
  CITY = ["鞍山",  "安阳",  "安庆", "北京",  "保定",  "包头",  "滨州",  "蚌埠",  "宝坻", "滨海新区", "重庆",  "成都",  "长春",  "长沙",  "常州",  "沧州", "长治",  "承德",  "常德",  "常熟", "大连",  "达州",  "东莞",  "大庆",  "大同",  "德州", "德阳",  "东营",  "大港", "鄂尔多斯", "抚顺",  "福州",  "佛山",  "阜阳",  "涪陵", "广州",  "贵阳",  "赣州",  "广安",  "桂林", "杭州",  "合肥",  "哈尔滨",  "呼和浩特",  "惠州", "邯郸",  "淮安",  "黄石",  "衡水",  "菏泽",  "湖州", "黄冈",  "合川",  "汉沽", "济南",  "济宁",  "吉林",  "嘉兴",  "佳木斯", "金华",  "江门",  "吉安",  "荆州",  "焦作",  "锦州", "江阴",  "静海",  "津南", "昆明",  "开封",  "开县",  "昆山", "洛阳",  "临沂",  "柳州",  "六安",  "辽阳",  "泸州", "临汾",  "兰州",  "廊坊",  "乐山",  "聊城", "绵阳",  "马鞍山",  "眉山", "南京",  "南昌",  "南宁",  "南通",  "南阳",  "南充", "宁波",  "内江", "莆田",  "平度", "青岛",  "泉州",  "曲靖",  "秦皇岛",  "齐齐哈尔", "衢州", "日照", "上海",  "苏州",  "沈阳",  "石家庄",  "深圳", "绍兴",  "宿迁",  "松原",  "遂宁",  "十堰",  "汕头", "天津",  "唐山",  "太原",  "泰州",  "泰安",  "台州", "铜陵",  "太仓",  "塘沽", "武汉",  "潍坊",  "无锡",  "威海",  "芜湖",  "温州", "乌鲁木齐",  "万州",  "吴江",  "瓦房店",  "武清", "西安",  "厦门",  "徐州",  "襄阳",  "新乡",  "湘潭", "许昌",  "信阳",  "邢台",  "孝感", "银川",  "烟台",  "扬州",  "宜昌",  "运城",  "宜宾", "盐城",  "营口",  "宜春",  "岳阳",  "云阳",  "永川", "宜兴", "郑州",  "中山",  "漳州",  "株洲",  "镇江",  "淄博", "枣庄",  "资阳",  "珠海",  "自贡",  "驻马店", "张家港"]

  # if false
  #   cui = UserSystem::CarUserInfo.find 8314722
  #   UserSystem::GuaziCarUserInfo.create_user_info_from_car_user_info cui
  # end


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
        pp '更新瓜子车异常'
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

    cui.xiaoqudao = cui.car_user_info.wuba_kouling if cui.site_name == 'guazi_shouche'
    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::GuaziCarUserInfo.upload_guazi cui
  end


  # gcuis = UserSystem::GuaziCarUserInfo.where("guazi_upload_status = ?", '未上传')
  # gcuis.each do |cui|
  #   UserSystem::GuaziCarUserInfo.upload_guazi cui
  # end


  def self.upload_guazi yc_car_user_info
    # return if yc_car_user_info.phone == '13472446647'

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

    begin
    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '手机号不正确'
      yc_car_user_info.save!
      return
    end
    rescue
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

begin
    if !yc_car_user_info.car_user_info.note.blank? and yc_car_user_info.car_user_info.note.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end
rescue
  end


    begin
    if !yc_car_user_info.car_user_info.che_xing.blank? and yc_car_user_info.car_user_info.che_xing.match /\d{11}/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end
    rescue
    end

    ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
      next if yc_car_user_info.name.blank?
      next if yc_car_user_info.car_user_info.che_xing.blank?
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
    begin
    tmp_chexing = yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
    tmp_note = yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '')
    if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
      yc_car_user_info.guazi_upload_status = '疑似走私车'
      yc_car_user_info.save!
      return
    end
    rescue
      end

    cui = yc_car_user_info.car_user_info

    # 2017-04-26  进一步放宽条件
    # cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    # cui.save!
    # if not cui.phone_city.blank?
    #   unless cui.city_chinese == cui.phone_city
    #     yc_car_user_info.guazi_upload_status = '非本地车'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end


    begin
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
    rescue
      end


    # 2017-04-26  进一步放宽条件
    # config_key_words = 0
    # ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
    #  "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
    #  "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
    #  "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
    #   config_key_words+=1 if cui.note.include? kw
    # end
    # # 过多配置描述，一般车商
    # if config_key_words > 6
    #   yc_car_user_info.guazi_upload_status = '疑似车商，'
    #   yc_car_user_info.save!
    #   return
    # end

    host_name = "http://commapi.guazi.com/clue/carClue/AddCarSource" #正式环境

    scode = if yc_car_user_info.site_name == 'guazi_shouche'
              UserSystem::GuaziCarUserInfo::GZSCODE_SHOUCHE
            else
              UserSystem::GuaziCarUserInfo::GZSCODE
            end

    param = {
        appkey: UserSystem::GuaziCarUserInfo::GZAPPKEY,
        app_secret: UserSystem::GuaziCarUserInfo::GZAPPSECRET,
        nonce: UserSystem::GuaziCarUserInfo::RANDSTR,
        expires: Time.now.to_i+6000,
        phoneNum: cui.phone,
        scode: scode,
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


    gcui = UserSystem::GuaziCarUserInfo.where("guazi_yaoyue is null and created_at > ? and guazi_upload_status = '0'", Time.now - 20.days)
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
        cui.guazi_id = response["code"]
        if [2, 6, 14].include? response["data"]["statusCode"].to_i
          cui.guazi_jiance = response["data"]["statusCode"].to_i
          cui.guazi_yaoyue = '失败'
          cui.save!
          next
        end

        if [9].include? response["data"]["statusCode"].to_i
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
    params.each_with_index do |param, i|
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


    sign = (Digest::MD5.hexdigest(Base64.encode64("#{OpenSSL::HMAC.digest('sha256', UserSystem::GuaziCarUserInfo::GZAPPSECRET, k)}").gsub("\n", '')))[5, 10]

    pp sign
    return sign
    # puts CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',k, GZAPPSECRET)}\n"))
  end


  # UserSystem::GuaziCarUserInfo.query_guazi_chengjiao
  def self.query_guazi_chengjiao
    host_name = "http://commapi.guazi.com/clue/carClue/GuaZiGetCarClueStatus" #正式环境


    gcui = UserSystem::GuaziCarUserInfo.where("guazi_yaoyue = '成功'")
    gcui.find_each do |cui|

      next unless cui.guazi_chengjiao.blank?

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
        next
      end

      chengjiao = begin
        response["data"]["CarSoldDate"] rescue ''
      end
      chengjiao.gsub!('无', '')
      next if chengjiao.blank?

      cui.guazi_chengjiao = chengjiao
      cui.save!


    end
  end

  def self.xx
    shouche_date = '2017-5-15'
    password = 'i8293lUFopW#ksi(&%$FJK'
    t = Time.now.to_i
    sign = Digest::MD5.hexdigest("#{shouche_date}#{t}#{password}")
    response = RestClient.get "http://che.uguoyuan.cn/api/v1/update_user_infos/shoucheyj?date=#{CGI.escape shouche_date}&time=#{t}&sign=#{sign}"
    pp JSON.parse response
  end


  # 收车业绩
  # 传入查询日期
  def self.shouche_yeji shouche_date, time, paramsign
    password = 'i8293lUFopW#ksi(&%$FJK'
    sign = Digest::MD5.hexdigest("#{shouche_date}#{time}#{password}")
    BusinessException.raise '签名不正确' unless sign == paramsign

    shouche_date = "2017-05-15"
    shouche_date = Date.parse shouche_date
    BusinessException.raise '未出结果' if shouche_date >= Date.today

    BusinessException.raise '已过期' if Time.now.to_i - time.to_i > 300


        #提交
    push_cuis = UserSystem::GuaziCarUserInfo.
        joins("left join car_user_infos  on guazi_car_user_infos.car_user_info_id = car_user_infos.id").
        where("guazi_car_user_infos.created_day = ? and guazi_car_user_infos.site_name = ? and guazi_car_user_infos.guazi_upload_status in ('0', '重复')",
              shouche_date, "guazi_shouche").
        group('car_user_infos.wuba_kouling').
        select("count(*) as c, car_user_infos.wuba_kouling as qudao")

    shangjia_cuis = UserSystem::GuaziCarUserInfo.
        joins("left join car_user_infos  on guazi_car_user_infos.car_user_info_id = car_user_infos.id").
        where("guazi_car_user_infos.guazi_yaoyue = '成功' and guazi_car_user_infos.yaoyue_day = ? and guazi_car_user_infos.site_name = ? ",
              shouche_date, "guazi_shouche").
        group('car_user_infos.wuba_kouling').
        select("count(*) as c, car_user_infos.wuba_kouling as qudao")

    chengjiao_cuis = UserSystem::GuaziCarUserInfo.
        joins("left join car_user_infos  on guazi_car_user_infos.car_user_info_id = car_user_infos.id").
        where("guazi_car_user_infos.guazi_yaoyue = '成功' and guazi_car_user_infos.guazi_chengjiao > ? and guazi_car_user_infos.guazi_chengjiao < ? and guazi_car_user_infos.site_name = ? ",
              "#{shouche_date.strftime("%Y-%m-%d")} 00:00:00","#{shouche_date.chinese_format_day} 23:59:59" , "guazi_shouche").
        group('car_user_infos.wuba_kouling').
        select("count(*) as c, car_user_infos.wuba_kouling as qudao")

    return {:push => push_cuis, :shangjia => shangjia_cuis, :chengjiao => chengjiao_cuis}


    # 上架  成交


    # gz_today_chenggong = UserSystem::GuaziCarUserInfo.where("guazi_yaoyue = '成功' and yaoyue_day = ?", Date.today).count
    # gz_month_chenggong = UserSystem::GuaziCarUserInfo.where("guazi_yaoyue = '成功' and yaoyue_day >= ?", Date.new(Date.today.year, Date.today.month, 1)).count

    # 瓜子创建量
    # gz_today_maoshuju = UserSystem::GuaziCarUserInfo.where("guazi_id = '0' and created_day = ?", Date.today ).count
    # gz_yesterady_maoshuju = UserSystem::GuaziCarUserInfo.where("guazi_id = '0' and created_day = ?", Date.today.yesterday ).count

    # 瓜子提交量,包含重复和创建
    # gz_today_all_maoshuju = UserSystem::GuaziCarUserInfo.where("guazi_upload_status in ('0', '重复') and created_day = ?", Date.today).count
    # gz_yesterady_all_maoshuju = UserSystem::GuaziCarUserInfo.where("guazi_upload_status in ('0', '重复') and created_day = ?", D
  end

end

__END__


