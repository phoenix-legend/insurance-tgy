class UserSystem::CarUserInfo < ActiveRecord::Base
  require 'rest-client'
  require 'pp'

  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: true, :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :name, message: '请填写姓名', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :brand, message: '请填写品牌', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :city_chinese, message: '请填写城市', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }


  # CURRENT_ID = 171550  第一次导入
  CURRENT_ID = 539767

  EMAIL_STATUS = {0 => '待导', 1 => '已导', 2 => '不导入'}
  # ALL_CITY = {"441900" => "东莞", "440600" => "佛山", "440100" => "广州",
  #             "440300" => "深圳", "370100" => "济南", "370200" => "青岛",
  #             "330100" => "杭州", "330200" => "宁波", "330300" => "温州",
  #             "320100" => "南京", "320500" => "苏州", "320200" => "无锡",
  #             "130100" => "石家庄", "130200" => "唐山", "410100" => "郑州",
  #             "110100" => "北京", "210200" => "大连", "210100" => "沈阳",
  #             "310100" => "上海", "500100" => "重庆", "350100" => "福州",
  #             "350200" => "厦门", "420100" => "武汉", "430100" => "长沙",
  #             "230100" => "哈尔滨", "610100" => "西安", "510100" => "成都",
  #             "140100" => "太原", "120100" => "天津", "340100" => '合肥'}

  ALL_CITY = {"310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州","420100" => "武汉",
               "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡",
              "110100" => "北京", "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛"} #, "320400" => '常州'

  def self.get_che168_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州","420100" => "武汉"
        }
      when 1
        {
            "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡",
        }
      else
        {
            "110100" => "北京", "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛"
        }
    end
  end


  #城市所对应的拼音。 主要用于从淘车网更新数据。

  PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "beijing" => "北京", "zhengzhou" => '郑州', 'changsha' => '长沙',
      'xian' => '西安', "qingdao" => "青岛", 'zhenjiang' => '镇江', "wuxi" => "无锡"
  } #, "changzhou" => "常州"


  BAIXING_PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "beijing" => "北京", "zhengzhou" => '郑州', 'changsha' => '长沙',
      'xian' => '西安', "qingdao" => "青岛", 'zhenjiang' => '镇江', "wuxi" => "无锡"
  } #, "changzhou" => "常州"


  GANJI_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉",
       "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡",
      'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zhenjiang' => '镇江', 'bj' => '北京'
  } #, "changzhou" => "常州"
  def self.get_ganji_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉"
        }
      when 1
        {
            "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡"
        }
      else
        {
            'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zhenjiang' => '镇江', 'bj' => '北京'
        }
    end
  end





  WUBA_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州","wh" => "武汉",
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡","cq" => "重庆",
      'bj' => '北京', 'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江'
  } #, "cz" => "常州"

  def self.get_58_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州","wh" => "武汉",
        }
      when 1
        {
            "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡","cq" => "重庆",
        }
      else
        {
            'bj' => '北京', 'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江'
        }
    end
  end






  def self.create_car_user_info options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return 1 if user_infos.length > 0

    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return 0
  end

  def self.create_car_user_info_and_return_id options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return user_infos.first if user_infos.length > 0
    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return car_user_info
  end

  def self.update_detail params
    pp params
    car_user_info = UserSystem::CarUserInfo.find params[:id]

    #更新数据模块
    car_user_info.name = params[:name].gsub('联系TA', '先生女士') unless params[:name].blank?
    car_user_info.phone = params[:phone]
    car_user_info.note = params[:note]
    car_user_info.fabushijian = params[:fabushijian] unless params[:fabushijian].blank?
    if not params[:licheng].blank?
      car_user_info.milage = params[:licheng].gsub('万公里', '')
    end
    if not params[:price].blank?
      car_user_info.price = params[:price]
    end

    if not params[:brand].blank?
      car_user_info.brand = params[:brand]
    end
    car_user_info.need_update = false
    car_user_info.save!

    # 更新车商库
    begin
      UserSystem::CarBusinessUserInfo.add_business_user_info_phone car_user_info
    rescue Exception => e
      pp '更新商家电话号码出错'
      pp e
    end

    #如果在car_business_user中出现，就算作车商
    cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
    unless cbui.blank?
      car_user_info.is_cheshang = 1
      car_user_info.is_real_cheshang = true
      car_user_info.need_update = false
      car_user_info.save!
    end

    is_pachong = UserSystem::CarBusinessUserInfo.is_pachong car_user_info
    if is_pachong
      car_user_info.is_pachong = true
      car_user_info.save!
    end

    if car_user_info.site_name == '58'
      invert_wuba_city = UserSystem::CarUserInfo::WUBA_CITY.invert
      sx = invert_wuba_city[car_user_info.city_chinese]
      zhengze = "http://#{sx}.58.com"
      url_sx = car_user_info.detail_url.match Regexp.new zhengze
      unless url_sx
        car_user_info.is_cheshang = 2
        car_user_info.is_city_match = false
        car_user_info.save!
      end
    end

    unless car_user_info.phone.blank?
      phone_number_one_month = UserSystem::CarUserInfo.where("phone = ? and created_at > ? and tt_id is not null", car_user_info.phone, (Time.now.months_ago 1).chinese_format).count
      car_user_info.is_repeat_one_month = phone_number_one_month > 1
      car_user_info.save!
    end


    pp "准备更新品牌#{car_user_info.phone}~~#{car_user_info.name}"
    begin
      car_user_info.update_brand
    rescue Exception => e
      car_user_info.destroy
      pp '更新品牌失败，已删除'
      return
    end
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"
    UploadTianTian.upload_one_tt car_user_info

    if car_user_info.is_pachong == false and UserSystem::ChezhibaoCarUserInfo::CITY_HASH.keys.include?(car_user_info.city_chinese)
      begin
        #数据回传到车置宝
        UserSystem::ChezhibaoCarUserInfo.create_czb_car_info name: car_user_info.name,
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
                                                             czb_upload_status: '未上传',
                                                             cx: car_user_info.cx,
                                                             site_name: car_user_info.site_name
      rescue Exception => e
        pp '更新车置宝异常'
        pp e
      end

    end


  end


  def self.run_che168 sub_city_party = 0
    [1..1000].each do |i|
      begin
        Che168.get_car_user_list sub_city_party
      rescue Exception => e
        pp e
      end
      pp '168再来一遍。。。'
      pp "168现在时间 #{Time.now.chinese_format}"
    end



    # begin
    #   # Che168.update_detail
    # rescue Exception => e
    #   pp e
    # end
  end

  def self.run_taoche
    begin
      TaoChe.get_car_user_list
    rescue Exception => e
      pp e
    end

    begin
      TaoChe.update_detail
    rescue Exception => e
      pp e
    end
  end

  def self.run_58 sub_city_party = 0
    [1..1000].each do |i|
      begin
        Wuba.get_car_user_list 20,sub_city_party
      rescue Exception => e
        pp e
      end

      begin
        #Wuba.update_detail
      rescue Exception => e
        pp e
      end
      pp '58再来一遍。。。'
      pp "58现在时间 #{Time.now.chinese_format}"
    end
  end

  def self.run_ganji party = 0
    [1..1000].each do |i|
      begin
        Ganji.get_car_user_list party
      rescue Exception => e
        pp e
      end

      begin
        # Ganji.update_detail
      rescue Exception => e
        pp e
      end
      pp '赶集再来一遍。。。'
      pp "现在赶集时间 #{Time.now.chinese_format}"
    end
  end

  def self.run_baixing
    begin
      Baixing.get_car_user_list
    rescue Exception => e
      pp e
    end

    begin
      Baixing.update_detail
    rescue Exception => e
      pp e
    end
  end


  #UserSystem::CarUserInfo.run_men true
  def self.run_men run_list = true

    if run_list
      begin
        Che168.get_car_user_list
      rescue Exception => e
        pp e
      end
    end

    begin
      Che168.update_detail
    rescue Exception => e
      pp e
    end

    if run_list
      begin
        TaoChe.get_car_user_list
      rescue Exception => e
        pp e
      end
    end
    pp '.........淘车列表跑完'


    begin
      TaoChe.update_detail
    rescue Exception => e
      pp e
    end
    pp '.........淘车明细更新完成'

    # begin
    #   UserSystem::CarUserInfo.update_all_brand
    #   pp '更新品牌结束'
    # rescue Exception => e
    #   pp e
    # end

    begin
      UploadTianTian.upload_tt
    rescue Exception => e
      pp e
    end
    #
    #
    # begin
    #   UserSystem::CarUserInfo.send_email
    #   pp Time.now.chinese_format
    # rescue Exception => e
    #   pp e
    # end
  end


  #获取20个城市的代码及名称, 针对che168网站
  # UserSystem::CarUserInfo.get_city_code_name
  def self.get_city_code_name
    provinces = {"440000" => "广东", "370000" => "山东", "330000" => "浙江", "320000" => "江苏", "130000" => "河北", "410000" => "河南", "110000" => "北京", "210000" => "辽宁", "310000" => "上海", "500000" => "重庆", "350000" => "福建", "450000" => "广西", "520000" => "贵州", "620000" => "甘肃", "460000" => "海南", "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林", "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川", "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南", "34000" => "安徽"}
    city_hash = {}
    provinces.each_pair do |key, v|
      city_content = RestClient.get("http://m.che168.com/Handler/GetArea.ashx?pid=#{key}")
      pp 'xxx'
      city_content = JSON.parse city_content.body

      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if ::UserSystem::CarUserInfo::ALL_CITY.values.include? areaname
          city_hash[areaid] = areaname
        end
      end
    end
  end


  # 生成每小时xls
  def self.generate_xls_of_car_user_info car_user_infos
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
    sheet1 = book.create_worksheet name: '车主信息数据'
    ['姓名', '电话', '车型', '车龄', '价格', '城市', '备注', '里程', '发布时间', '保存时间', '数据来源', '导入状态', '渠道'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    current_row = 1
    car_user_infos.each do |car_user_info|
      upload_zhuangtai = case car_user_info.upload_status
                           when 'success'
                             '成功'
                           when 'yicunzai'
                             if car_user_info.bookid.blank?
                               '已存在'
                             else
                               '成功'
                             end
                           when 'shibai'
                             "失败--#{car_user_info.shibaiyuanyin}"
                           else
                             '不导入'
                         end

      [car_user_info.name, car_user_info.phone, car_user_info.che_xing, ("#{(Time.now.year-car_user_info.che_ling.to_i) rescue ''}年"), car_user_info.price, car_user_info.city_chinese, car_user_info.note, "#{car_user_info.milage}万公里", car_user_info.fabushijian, (car_user_info.created_at.chinese_format rescue ''), car_user_info.site_name, upload_zhuangtai, car_user_info.channel].each_with_index do |content, i|
        sheet1.row(current_row)[i] = content
      end
      current_row += 1
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车主信息数据.xls")
    book.write file_path
    file_path
  end

  # class UserSystem::CarUserInfo < ActiveRecord::Base
  def self.update_all_brand
    # cui = UserSystem::CarUserInfo.where("brand is not null").order(id: :desc).first
    # cuis = UserSystem::CarUserInfo.where("id > #{cui.id} and brand is  null and phone is not null")
    cuis = UserSystem::CarUserInfo.where("id > 172006 and brand is  null and phone is not null")
    cuis.each_with_index do |cui, i|
      begin
        cui.update_brand
      rescue Exception
        cui.update_brand
      end
      pp "完成 #{i}/#{cuis.length}"
    end
  end

  # end

  def update_brand
    return unless self.brand.blank?

    UserSystem::CarType.all.each do |t|
      if self.che_xing.match Regexp.new(t.name)
        self.brand = t.car_brand.name
        self.cx = t.name
        self.save!
        break
      end
    end

    return unless self.brand.blank?

    UserSystem::CarBrand.all.each do |brand|
      if self.che_xing.match Regexp.new(brand.name)
        self.brand = brand.name
        self.save!
        break
      end
    end

  end

  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 为开新临时导出上海的成功数据，导前一天的数据, 邮件给KK， OO 和我。  业务现已停止
  # UserSystem::CarUserInfo.get_kaixin_info
  def self.get_kaixin_info
    cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = '上海' and tt_yaoyue = '成功' and tt_yaoyue_day = ? and tt_chengjiao is null", Date.today)
    return if cuis.length == 0
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
    sheet1 = book.create_worksheet name: '车主信息数据'
    ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    current_row = 1
    i = 0
    cuis.each do |car_user_info|
      [car_user_info.name, car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
        sheet1.row(current_row)[i] = content
      end
      i = i+1
      current_row += 1
      car_user_info.tt_chengjiao = 'kaixin'
      car_user_info.save!
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}上海信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
                                 '13472446647@163.com',
                                 i,
                                 "最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出数据给车王。
  # 现在只要天津和上海数据。每天下午3点定时导出前一天下午3点到今天下午3点的数据。
  # UserSystem::CarUserInfo.get_info_to_chewang
  def self.get_info_to_chewang

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    record_number = 0
    ['天津', '上海'].each do |city|
      sheet1 = book.create_worksheet name: "#{city}数据"
      ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      row = 0
      cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and milage < 9 and  tt_upload_status = '已上传' and tt_code in (0,1) and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 15:00:00", "#{Date.today.chinese_format_day} 15:00:00")
      cuis.each_with_index do |car_user_info, current_row|
        next if car_user_info.is_repeat_one_month

        if car_user_info.city_chinese == '上海'
          unless ['别克', '福特', 'MG', '荣威', '雪佛兰'].include? car_user_info.brand
            next
          end
        end

        record_number = record_number+1
        row = row+1
        [car_user_info.name.gsub('(个人)', ''), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|

          sheet1.row(row)[i] = content

        end

      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车王信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
                                 '13472446647@163.com',
                                 record_number,
                                 "车王最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出北京数据
  # UserSystem::CarUserInfo.get_info_to_chewang
  def self.get_info_to_youche

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    phones = []
    record_number = 0
    ['北京', '天津'].each do |city|
      sheet1 = book.create_worksheet name: "#{city}数据"
      ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      row = 0
      cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 18:00:00", "#{Date.today.chinese_format_day} 18:00:00")
      cuis.each_with_index do |car_user_info, current_row|
        # car_user_info.name = car_user_info.name.gsub('联系TA','先生女士')
        # car_user_info.save!


        cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
        unless cbui.blank?
          next
        end

        next if car_user_info.phone.blank?
        next if car_user_info.name.blank?
        next if car_user_info.brand.blank?

        next if phones.include? car_user_info.phone
        phones << car_user_info.phone

        record_number = record_number+1
        row = row+1
        [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|

          sheet1.row(row)[i] = content

        end

      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}UC信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('13472446647@163.com',
                                 '',
                                 record_number,
                                 "UC最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end

  def self.phone_city

    UserSystem::CarUserInfo.where("phone_city is null and id > 500000 and phone is not null").order(id: :desc).find_each do |cui|
      begin
        next unless cui.phone_city.blank?
        response = RestClient.get "http://virtual.paipai.com/extinfo/GetMobileProductInfo?mobile=#{cui.phone}&amount=10000&callname=getPhoneNumInfoExtCallback"
        ec = Encoding::Converter.new("gb18030", "UTF-8")
        response = ec.convert response
        matchs = response.match /cityname:'(.*)'/
        cityname = matchs[1].to_s
        next if cityname.blank?
        cui.phone_city = cityname
        cui.save!
      rescue Exception => e
      end
    end


    ts = []
    phones.each do |phone|
      begin
        response = RestClient.get "http://life.tenpay.com/cgi-bin/mobile/MobileQueryAttribution.cgi?chgmobile=#{phone}"

        ec = Encoding::Converter.new("gb18030", "UTF-8")
        response = ec.convert response
        pp response
        matchs = response.match /<city>(.*)<\/city>/
        cityname = matchs[1].to_s
        ts << cityname
      rescue
        next
      end
    end


    month_ago = Time.now - 3.days
    h = {}
    while true do
      n = UserSystem::CarUserInfo.where("created_at > ? and site_name = '58' and created_at < ? and site_name = '58' and city_chinese in ('上海', '成都', '深圳', '南京', '广州', '武汉', '天津', '苏州', '杭州', '东莞', '重庆')", "#{month_ago.chinese_format_day} #{month_ago.hour}:00:00", "#{month_ago.chinese_format_day} #{month_ago.hour}:59:59").count
      if h[month_ago.hour].blank?
        h[month_ago.hour] = []
      end
      h[month_ago.hour] << n
      month_ago = month_ago + 1.hour
      break if Time.now < month_ago
    end

    h_new = {}
    h.each_pair do |k, v|
      h_new[k] = (v.sum.to_f / v.length).to_i
    end


    h = {}
    days = ['2016-03-28', '2016-03-29', '2016-04-11', '2016-04-12', '2016-04-15']
    a = ""
    (10..22).each do |hour|
      days.each do |day|
        n = UserSystem::CarUserInfo.where("created_at > ? and site_name = '58' and created_at < ? and site_name = '58' and city_chinese in ('上海', '成都', '深圳', '南京', '广州', '武汉', '天津', '苏州', '杭州', '东莞', '重庆')", "#{day} #{hour}:00:00", "#{day} #{hour}:59:59").count
        h["#{day} #{hour}"] = n
        a = "#{a} #{"#{day} #{hour}点"} #{n}"
      end

      a = "#{a}
      "

    end


    # hours = c(15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
    # numb = c(112, 113, 109, 92, 87, 82, 80, 69, 53, 35, 18, 10, 6, 4, 4, 9, 19, 42, 81, 108, 122, 92, 113, 109)

    # hours = c(15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
    # numb = c(101, 92, 97, 75, 70, 76, 62, 63, 47, 40, 18, 13, 7, 7, 5, 9, 17, 44, 77, 106, 113, 85, 106, 93)

  end


end
__END__
***********备份的代码*******************

      unless car_user_info.note.blank?
        ["诚信", '到店', '精品车', '本公司', '五菱', '提档', '双保险', '可按揭', '该车为', '铲车', '首付', '全顺', '该车', '按揭', '热线', '依维柯'].each do |word|
          if car_user_info.note.include? word
            is_next = true
          end
        end
      end

      ["0000", "1111", "2222", "3333", "4444", "5555", "6666", "7777", "8888", "9999"].each do |p|
        if car_user_info.phone.include? p
          is_next = true
        end
      end

      ['经理', '总'].each do |name_key|
        is_next = true if car_user_info.name.include? name_key
      end



response = RestClient.get 'http://virtual.paipai.com/extinfo/GetMobileProductInfo?mobile=13472446647&amount=10000&callname=getPhoneNumInfoExtCallback'
ec = Encoding::Converter.new("gb18030", "UTF-8")
response = ec.convert response
matchs = response.match /cityname:'(.*)'/
cityname = matchs[1].to_s