class UserSystem::YouyicheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ["北京", "南京", "深圳", "上海", "青岛", "西安", "郑州", "无锡", "苏州",
          "杭州",
          "常州", "重庆", "武汉", "长沙", "成都", "太原", "南昌", "昆明", "宁波", "东莞", "济南", "南宁",
          "贵阳", "临沂", "广州", "佛山", "南通", "嘉兴", "金华", '台州', "合肥", "徐州", "大连", "沈阳",
          "天津", "哈尔滨", "长春", "厦门", "福州", "泉州", "石家庄", "邯郸", "唐山", "沧州", "保定"]

  # 只在在这个hash中出现的城市,都会被推到网页端。
  DIQU = {"太原" => '1947', "南昌" => "1919", "昆明" => "2134", "宁波" => "2124", "东莞" => "2067", "济南" => "1930", "南宁" => "2085",
          "贵阳" => "2167", "临沂" => '1942', "广州" => '2051', "佛山" => '2056', "南通" => '2077', "嘉兴" => '2126', "金华" => '2129',
          "温州" => '2125',
          '台州' => '2132', "合肥" => '2150', "徐州" => '2074', "大连" => '1989', "沈阳" => '1988', "天津" => '1892', "哈尔滨" => '2038',
          "长春" => '2015',
          "厦门" => "1911", "福州" => "1910", "泉州" => "1914", "石家庄" => "1899", "邯郸" => "1902", "唐山" => "1900", "沧州" => "1907",
          "保定" => "1904",
          "北京" => "1867", "南京" => "2072", "深圳" => "2053", "上海"=>"1889", "青岛" => "1931", "西安" => "2176", "郑州" => "1970",
          "无锡" => "2073", "苏州" => "2076",
          "杭州" => "2123",
          "常州" => "2075", "重庆" => "1898", "武汉" => "2002", "长沙" => "2024", "成都" => "2102"
  }


  #阿里的所有地区全部往网页中提交
  ALIDIQU = {"太原" => '1947', "南昌" => "1919", "昆明" => "2134", "宁波" => "2124", "东莞" => "2067", "济南" => "1930", "南宁" => "2085",
          "贵阳" => "2167", "临沂" => '1942', "广州" => '2051', "佛山" => '2056', "南通" => '2077', "嘉兴" => '2126', "金华" => '2129',
          "温州" => '2125',
          '台州' => '2132', "合肥" => '2150', "徐州" => '2074', "大连" => '1989', "沈阳" => '1988', "天津" => '1892', "哈尔滨" => '2038',
          "长春" => '2015',
          "厦门" => "1911", "福州" => "1910", "泉州" => "1914", "石家庄" => "1899", "邯郸" => "1902", "唐山" => "1900", "沧州" => "1907",
          "保定" => "1904",
          "北京" => "1867", "南京" => "2072", "深圳" => "2053", "上海"=>"1889", "青岛" => "1931", "西安" => "2176", "郑州" => "1970",
          "无锡" => "2073", "苏州" => "2076",
          "杭州" => "2123",
          "常州" => "2075", "重庆" => "1898", "武汉" => "2002", "长沙" => "2024", "成都" => "2102"
  }

  # UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info
    return if car_user_info.brand.blank?
    return unless ['58', 'ganji', 'baixing', 'che168', 'zuoxi'].include? car_user_info.site_name
    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::YouyicheCarUserInfo::CITY.include?(car_user_info.city_chinese)
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

    cui = UserSystem::YouyicheCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::YouyicheCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::YouyicheCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!


    UserSystem::YouyicheCarUserInfo.upload_youyiche cui


    return cui
  end


  def self.cc
    UserSystem::YouyicheCarUserInfo.where("youyiche_chengjiao like '%管理员%'").each do |yc_car_user_info|
      UserSystem::YouyicheCarUserInfo.upload_cui_via_web yc_car_user_info
    end

  end

  # yc_car_user_info = UserSystem::YouyicheCarUserInfo.find id
  # UserSystem::YouyicheCarUserInfo.upload_youyiche yc_car_user_info
  def self.upload_youyiche yc_car_user_info, j = 1
    yc_car_user_info.youyiche_chengjiao = "#{j}" if j > 1

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.youyiche_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.name.blank?
      yc_car_user_info.youyiche_upload_status = '姓名不对'
      yc_car_user_info.save!
      return
    end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.youyiche_upload_status = '手机号不正确'
      yc_car_user_info.save!
      return
    end

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

    # if not yc_car_user_info.is_city_match
    #   pp '城市不匹配'
    #   yc_car_user_info.youyiche_upload_status = '城市不匹配'
    #   yc_car_user_info.save!
    #   return
    # end

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

    # 2017-11-15  增加数据范围 注释掉以下限制
    # ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ'].each do |kw|
    #   if yc_car_user_info.name.include? kw or yc_car_user_info.car_user_info.che_xing.include? kw
    #     yc_car_user_info.youyiche_upload_status = '疑似走私车或车商'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end

    # 2017-11-15  增加数据范围 注释掉以下限制
    # if /^[a-z|A-Z|0-9|-|_]+$/.match yc_car_user_info.name
    #   yc_car_user_info.youyiche_upload_status = '疑似走私车'
    #   yc_car_user_info.save!
    #   return
    # end

    #还有用手机号，QQ号做名字的。
    # 2017-11-15  增加数据范围 注释掉以下限制
    # if /[0-9]+/.match yc_car_user_info.name
    #   yc_car_user_info.youyiche_upload_status = '疑似走私车'
    #   yc_car_user_info.save!
    #   return
    # end

    # 2017-11-15 临时去掉,看看还是不是存在类似情况。
    # if ["温州", "宁波"].include? yc_car_user_info.city_chinese and /^17/.match yc_car_user_info.phone
    #   yc_car_user_info.youyiche_upload_status = '拨不通电话'
    #   yc_car_user_info.save!
    #   return
    # end

    #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
    begin
      tmp_chexing = begin
        yc_car_user_info.car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '') rescue ''
      end
      tmp_note = begin
        yc_car_user_info.car_user_info.note.gsub(/\s|\.|~|-|_/, '') rescue ''
      end
      if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
        yc_car_user_info.youyiche_upload_status = '疑似走私车'
        yc_car_user_info.save!
        return
      end
    rescue Exception => e
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
    # if ['苏州', '杭州', '成都', '合肥', '宿州', '福州'].include? yc_car_user_info.city_chinese

    # if Time.now.hour < 6 and ['苏州','合肥'].include? yc_car_user_info.city_chinese
    #   yc_car_user_info.youyiche_upload_status = '时间太早'
    #   yc_car_user_info.save!
    #   return
    # end

    # cui = yc_car_user_info.car_user_info
    # cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    # cui.save!
    # if not cui.phone_city.blank?
    #   unless cui.city_chinese == cui.phone_city
    #     yc_car_user_info.youyiche_upload_status = '非本地车'
    #     yc_car_user_info.save!
    #     return
    #   end
    # end


    # if cui.note.match /^出售/
    #   yc_car_user_info.youyiche_upload_status = '疑似车商'
    #   yc_car_user_info.save!
    #   return
    # end
    #
    # if cui.che_xing.match /QQ|电话|不准|低价|私家车|咨询|一手车|精品|业务|打折|货车/
    #   yc_car_user_info.youyiche_upload_status = '疑似车商'
    #   yc_car_user_info.save!
    #   return
    # end


    # config_key_words = 0
    # ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
    #  "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
    #  "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
    #  "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
    #   config_key_words+=1 if cui.note.include? kw
    # end
    #
    #
    # # 过多配置描述，一般车商
    # if config_key_words > 6
    #   yc_car_user_info.youyiche_upload_status = '疑似车商，'
    #   yc_car_user_info.save!
    #   return
    # end



    # 需要往网页端传的数据如下:
    # ucloud 一部分进网页,一部分走又一车接口。    ali全部走网页
    dq = UserSystem::YouyicheCarUserInfo::DIQU
    dq = UserSystem::YouyicheCarUserInfo::ALIDIQU if Personal::Role.system_name == 'ali'

    if dq.keys.include? yc_car_user_info.city_chinese
      yc_car_user_info.youyiche_status_message = 'need_export_excel'
      yc_car_user_info.save!

      UserSystem::YouyicheCarUserInfo.upload_cui_via_web yc_car_user_info


      return
    end



    params = {
        "name" => yc_car_user_info.name,
        "phone" => yc_car_user_info.phone,
        "isSell" => 1,
        "city" => yc_car_user_info.city_chinese,
        "type" => "线上合作",
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

  #以excel方式导出上一小时的数据
  # UserSystem::YouyicheCarUserInfo.export_last_city_phones
  def self.export_last_city_phones
    return if Time.now.hour < 7
    return if Time.now.hour > 22
    return unless Time.now.min >= 0
    return unless Time.now.min < 10

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: "Sheet1"
    ['客户姓名', '客户地区', '手机号码', '品牌', '车系', '车型', '车牌号', '客户心理价(元)', '上牌时间', '备注'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    row = 1

    need_status = 'need_export_excel'
    ycuis = UserSystem::YouyicheCarUserInfo.where("created_at > ? and youyiche_status_message = '#{need_status}'", Time.now - 670.minutes)
    ycuis.each do |ycui|
      next if ycui.name.blank?
      next if ycui.phone.blank?
      [ycui.name.gsub('(个人)', ''), ycui.city_chinese, ycui.phone, ycui.brand, ycui.car_user_info.cx].each_with_index do |content, i|
        sheet1.row(row)[i] = content
      end
      ycui.youyiche_status_message = '已倒出'
      ycui.save!
      row += 1
    end

    return if row == 1


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}上传车置宝信息.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('lanjing@uguoyuan.cn',
                                 'xiaoqi.liu@uguoyuan.cn',
                                 row,
                                 "车置宝最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver
  end




  def self.upload_cui_via_web ycui
    return if ycui.phone.blank?
    OrderSystem::WeizhangLog.add_baixing_json_body ycui.id, 'czb'
    return
  end



  # UserSystem::YouyicheCarUserInfo.get_user_name yyc_id
  def self.post_data_with_session yyc_id
    # yyc_id = 318303
    yyc_cui = UserSystem::YouyicheCarUserInfo.find yyc_id.to_i
    user_name = UserSystem::YouyicheCarUserInfo.get_user_name
    text = `curl -b '/data/czb/#{user_name}' http://fdep.mychebao.com/car/manage`
    form = Nokogiri::HTML(text)
    token = form.css("#add_Token")[0]["value"]

    phone = yyc_cui.phone
    regionid = UserSystem::YouyicheCarUserInfo::DIQU[yyc_cui.city_chinese]

    escape_shi = CGI::escape begin  "#{yyc_cui.city_chinese}市" rescue ''  end
    escape_brand = CGI::escape begin yyc_cui.brand rescue "未知" end
    escape_cx = CGI::escape begin yyc_cui.car_user_info.cx rescue "未知" end
    name = CGI::escape begin yyc_cui.name rescue "未知" end

    response = `curl 'http://fdep.mychebao.com/car/addCar' -b '/data/czb/#{user_name}' -H 'User-Agent: Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://fdep.mychebao.com/car/manage' -H 'X-Requested-With: XMLHttpRequest' -H 'Proxy-Connection: keep-alive' --data 'addToken=#{token}&contactname=#{name}&phone=#{phone}&regionid=#{regionid}&location=#{escape_shi}&brandname=#{escape_brand}&modelname=#{ escape_cx}&type=#{CGI::escape "其它"}' --compressed`

    yyc_cui.youyiche_status_message = '已倒出'

    yyc_cui.youyiche_chengjiao = response
    yyc_cui.save
  end

  # 获取可以提交数据的用户名
  # UserSystem::YouyicheCarUserInfo.get_user_name
  def self.get_user_name
    redis = Redis.current

    return "chexian2" if Personal::Role.system_name == 'ali' and redis["chexian2-0001"] == 'yes'

    return 'cxmcsj' if  redis["cxmcsj-0001"] == 'yes'

    # user_name = []
    # ["cxmcsj", "gaoyixiangchezhu1", "gaoyixiangchezhu2"].each do |name|
    #   user_name << name if  redis["#{name}-0001"] == 'yes'
    # end
    # user_name.shuffle!
    # user_name[0]

  end


  # 每次扫之前, 先检查redis, 检查是否过期。 如果有效,就刷新。
  # 如果无效,就不再刷新,同时发邮件通知。
  # 2分钟刷新一次网页, 网页在redis中对应的key是:  cxmcsj-0001   gaoyixiangchezhu1-0001    gaoyixiangchezhu2-0001
  # UserSystem::YouyicheCarUserInfo.shuaxin_3_user

  #增加对阿里云服务器兼容
  def self.shuaxin_3_user
    redis = Redis.current
    user_names = ["cxmcsj", "gaoyixiangchezhu1", "gaoyixiangchezhu2"]
    user_names = ["chexian2"] if Personal::Role.system_name == 'ali'
    user_names.each do |name|
      redis["#{name}-0001"] = 'yes' if redis["#{name}-0001"].blank?
      redis["#{name}-0001_freshen_time"] = Time.now.to_i if redis["#{name}-0001_freshen_time"].blank?

      #2分钟以内不刷新
      next if Time.now.to_i - redis["#{name}-0001_freshen_time"].to_i <  120
      redis["#{name}-0001_freshen_time"] = Time.now.to_i # 记录当前刷新时间

      if redis["#{name}-0001"] == 'yes'
        text = `curl -b /data/czb/#{name} http://fdep.mychebao.com/car/manage`
        if text.include? '图形验证码'
          redis["#{name}-0001"] = 'no'
          MailSend.send_content('xiaoqi.liu@uguoyuan.cn',
                                'xiaoqi.liu@uguoyuan.cn',
                                "车置宝#{name}用户session失效",
                                "车置宝#{name}用户session失效, 运行 UserSystem::YouyicheCarUserInfo.repair_cookie '#{name}', '正确的session'"

          ).deliver
        else
          redis["#{name}-0001"] = 'yes'
        end
      end
    end
  end

  # 在控制台,把参数写到cookie文件中, 同时把redis中的状态置为正常, 同时, 把正常数据提交到状态正常的账号中。
  def self.repair_cookie user_name, session_id
    cookie_content = "HTTP/1.1 200 OK
Server: nginx
Date: Tue, 04 Jul 2017 03:06:34 GMT
Content-Type: text/html;charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Vary: Accept-Encoding
Set-Cookie: JSESSIONID=#{session_id}; Path=/; HttpOnly"

    file = File.open("/data/czb/#{user_name}", 'w')
    file << cookie_content
    file.close
    redis = Redis.current
    redis["#{user_name}-0001"] = 'yes'
  end

end
__END__
