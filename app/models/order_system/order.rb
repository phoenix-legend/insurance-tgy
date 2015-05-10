class OrderSystem::Order < ActiveRecord::Base
  belongs_to :product, :class_name => '::OrderSystem::Product'
  belongs_to :user_info, :class_name => '::UserSystem::UserInfo'

  validates_presence_of :product, message: "产品不存在。"
  validates_presence_of :user_info, message: "客户不存在。"

  def self.create_order options
      options = get_arguments_options options, [:product_id, :user_info_id]
      order = self.new options
      order.save!
      order.reload
      # TODO 将信息提交到合作伙伴网址。同时在数据库中记录是否提交成功

      order
  end

end