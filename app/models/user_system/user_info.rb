class UserSystem::UserInfo < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'

end