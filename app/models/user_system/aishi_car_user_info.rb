class UserSystem::AishiCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'


  CITY = ['天津', '苏州', "上海", "成都", "深圳", "南京", "广州", "杭州", "东莞", "佛山", '武汉', '重庆']
  # CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "东莞", "重庆"]

  # 上传到埃侍
  # UserSystem::AishiCarUserInfo.upload_to_aishi ycui
  def self.upload_to_aishi ycui
    sleep 2
    # return unless ycui.site_name == 'ganji'
    ycui.name = ycui.name.gsub('(个人)', '')
    ycui.name = ycui.name.gsub('个人', '')
    ycui.name = ycui.name.gsub('(', '')
    ycui.name = ycui.name.gsub(')', '')
    ycui.save!


    if ycui.phone.blank? or ycui.brand.blank?
      ycui.aishi_upload_status = '信息不完整'
      ycui.save!
      return
    end

    if not CITY.include? ycui.city_chinese
      pp '城市不对'
      ycui.aishi_upload_status = '城市不对'
      ycui.save!
      return
    end

    if ycui.is_real_cheshang
      pp '车商'
      ycui.aishi_upload_status = '车商'
      ycui.save!
      return
    end

    if ycui.is_pachong
      pp '爬虫'
      ycui.aishi_upload_status = '爬虫'
      ycui.save!
      return
    end

    if not ycui.is_city_match
      pp '城市不匹配'
      ycui.aishi_upload_status = '城市不匹配'
      ycui.save!
      return
    end

    return if ycui.phone.blank?
    return if ycui.aishi_upload_status != '未上传'
    return if ycui.name.blank?


    # key = "033bd94b1168d7e4f0d644c3c95e35bf" #测试
    # number = "4S-10009" #测试

    # key = "5c7a8fe495a35f24f6674ac80c9843d8" #正式
    # number = "4SA-1001" #正式

    key = "098f6bcd4621d373cade4e832627b4f6" #正式
    number = "4SA-1011" #正式

    require 'digest/md5'

    response = RestClient.post "http://api.formal.4scenter.com/index.php?r=apicar/signup", {mobile: ycui.phone,
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
    if response["error"] == "false"
      ycui.aishi_id = response["result"]["id"]
    end
    ycui.save!
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
        pp '更新4A异常'
        pp e
      end
    end
  end

  # 创建车主信息
  def self.create_car_info options
    cui = UserSystem::AishiCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    # cui = UserSystem::AishiCarUserInfo.find_by_phone options[:phone]
    # return unless cui.blank?

    cui = UserSystem::AishiCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::AishiCarUserInfo.upload_to_aishi cui

  end


  # UserSystem::AishiCarUserInfo.query_aishi
  def self.query_aishi
    return unless (Time.now.hour == 18 or Time.now.hour == 20)
    return unless Time.now.min > 40

    key = "098f6bcd4621d373cade4e832627b4f6" #正式
    number = "4SA-1011" #正式
    UserSystem::AishiCarUserInfo.where("aishi_id is not null and aishi_yaoyue is null").all.each do |cui|
      response = RestClient.post 'http://api.formal.4scenter.com/index.php?r=apicar/querysignupone', {number: number,
                                                                                                      sign: Digest::MD5.hexdigest("#{number}#{key}"),
                                                                                                      id: cui.aishi_id
                                                                                                   }
      response = JSON.parse response.body
      result = if ['创建失败', '邀约失败'].include? response["result"]["status"]
                 '失败'
               elsif ['检测成功', '检测失败', '竞拍成功', '竞拍失败', '成交成功', '成交失败', '邀约成功'].include? response["result"]["status"]
                 '成功'
               else
                 nil
               end
      next if result.blank?

      business_name = begin
        response["result"]["log"][0]["name"] rescue ''
      end
      upload_message = begin
        response["result"]["log"][0]["msg"] rescue ''
      end


      cui.aishi_yaoyue = result
      cui.aishi_upload_message = upload_message
      cui.business_name = business_name

      cui.aishi_yaoyue_time = Time.now.chinese_format
      cui.aishi_yaoyue_day = Time.now.chinese_format_day
      cui.save!
      pp "4A ID 为：#{cui.aishi_id}"
      pp response
    end

  end


end
__END__
