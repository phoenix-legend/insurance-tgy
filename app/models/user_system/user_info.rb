require "spreadsheet"
class UserSystem::UserInfo < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'

  validates_presence_of :car_number, message: "车牌号不可以为空。"
  validates_presence_of :phone, message: "手机号不可以为空。"

  validates_uniqueness_of :car_number, scope: :phone, message: "该车牌号已经存在。"
  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: false
  validates_format_of :car_number, :with => Tools::RegularConstants::CarNumber, message: '车牌号格式不正确', allow_blank: false

  CITY = ["北京市","天津市","上海市","重庆市","河北省","河南省","云南省","辽宁省","黑龙江省","湖南省","安徽省","山东省",
  "新疆维吾尔","江苏省","浙江省","江西省","湖北省","广西壮族","甘肃省","山西省","内蒙古","陕西省","吉林省","福建省",
  "贵州省","广东省","青海省","西藏","四川省","宁夏回族","海南省","台湾省","香港特别行政区","澳门特别行政区"]

  def self.update_user_by_xieche userid
    user = UserSystem::UserInfo.find_by_id userid
    BusinessException.raise '用户不存在' if user.blank?
    product = ::OrderSystem::Product.find_by_server_name 'xieche'
    orders = ::OrderSystem::Order.where product_id: product.id, user_info_id: userid, status: 0
    BusinessException.raise '订单不存在' if orders.blank?
    order = orders[0]
    order.status=1
    order.save!
  end

  # 点击“免费预约“将用户信息保存到数据库中，同时生成订单。
  # 将信息提交到合作伙伴网址。同时在数据库中记录是否提交成功。
  def self.create_user_info options
    product_id = options[:product_id]
    BusinessException.raise '产品ID不存在' if product_id.blank?
    options = get_arguments_options options, [:name, :phone, :channel, :car_number, :car_price, :city]
    exist_user_info = self.where(car_number: options[:car_number], phone: options[:phone]).first
    user_info = nil
    if exist_user_info.blank?
      # 保存用户信息
      user_info = self.new options
      user_info.save!
      user_info.reload
    else
      # 根据车牌号查找，user_info已经存在，则更新
      exist_user_info.channel = options[:channel] unless options[:channel].blank?
      exist_user_info.car_price = options[:car_price] unless options[:car_price].blank?
      exist_user_info.city = options[:city] unless options[:city].blank?
      exist_user_info.save!
      exist_user_info.reload
      user_info = exist_user_info
    end
    # 创建订单
    ::OrderSystem::Order.create_order user_info_id: user_info.id, product_id: product_id
    user_info
  end

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
      0.upto(6).each do |j|
        sheet1.row(current_row).set_format(j, in_left)
      end
      current_row += 1
    end
    file_path = "保盒用户资料表.xls"
    book.write file_path
    file_path
  end

end