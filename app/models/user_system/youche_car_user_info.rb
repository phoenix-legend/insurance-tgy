class UserSystem::YoucheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ['天津', '北京']

  # 创建车置宝车主信息
  def self.create_czb_car_info options

    cui = UserSystem::YoucheCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::YoucheCarUserInfo.new options
    cui.save!


    # UserSystem::YoucheCarUserInfo.upload_youche cui
  end



  def self.upload_youche yc_car_user_info

    if yc_car_user_info.phone.blank? or yc_car_user_info.brand.blank?
      yc_car_user_info.yc_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    # if ['58','ganji','che168'].include? yc_car_user_info.site_name
    #   yc_car_user_info.yc_upload_status = '先不进58，赶集,168'
    #   yc_car_user_info.save!
    #   return
    # end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.yc_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.yc_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.yc_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.yc_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end

  end

end
__END__
