class UserSystem::AishiCarUserInfo < ActiveRecord::Base
  #改为优信业务
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'
  CITY = []

  # 创建车主信息
  # 初始信息为: phone , name , city_chinese, brand, chexi, 是否车商,  是否爬虫, 是否需上传=>yes,
  #
  def self.create_car_info options
    cui = UserSystem::AishiCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::AishiCarUserInfo.upload_to_aishi cui
  end



  #使用日期+是否需上传两个条件,进行上传数据
  def self.batch_upload_to_youxin

  end
end
