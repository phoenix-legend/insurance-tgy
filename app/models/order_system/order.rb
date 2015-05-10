class OrderSystem::Order < ActiveRecord::Base
  belongs_to :product, :class_name => '::OrderSystem::Product'
  belongs_to :user_info, :class_name => '::UserSystem::UserInfo'


  def self.create_order options
      options = get_arguments_options options, [:product_id, :user_info_id, :status], status: 1
      order = self.new options
      order.save!
      order.reload
      order
  end

end