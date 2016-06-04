class UserSystem::AishiCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'


  CITY = ['天津', '苏州']
  # CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "东莞", "重庆"]

  # 上传到埃侍
  # UserSystem::AishiCarUserInfo.upload_to_aishi ycui
  def self.upload_to_aishi ycui
    return unless ycui.site_name == 'ganji'
    ycui.name = ycui.name.gsub('(个人)', '')
    ycui.name = ycui.name.gsub('个人', '')
    ycui.name = ycui.name.gsub('(', '')
    ycui.name = ycui.name.gsub(')', '')
    ycui.save!


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

    return if ycui.phone.blank?
    return if ycui.aishi_upload_status != '未上传'
    return if ycui.name.blank?


     key = "033bd94b1168d7e4f0d644c3c95e35bf" #测试
    number = "4S-10009" #测试

    # key = "5c7a8fe495a35f24f6674ac80c9843d8" #正式
    # number = "4SA-1001" #正式
    require 'digest/md5'

    response = RestClient.post "http://api.test.4scenter.com/index.php?r=apicar/signup", {mobile: ycui.phone,
                                                                                          name: ycui.name.gsub('(个人)', ''),
                                                                                          city: "#{ycui.city_chinese}市",
                                                                                          brand: ycui.brand,
                                                                                          number: number,
                                                                                          sign: Digest::MD5.hexdigest("#{number}#{key}")
                                                                                       }
    response = JSON.parse response.body
    pp response
    ycui.aishi_upload_status = '已上传'
    ycui.aishi_upload_message = response["message"]
    if response["error"] == false
      ycui.aishi_id = response["result"]["id"]
    end
    ycui.save!
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

  # 创建车主信息
  def self.create_car_info options
    cui = UserSystem::AishiCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!
    # UserSystem::AishiCarUserInfo.upload_aishi cui
  end


end
__END__
