class UserSystem::YouyicheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'


  # 泉州
  # 唐山
  # 邯郸
  # 石家庄
  # 沧州
  # 保定

  CITY = ["北京", "南京", "深圳", "上海", "青岛", "西安", "郑州", "无锡", "苏州", "杭州", "常州", "重庆", "武汉", "长沙", "成都",
          "太原", "南昌", "昆明", "宁波", "东莞", "济南", "南宁",
          "贵阳", "临沂", "广州", "佛山", "南通", "嘉兴", "金华", "温州", '台州', "合肥", "徐州", "大连", "沈阳", "天津", "哈尔滨", "长春",
          "厦门", "福州", "泉州", "石家庄", "邯郸", "唐山", "沧州", "保定"]


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

    # sleep_time = rand(3)
    # sleep sleep_time

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


  def temp_upload
    # 广州 195    佛山    温州  187
    # [  "贵阳", "临沂", "广州","佛山", "南通", "嘉兴", "金华", "温州", '台州', "合肥","徐州","大连","沈阳", "天津", "哈尔滨","长春"].each do |k|


    #"厦门","合肥",        "泉州","石家庄","邯郸","唐山","沧州","保定"
    ["广州"].each do |k|
      cuis = UserSystem::CarUserInfo.where("city_chinese = ? and created_at > ?", k, Time.now - 100.days)
      cuis.each do |cui|
        pp cui.id
        next if cui.tt_yaoyue == '历史遗留数据'
        UserSystem::CarUserInfo.che_shang_jiao_yan cui, true
        UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info cui
      end
    end


    # cuis = UserSystem::YouyicheCarUserInfo.where("youyiche_status_message = '车源提交失败'").select(:car_user_info_id)
    # ids = cuis.collect &:car_user_info_id
    #
    # UserSystem::YouyicheCarUserInfo.delete_all("youyiche_status_message = '车源提交失败'")
    #
    # ids.each do |id|
    #   begin
    #     cui = UserSystem::CarUserInfo.find id
    #     pp cui.id
    #
    #     next if cui.tt_yaoyue == '历史遗留数据'
    #     UserSystem::CarUserInfo.che_shang_jiao_yan cui, true
    #     UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info cui
    #   rescue
    #   end
    # end

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

    #对量进行严格控制
    # peiliang = {"苏州" => 40, "杭州" => 30, "成都" => 50}
    # peiliang = {"苏州" => 460, "杭州" => 500, "成都" => 700, "合肥" => 800, '宿州' => 25, "福州" => 200}
    # liang = peiliang[yc_car_user_info.city_chinese]
    # yijingyoudeliang = UserSystem::YouyicheCarUserInfo.where("city_chinese = ? and created_day = ? and youyiche_id is not null", yc_car_user_info.city_chinese, Time.now.chinese_format_day).count
    # if yijingyoudeliang > liang
    # xemail  = if rand(10)<6 then 'lanyu@uguoyuan.cn' else 'lanjing@uguoyuan.cn' end
    # yc_car_user_info.youyiche_upload_status = "。超出配额-给兰-#{xemail}"
    # yc_car_user_info.save!
    #
    # #超出配额给兰昱。
    #
    #
    # (MailSend.send_content xemail, '', "#{yc_car_user_info.name} 有车要卖",
    #                        "#{yc_car_user_info.phone}   #{yc_car_user_info.name}  #{yc_car_user_info.brand}").deliver
    #   yc_car_user_info.youyiche_upload_status = '过量'
    #   yc_car_user_info.save!
    #   return
    # end

    # end

    # if yc_car_user_info.city_chinese == '成都'
    #   #成都暂时给兰昱。
    #   xemail  = if rand(10)<6 then 'lanyu@uguoyuan.cn' else 'lanjing@uguoyuan.cn' end
    #   yc_car_user_info.youyiche_upload_status = "成都车-给兰-#{xemail}"
    #   yc_car_user_info.save!
    #
    #   (MailSend.send_content xemail, '', "#{yc_car_user_info.name} 有车要卖",
    #                          "#{yc_car_user_info.phone}   #{yc_car_user_info.name}  #{yc_car_user_info.brand}").deliver
    #   return
    # end


    # 新城市临时通过手动方式进行上传,在这里先进行标记
    if ["太原", "南昌", "昆明", "宁波", "东莞", "济南", "南宁",
        "贵阳", '临沂', "广州", "佛山", "南通", "嘉兴", "金华", "温州",
        '台州', "合肥", "徐州", "大连", "沈阳", "天津", "哈尔滨", "长春", "厦门", "福州", "泉州",
        "石家庄", "邯郸", "唐山", "沧州", "保定"].include? yc_car_user_info.city_chinese
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


  # # UserSystem::YouyicheCarUserInfo.export_last_city_phones2
  # def self.export_last_city_phones2
  #   # return if Time.now.hour < 7
  #   # return if Time.now.hour > 22
  #   # return unless Time.now.min >= 0
  #   # return unless Time.now.min < 10
  #
  #   diqu = {"太原" => '1947',
  #           "南昌" => "1919",
  #           "昆明" => "2134",
  #           "宁波" => "2124", "东莞" => "2067", "济南" => "1930", "南宁" => "2085"}
  #
  #
  #   need_status = 'need_export_excel'
  #   ycuis = UserSystem::YouyicheCarUserInfo.where("created_at > ? and youyiche_status_message = '#{need_status}'", Time.now - 10.minutes)
  #   ycuis.each do |ycui|
  #
  #     next if ycui.phone.blank?
  #
  #     escape_shi = CGI::escape "#{ycui.city_chinese}市" rescue ''
  #
  #     response = `curl 'http://www.mychebao.com/czhib_promote/addInfoToFdep.htm' -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1' --data 'id=272&phone=#{ycui.phone}&regionid=#{diqu[ycui.city_chinese]}&location=#{escape_shi}&brand=#{begin CGI::escape ycui.brand rescue '' end}&model=#{begin CGI::escape ycui.car_user_info.cx rescue '' end}&type=#{CGI::escape "其它"}&channelId=' --compressed`
  #
  #     ycui.youyiche_status_message = '已倒出'
  #     ycui.save!
  #
  #     ycui.youyiche_chengjiao = response
  #     ycui.save
  #
  #   end
  # end

  def self.upload_cui_via_web ycui
    return if ycui.phone.blank?

    diqu = {"太原" => '1947',
            "南昌" => "1919",
            "昆明" => "2134",
            "宁波" => "2124",
            "东莞" => "2067",
            "济南" => "1930",
            "南宁" => "2085",
            "贵阳" => "2167", "临沂" => '1942', "广州" => '2051', "佛山" => '2056', "南通" => '2077', "嘉兴" => '2126', "金华" => '2129', "温州" => '2125',
            '台州' => '2132', "合肥" => '2150', "徐州" => '2074', "大连" => '1989', "沈阳" => '1988', "天津" => '1892', "哈尔滨" => '2038', "长春" => '2015',
            "厦门" => "1911", "福州" => "1910", "泉州" => "1914", "石家庄" => "1899", "邯郸" => "1902", "唐山" => "1900", "沧州" => "1907", "保定" => "1904"
    }

    users = {
        "gaoyixiangchezhu1" => {"id" => "318", "channelId" => "1099"},
        "gaoyixiangchezhu2" => {"id" => "319", "channelId" => "1100"},
        "cxmcsj" => {"id" => "272", "channelId" => "998"}
    }

    user_name = if ['太原', "南昌", "宁波", "东莞", "济南", "南宁", "贵阳", '临沂', "广州", "佛山", "南通", "嘉兴", "金华", "温州", '台州', "合肥", "徐州", "大连", "沈阳", "天津"].include? ycui.city_chinese
                  "cxmcsj"
                else
                  if rand(10) < 5
                    "gaoyixiangchezhu2"
                  else
                    "gaoyixiangchezhu1"
                  end
                end

    # user_name = "gaoyixiangchezhu2"

    id = users[user_name]["id"]
    channelId = users[user_name]["channelId"]


    escape_shi = CGI::escape "#{ycui.city_chinese}市" rescue ''

    response = `curl 'http://www.mychebao.com/czhib_promote/addInfoToFdep.htm' -H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1' --data 'id=#{id}&phone=#{ycui.phone}&regionid=#{diqu[ycui.city_chinese]}&location=#{escape_shi}&brand=#{
    begin
      CGI::escape ycui.brand rescue ''
    end}&model=#{
    begin
      CGI::escape ycui.car_user_info.cx rescue ''
    end}&type=#{CGI::escape "其它"}&channelId=#{channelId}' --compressed`

    ycui.youyiche_status_message = '已倒出'
    ycui.save!

    ycui.youyiche_chengjiao = response
    ycui.save


  end


  # UserSystem::YouyicheCarUserInfo.query_youyiche
  # 2017-01-06 为缩短查询时间，只关注最近30天提交的数据
  # 2017-04-10 切换到车置宝以后,结束又一车查询,直接return
  def self.query_youyiche
    return #切换到车置宝以后, 查询功能丧失
    return unless Time.now.hour == 15
    return unless Time.now.hour == 20
    return unless Time.now.min < 10
    # host_name = 'uat.youyiche.com' #测试环境
    host_name = "b.youyiche.com" #正式环境

    # query_q_ids = {}
    # UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and youyiche_jiance is null  and id > 84000 and created_day > ?", Date.today - 30).find_each do |cui|
    #   next if cui.youyiche_yaoyue == '失败'
    #   next if cui.youyiche_jiance == '竞拍中'
    #   next if cui.youyiche_chengjiao == '失败'
    #
    #
    #   query_q_ids[0] = cui.youyiche_id
    #
    #   # 想加速查询，把5改为更大的数字
    #
    #
    #   response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", query_q_ids.to_json, :content_type => 'application/json'
    #   response = JSON.parse response.body
    #   pp response
    #
    # end


    query_q_ids = {}
    kk = 0
    sanbaideliang = 0
    UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and (youyiche_yaoyue is null or youyiche_yaoyue in ('未拨通')) and id > 70000 and created_day > ?", Date.today - 30).find_each do |cui|
      next if cui.youyiche_id.to_i == -1
      kk += 1
      query_q_ids["#{kk}"] = cui.youyiche_id
      # 想加速查询，把10改为更大的数字
      if kk == (
      if sanbaideliang < 180 then
        300
      else
        10
      end)
        pp 'XXX'
        kk = 0
        sanbaideliang += 1
        response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", query_q_ids.to_json, :content_type => 'application/json'
        pp response.body

        response = JSON.parse response.body
        pp response
        response.each do |xx|
          status = xx["status"].strip
          next if ['待跟进', '跟进中'].include? status
          next if status.blank?
          cuii = (UserSystem::YouyicheCarUserInfo.find_by_youyiche_id xx["need_id"])
          next if status == cuii.youyiche_yaoyue
          if status == '竞拍中'
            cuii.youyiche_jiance = status
          end
          cuii.youyiche_yaoyue = status
          cuii.save!
        end
        query_q_ids = {}
      end
    end


    query_q_ids = {}
    kk = 0
    sanbaideliang = 0
    UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and youyiche_jiance is null  and id > 70000 and created_day > ?", Date.today - 30).find_each do |cui|
      next if cui.youyiche_yaoyue == '失败'
      next if cui.youyiche_jiance == '竞拍中'
      next if cui.youyiche_chengjiao == '失败'
      kk += 1

      query_q_ids["#{kk}"] = cui.youyiche_id

      # 想加速查询，把5改为更大的数字
      if kk == (
      if sanbaideliang < 180 then
        300
      else
        10
      end)
        kk = 0
        sanbaideliang += 1
        response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", query_q_ids.to_json, :content_type => 'application/json'
        response = JSON.parse response.body
        pp response
        response.each do |xx|
          status = xx["status"].strip
          if status == '竞拍中'
            cuii = (UserSystem::YouyicheCarUserInfo.find_by_youyiche_id xx["need_id"])
            cuii.youyiche_jiance = status
            cuii.yaoyue_time = Time.now.chinese_format
            cuii.yaoyue_day = Time.now.chinese_format_day
            cuii.save!
          end
        end

        query_q_ids = {}
      end
    end

  end


  # UserSystem::YouyicheCarUserInfo.chengjiaogengxin
  # 查看又一车有多少车辆成交，成交价格多少。
  # def self.chengjiaogengxin
  #   #一次更新所有数据   最终结果
  #   host_name = "b.youyiche.com" #正式环境
  #   p = {}
  #   cuis = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and youyiche_jiance = '竞拍中'").each_with_index do |cui, i|
  #     next if cui.youyiche_chengjiao == '成交'
  #     next if cui.youyiche_chengjiao == '失败'
  #     p["#{i}"] = cui.youyiche_id
  #   end
  #   response = RestClient.post "http://#{host_name}/thirdpartyapi/vehicles_from_need/sync/xuzuo", p.to_json, :content_type => 'application/json'
  #   response = JSON.parse response.body
  #   response.each do |xx|
  #     cui = cuis.select { |cui| cui.youyiche_id == "#{xx["need_id"]}" }
  #     cui = cui[0]
  #     next if cui.youyiche_chengjiao == xx["status"]
  #     cui.youyiche_chengjiao = xx["status"]
  #     cui.save!
  #   end
  #
  # end

  # UserSystem::YouyicheCarUserInfo.jiancelu
  # 一开始竞标的时候需要多关注， 已不再使用
  # def self.jiancelu
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #
  #   sheet1 = book.create_worksheet name: "总体转化率"
  #   ['日期', '创建数', '竞拍数', '竞拍率'].each_with_index do |content, i|
  #     sheet1.row(0)[i] = content
  #   end
  #   0.upto 30 do |i|
  #     date = Date.today - i
  #     # yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? and youyiche_yaoyue not in ('重复') AND  youyiche_yaoyue IS NOT NULL", date.chinese_format_day)
  #     yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? and youyiche_yaoyue <> '重复' ", date)
  #     # yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? ", date.chinese_format_day)
  #     yiccuis_yaoyue = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and yaoyue_day  = ? and youyiche_jiance = '竞拍中'", date)
  #
  #     yaoyuelv = if yiccuis_create.count == 0 then
  #                  '无'
  #                else
  #                  "#{((yiccuis_yaoyue.count.to_f/yiccuis_create.count.to_f)*100).to_i}%"
  #                end
  #     [date.chinese_format_day, yiccuis_create.count, yiccuis_yaoyue.count, yaoyuelv].each_with_index do |content, j|
  #       sheet1.row(i+1)[j] = content
  #     end
  #
  #   end
  #
  #   CITY.each do |city|
  #     sheet1 = book.create_worksheet name: "#{city}转化率"
  #     ['日期', '创建数', '竞拍数', '竞拍率'].each_with_index do |content, i|
  #       sheet1.row(0)[i] = content
  #     end
  #     0.upto 20 do |i|
  #       date = Date.today - i
  #
  #       # yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? and youyiche_yaoyue not in ('重复') AND  youyiche_yaoyue IS NOT NULL and city_chinese = ?", date.chinese_format_day, city)
  #       yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? and youyiche_yaoyue  <> '重复'  and city_chinese = ?", date, city)
  #       # yiccuis_create = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and created_day  = ? ", date.chinese_format_day)
  #       yiccuis_yaoyue = UserSystem::YouyicheCarUserInfo.where("youyiche_id is not null and yaoyue_day  = ? and youyiche_jiance = '竞拍中' and city_chinese = ?", date, city)
  #       # next if yiccuis_create.count == 0
  #       # pp "#{city} #{date.chinese_format_day}上架率：#{}%"
  #
  #       yaoyuelv = if yiccuis_create.count == 0 then
  #                    '无'
  #                  else
  #                    "#{((yiccuis_yaoyue.count.to_f/yiccuis_create.count.to_f)*100).to_i}%"
  #                  end
  #
  #       [date.chinese_format_day, yiccuis_create.count, yiccuis_yaoyue.count, yaoyuelv].each_with_index do |content, j|
  #         sheet1.row(i+1)[j] = content
  #       end
  #
  #     end
  #   end
  #
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "又一车转化率 #{Time.now.strftime("%Y%m%dT%H%M%S")}导出.xls")
  #   book.write file_path
  #   file_path
  # end

  # def self.s
  #
  #
  #   ycuis = UserSystem::YouyicheCarUserInfo.where("youyiche_chengjiao like '%已超过单日最大提交量,请明日再提交数据%'")
  #   ids = []
  #   ycuis.each do |k|
  #     ids << k.car_user_info_id
  #   end
  #
  #   ids.each do |id|
  #     cui = UserSystem::CarUserInfo.find id
  #     UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info cui
  #   end
  #
  # end

end
__END__
