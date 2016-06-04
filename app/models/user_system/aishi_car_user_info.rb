class UserSystem::AishiCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  # CITY = ['天津', '苏州']
  CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "东莞", "重庆"]

  # 上传到埃侍
  def self.upload_to_aishi
    ycuis = UserSystem::AishiCarUserInfo.where("aishi_upload_status = ? ", '未上传')
    ycuis.each do |ycui|
      is_select = true
      if not ycui.aishi_id.blank?
        return # 如果已经提交，就不再提交
      end

      if ycui.phone.blank?
        ycui.aishi_upload_status = '手机号不存在'
        is_select = false
      end

      if ycui.aishi_upload_status != '未上传'
        is_select = false
      end

      if ycui.is_real_cheshang
        ycui.aishi_upload_status = '疑似车商'
        is_select = false
      end

      if ycui.is_pachong
        ycui.aishi_upload_status = '疑似爬虫'
        is_select = false
      end

      unless ycui.is_city_match
        ycui.aishi_upload_status = '城市不匹配'
        is_select = false
      end

      if ycui.name.blank?
        ycui.aishi_upload_status = '没姓名'
        is_select = false
      end


      unless UserSystem::AishiCarUserInfo::CITY.include? ycui.city_chinese
        ycui.aishi_upload_status = '城市不对'
        is_select = false
      end
      ycui.save!

      if is_select
        response = RestClient.post "http://api.test.4scenter.com/index.php?r=apicar/signup", {owner_phone: ycui.phone,
                                                                                              owner_name: ycui.name.gsub('(个人)', ''),
                                                                                              addr: ycui.city_chinese,
                                                                                              brand: ycui.brand,
                                                                                              token: 'Ap4q0s31p'
                                                                                           }
        response = JSON.parse response.body
        pp response
        ycui.youche_id = response["data"]["id"]
        ycui.youche_upload_status = '已上传'

        ycui.yc_status = response["status_msg"]
        ycui.yc_status_message = response["status_msg"]
        ycui.save!
      end
    end
  end


  # UserSystem::AishiCarUserInfo.query_youche_status
  def self.query_youche_status
    return if Time.now.min > 10
    i = 0
    j = 0
    ycuis = UserSystem::AishiCarUserInfo.where("aishi_id is not null and youche_yaoyue is null ")
    ycuis.each do |ycui|
      response = RestClient.get "http://http.api.youche.com/xuzuo/query_user?id=#{ycui.youche_id}&token=Ap4q0s31p"
      response = JSON.parse response.body
      pp response
      if response["data"]["user_status_msg"] == '有效'
        i += 1
        ycui.youche_yaoyue = '有效'
        ycui.yaoyue_time = Time.now.chinese_format
        ycui.yaoyue_day = Time.now.chinese_format_day
        ycui.save!
      end

      if response["data"]["user_status_msg"] == '无效'
        j += 1
        ycui.youche_yaoyue = '无效'
        ycui.yaoyue_time = Time.now.chinese_format
        ycui.yaoyue_day = Time.now.chinese_format_day
        ycui.save!
      end
    end
  end

  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and UserSystem::AishiCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        #数据回传到优车
        UserSystem::AishiCarUserInfo.create_car_info name: car_user_info.name,
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
                                                     aishi_upload_status: '未上传',
                                                     site_name: car_user_info.site_name,
                                                     created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新优车异常'
        pp e
      end
    end
  end

  # 创建优车车主信息
  def self.create_car_info options
    cui = UserSystem::AishiCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!
    # UserSystem::AishiCarUserInfo.upload_youche cui
  end


  def self.upload_youche sa_car_user_info

    sa_car_user_info.name = sa_car_user_info.name.gsub('(个人)', '')
    sa_car_user_info.save!

    if sa_car_user_info.phone_city.blank?
      phone_city_name = get_city_name sa_car_user_info.phone
      sa_car_user_info.phone_city = phone_city_name
      sa_car_user_info.save!
    end


    if sa_car_user_info.phone.blank? or sa_car_user_info.brand.blank?
      sa_car_user_info.aishi_upload_status = '信息不完整'
      sa_car_user_info.save!
      return
    end

    if not CITY.include? sa_car_user_info.city_chinese
      pp '城市不对'
      sa_car_user_info.aishi_upload_status = '城市不对'
      sa_car_user_info.save!
      return
    end

    if sa_car_user_info.is_real_cheshang
      pp '车商'
      sa_car_user_info.aishi_upload_status = '车商'
      sa_car_user_info.save!
      return
    end

    if sa_car_user_info.is_pachong
      pp '爬虫'
      sa_car_user_info.aishi_upload_status = '爬虫'
      sa_car_user_info.save!
      return
    end

    if not sa_car_user_info.is_city_match
      pp '城市不匹配'
      sa_car_user_info.aishi_upload_status = '城市不匹配'
      sa_car_user_info.save!
      return
    end


    if sa_car_user_info.city_chinese == '北京'
      unless sa_car_user_info.phone_city == '北京'
        sa_car_user_info.aishi_upload_status = '北京的外地电话'
        sa_car_user_info.save!
        return
      end
    end
  end


end
__END__
