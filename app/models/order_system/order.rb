class OrderSystem::Order < ActiveRecord::Base
  belongs_to :product, :class_name => '::OrderSystem::Product'
  belongs_to :user_info, :class_name => '::UserSystem::UserInfo'

end