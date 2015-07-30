require "spreadsheet"
class UserSystem::UserInfo < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'
  has_many :weizhang_results, :class_name => '::OrderSystem::WeizhangResult'
  has_many :weizhang_logs, :class_name => 'OrderSystem::WeizhangLog'


  validates_presence_of :phone, message: "手机号不可以为空。"
  validates_uniqueness_of :car_number, scope: :phone, message: "该车牌号已经存在。"
  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: false
  validates_format_of :car_number, :with => Tools::RegularConstants::CarNumber, message: '车牌号格式不正确', allow_blank: true
  validates_format_of :vin_no, :with => EricTools::RegularConstants::VinNo, message: '车架号不正确', allow_blank: true
  validates_format_of :engine_no, :with => EricTools::RegularConstants::EngineNo, message: '发动机号不正确', allow_blank: true

  #获取携车网所需要的参数。
  def get_xieche_param
    {
        "mobile" => self.phone,
        "licenseplate_type" => self.car_number[0],
        "licenseplate" => self.car_number[1..-1],
        "pingan_id" => self.id
    }.to_json
  end

  #更新携车网的数据接口。
  def self.update_user_by_xieche userid
    UserSystem::UserInfo.transaction do
      user = UserSystem::UserInfo.find_by_id userid
      BusinessException.raise '用户不存在' if user.blank?
      product = ::OrderSystem::Product.find_by_server_name 'xieche'
      orders = ::OrderSystem::Order.where product_id: product.id, user_info_id: userid, status: 0
      BusinessException.raise '订单不存在' if orders.blank?
      order = orders[0]
      order.status=1
      order.save!
    end
  end

  # UserSystem::UserInfo.yiwaixianjiekou({"realname"=>'刘晓琦', "gender" => "M", "birth" => '1984-01-01', "mobile"  => '13444444444', "product" => 'WYCX', "city" => '上海'})

  def self.yiwaixianjiekou options
    require 'digest'
    url = "http://apis.zonghengche.com/life/query"
    options = get_arguments_options options, [:realname, :gender,
                                              :birth, :mobile, :product, :parentname, :city,
                                              :idcard, :carmodel, :remark, :answer1, :answer2, :answer3]
    options.merge! media: '017792',
                   appid: 'baohe',
                   sign: Digest::MD5.hexdigest("#{options[:birth]}#{options[:mobile]}f4d7f0a85c4cea2360aa0d71ecd90862")
    options1 = {}
    ec = Encoding::Converter.new("UTF-8", "GB2312")
    options.each do |k, v|
      options1[k] = ec.convert(v)
    end
    # pp options1
    response = RestClient.post(url, options1)


    ce = Encoding::Converter.new("GB2312", "UTF-8")
    body = ce.convert(response.body)
    JSON.parse body


    # require 'spreadsheet/excel'
    # book = Spreadsheet::Parseexcel.parse("/Users/ericliu/work/projects/github/insurance-tgy-doc/a.xls")
    # sheet = book.worksheet 0
  end

  # 点击“免费预约“将用户信息保存到数据库中，同时生成订单。
  # 将信息提交到合作伙伴网址。同时在数据库中记录是否提交成功。
  def self.create_user_info options
    UserSystem::UserInfo.transaction do
      product_id = options[:product_id]
      BusinessException.raise '产品ID不存在' if product_id.blank?
      options = get_arguments_options options, [:gender, :birthday, :engine_no, :vin_no, :month, :name, :phone, :channel, :car_number, :car_price, :city]
      BusinessException.raise '车牌号不能为空' if options[:car_number].blank?


      # 如果是查询违章，无车架号和发动机号不能查询。
      product = ::OrderSystem::Product.find product_id

      if product.server_name == 'yiwaixian'
        BusinessException.raise '请填写姓名' if options[:name].blank?
        BusinessException.raise '请选择性别' if options[:gender].blank?
        BusinessException.raise '请填写生日' if options[:birthday].blank?
      end


      if product.server_name == 'weizhang'
        BusinessException.raise '发动机号填写错误' if options[:engine_no].blank?
        BusinessException.raise '车架号填写错误' if options[:vin_no].blank?
      end

      exist_user_info = self.where(car_number: options[:car_number], phone: options[:phone]).first

      options[:template_name] = Thread.current[:template_name]
      options[:qudao_name] = Thread.current[:qudao_name]
      options[:ip] = Thread.current[:ip]

      user_info = if exist_user_info.blank?
                    # 保存用户信息
                    user_info = self.new options
                    user_info.save!
                    user_info
                  else
                    # 根据车牌号查找，user_info已经存在，则更新
                    options.delete_if { |k, v| v.blank? }
                    exist_user_info.update_attributes! options
                    exist_user_info
                  end
      # 创建订单
      ::OrderSystem::Order.create_order user_info_id: user_info.id, product_id: product_id
      user_info
    end
  end

  #导出用户数据，生成表格。
  def self.export_excel users
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    in_left = Spreadsheet::Format.new horizontal_align: :left, border: :thin
    sheet1 = book.create_worksheet name: '用户资料表'

    sheet1.row(0)[0] = "名字"
    sheet1.row(0)[1] = "手机号"
    sheet1.row(0)[2] = "渠道"
    sheet1.row(0)[3] = "车牌号"
    sheet1.row(0)[4] = "车价"
    sheet1.row(0)[5] = "所在城市"
    sheet1.row(0)[6] = "IP"
    sheet1.row(0)[7] = "发动机号"
    sheet1.row(0)[8] = "车架号"

    0.upto(6).each do |i|
      sheet1.row(0).set_format(i, in_center)
    end

    current_row = 1
    users.each do |user|
      sheet1.row(current_row)[0] = user.name
      sheet1.row(current_row)[1] = user.phone
      sheet1.row(current_row)[2] = user.channel
      sheet1.row(current_row)[3] = user.car_number
      sheet1.row(current_row)[4] = user.car_price.to_s + "万元"
      sheet1.row(current_row)[5] = user.city
      sheet1.row(current_row)[6] = user.ip
      sheet1.row(current_row)[7] = user.engine_no
      sheet1.row(current_row)[8] = user.vin_no

      0.upto(8).each do |j|
        sheet1.row(current_row).set_format(j, in_left)
      end
      current_row += 1
    end
    file_path = "保盒用户资料表-#{Time.now.chinese_format}.xls"
    book.write file_path
    file_path
  end


  def self.a

    string = <<EOF
凯凯%2012-09-14%男%王俊杰%山东%烟台%15615657978
EOF

    as = string.split("\n")

    as = as.collect { |a| a.split('%') }

    as.each do |bs|
      name = bs[0]
      birthdy = bs[1]
      gender = bs[2]
      jiazhang = bs[3]
      city = bs[5]
      phone = bs[6]

      puts name
      begin
        puts UserSystem::UserInfo.yiwaixianjiekou({"realname" => name,
                                                   "gender" => gender=='男' ? 'M' : 'F',
                                                   "birth" => birthdy,
                                                   "mobile" => phone,
                                                   "product" => 'SEWYCX',
                                                   "city" => city,
                                                   "parentname" => jiazhang})
      rescue Exception => e
        puts '错了'
      end
    end
  end

  def self.x



    content = `curl -c stored_cookies_in_file http://www.pahaoche.com/yuyue_140807a.w?ch=yy-huayang-141219-012`
    detail_content = Nokogiri::HTML(content)
    value = detail_content.css('#checkCode').attributes["src"].value

    session_key = "#{Time.now.to_i}#{rand(10000000)}"
    url = "http://gw2.pahaoche.com/wghttp/randomImageServlet?Rand=4&sessionKey=#{session_key}"



    a = {
        "authCode" => "abc",
        "channel" => "yy-huayang-141219-012",
        "city" => "南京",
        "expectTime" => "计划卖车时间:一周内.",
        "from" => "GW",
        "mobile" => "18652011717",
        "name" => "柏先生(江苏-个人)",
        "tokenKey" => "CD6773E1-C698-4757-87C7-3F2E5C24DAEE",
        "tokenValue" => "512017b9-61cb-477b-919b-89c2b4d36ec5",
        "vehicleType" => "甲壳虫 2014款 1.2TSI 时尚型",
        "yuyueId" => "5d8df285-15f3-470a-9875-32e5e9cba76b"
    }
    response = RestClient.post 'http://www.pahaoche.com/yuyueZt.w', a
    pp response.body






    session_key = "#{Time.now.to_i}#{rand(10000000)}"
    url = "http://gw2.pahaoche.com/wghttp/randomImageServlet?Rand=4&sessionKey=#{session_key}"
    response = RestClient.get url
    file = File.new("#{Rails.root}/public/downloads/#{session_key}.jpg",'wb')
    file.write response.body
    file.flush
    file.close
    file_name = file.path
    code = `tesseract #{file_name} stdout --tessdata-dir /Applications/OCRTOOLS.app/Contents/Resources/tessdata`
    code = code.strip
    code



    url = "http://gw2.pahaoche.com/wghttp/internal/booking?sessionKey=#{session_key}&jsonpCallback=jQuery18305799584991588008_1438219790186&yuyueId=&channel=yy-huayang-141219-012&from=GW&tokenKey=8891E237-C4DB-4B79-A7A2-77DBB50D0772&tokenValue=3b783617-8bf6-4f03-ab11-7c6f46054af2&expectTime=%E8%AE%A1%E5%88%92%E5%8D%96%E8%BD%A6%E6%97%B6%E9%97%B4%3A%E4%B8%80%E5%91%A8%E5%86%85.&name=%E5%BC%A0%E4%B8%89&mobile=13472446647&city=%E5%8D%97%E4%BA%AC&vehicleType=%E7%94%B2%E5%A3%B3%E8%99%AB+2014%E6%AC%BE+1.2TSI+%E6%97%B6%E5%B0%9A%E5%9E%8B&authCode=#{code}&_=14382212161096570"

    response = RestClient.get url

    pp response.body

    # export TESSDATA_PREFIX=/Applications/OCRTOOLS.app/Contents/Resources/tessdata
    #                        /Applications/OCRTOOLS.app/Contents/Resources/tessdata/eng.traineddata
    # tesseract ~/tmp/tesser/randomImageServlet.jpg stdout
  end

end