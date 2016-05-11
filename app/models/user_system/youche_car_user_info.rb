class UserSystem::YoucheCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  CITY = ['天津']

  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and UserSystem::YoucheCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        #数据回传到优车
        UserSystem::YoucheCarUserInfo.create_car_info name: car_user_info.name,
                                                      phone: car_user_info.phone,
                                                      brand: car_user_info.brand,
                                                      city_chinese: car_user_info.city_chinese,
                                                      che_ling: car_user_info.che_ling,
                                                      car_user_info_id: car_user_info.id,
                                                      milage: car_user_info.milage,
                                                      price: car_user_info.price,
                                                      is_real_cheshang: car_user_info.is_real_cheshang,
                                                      is_city_match: car_user_info.is_city_match,
                                                      is_pachong: car_user_info.is_pachong,
                                                      is_repeat_one_month: car_user_info.is_repeat_one_month,
                                                      youche_upload_status: '未上传',
                                                      site_name: car_user_info.site_name,
                                                      created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新优车异常'
        pp e
      end
    end
  end

  # 创建车置宝车主信息
  def self.create_car_info options

    cui = UserSystem::YoucheCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::YoucheCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    # UserSystem::YoucheCarUserInfo.upload_youche cui
  end



  def self.batch_upload_youche
    UserSystem::YoucheCarUserInfo.where("youche_upload_status = '未上传' ").each do |yc_car_user_info|
      upload_youche yc_car_user_info
    end
  end


  def self.upload_youche yc_car_user_info

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    if yc_car_user_info.phone_city.blank?
      phone_city_name = get_city_name yc_car_user_info.phone
      yc_car_user_info.phone_city = phone_city_name
      yc_car_user_info.save!
    end


    if yc_car_user_info.phone.blank? or yc_car_user_info.brand.blank?
      yc_car_user_info.youche_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.youche_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.youche_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.youche_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    if not yc_car_user_info.is_city_match
      pp '城市不匹配'
      yc_car_user_info.youche_upload_status = '城市不匹配'
      yc_car_user_info.save!
      return
    end


    if yc_car_user_info.city_chinese == '北京'
      unless yc_car_user_info.phone_city == '北京'
        yc_car_user_info.youche_upload_status = '北京的外地电话'
        yc_car_user_info.save!
        return
      end
    end
  end

  def self.get_city_name phone
    begin
      response = RestClient.get "http://life.tenpay.com/cgi-bin/mobile/MobileQueryAttribution.cgi?chgmobile=#{phone}"
      ec = Encoding::Converter.new("gb18030", "UTF-8")
      response = ec.convert response
      matchs = response.match /<city>(.*)<\/city>/
      return matchs[1].to_s.strip
    rescue Exception => e
      pp '获取城市出错'
      return ''
    end


  end

end
__END__
