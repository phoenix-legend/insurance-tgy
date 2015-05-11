class OrderSystem::Product < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'

end