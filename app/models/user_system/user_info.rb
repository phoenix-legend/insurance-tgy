class UserSystem::UserInfo < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'

  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: false
  validates_format_of :car_number, :with => Tools::RegularConstants::CarNumber, message: '车牌号格式不正确', allow_blank: false

  def self.create_user_info options
    options = get_arguments_options options, [:name, :phone, :channel, :car_number, :car_price, :city]
    user_info = self.new options
    user_info.save!
    user_info.reload
    user_info
  end
end