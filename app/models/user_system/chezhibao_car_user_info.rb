class UserSystem::ChezhibaoCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'

  # CITY_HASH = {"北京" => 1867, "重庆" => 1898, "青岛" => 1931, "郑州" => 1970, "武汉" => 2002, '长沙' => 2024,
  #              "深圳" => 2053, "南京" => 2072, "无锡" => 2073, "苏州" => 2076, "镇江" => 2082, "成都" => 2102, "杭州" => 2123, "西安" => 2176,
  #              "上海" => 1889, '常州' => 2075}

  CITY_HASH = { "南京" => 2072, "无锡" => 2073, "苏州" => 2076, '常州' => 2075}


  # TestUrl = 'http://open.jzl.mychebao.com/apiService.hs'
  ProcuctionUrl = 'http://open.mychebao.com/apiService.hs'
  # KEY = 'jhsdhsrr'
  # KEY = 'jhcsvtjh'
  KEY = 'pkbfeauv'
  SOURCE = 459
  CLIENT = 'k78242T1'


  def self.create_info_from_car_user_info car_user_info
    if false and car_user_info.is_pachong == false and UserSystem::ChezhibaoCarUserInfo::CITY_HASH.keys.include?(car_user_info.city_chinese)
      begin
        #数据回传到车置宝
        UserSystem::ChezhibaoCarUserInfo.create_czb_car_info name: car_user_info.name,
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
                                                             czb_upload_status: '未上传',
                                                             cx: car_user_info.cx,
                                                             site_name: car_user_info.site_name
      rescue Exception => e
        pp '更新车置宝异常'
        pp e
      end
    end
  end


  # 创建车置宝车主信息
  def self.create_czb_car_info options

    cui = UserSystem::ChezhibaoCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    czb = UserSystem::ChezhibaoCarUserInfo.new options
    czb.save!

    czb.created_day = czb.created_at.chinese_format_day
    czb.save!

    #UserSystem::ChezhibaoCarUserInfo.upload_czb czb
  end

  # 获取所有城市
  def self.get_citys
    response = RestClient.post ProcuctionUrl, {service: 'unify.data.load.city',
                                               client: CLIENT}
    response = JSON.parse response
  end

  def self.upload_all_zhb
    cuis = UserSystem::ChezhibaoCarUserInfo.where("czb_upload_status  in ('非法请求', '未上传')")
    cuis.each do |c|
      UserSystem::ChezhibaoCarUserInfo.upload_czb c
    end
  end


  def self.upload_czb czb_car_user_info


    if czb_car_user_info.phone.blank? or czb_car_user_info.brand.blank?
      czb_car_user_info.czb_upload_status = '信息不完整'
      czb_car_user_info.save!
      return
    end

    if ['58','ganji','che168'].include? czb_car_user_info.site_name
      czb_car_user_info.czb_upload_status = '先不进58，赶集,168'
      czb_car_user_info.save!
      return
    end

    if not CITY_HASH.keys.include? czb_car_user_info.city_chinese
      pp '城市不对'
      czb_car_user_info.czb_upload_status = '城市不对'
      czb_car_user_info.save!
      return
    end

    if czb_car_user_info.is_real_cheshang
      pp '车商'
      czb_car_user_info.czb_upload_status = '车商'
      czb_car_user_info.save!
      return
    end

    if czb_car_user_info.is_pachong
      pp '爬虫'
      czb_car_user_info.czb_upload_status = '爬虫'
      czb_car_user_info.save!
      return
    end

    if not czb_car_user_info.is_city_match
      pp '城市不匹配'
      czb_car_user_info.czb_upload_status = '城市不匹配'
      czb_car_user_info.save!
      return
    end


    require 'digest/md5'
    encrypt_phone = encrypt czb_car_user_info.phone

    cx = czb_car_user_info.cx
    cx = czb_car_user_info.brand if cx.blank?
    cityid = CITY_HASH[czb_car_user_info.city_chinese]
    before_md5 = "phone=#{encrypt_phone}&brand=#{czb_car_user_info.brand}&model=#{cx}&city=#{cityid}&source=#{SOURCE}&key=#{KEY}"
    pp "签名前: #{before_md5}"
    after_md5 = Digest::MD5.hexdigest(before_md5)
    pp "签名后: #{after_md5.upcase}"
    response = RestClient.post ProcuctionUrl, {
                                                service: 'unify.data.push.car',
                                                client: CLIENT,
                                                phone: encrypt_phone,
                                                brand: czb_car_user_info.brand,
                                                model: cx,
                                                type: '',
                                                city: cityid,
                                                source: SOURCE,
                                                datasign: after_md5.upcase
                                            }
    response = JSON.parse response
    if response["resultCode"] == 1
      czb_car_user_info.czb_upload_status = '上传成功'
      czb_car_user_info.czb_id = response["carId"]
      czb_car_user_info.save!
    else
      czb_car_user_info.czb_upload_status = response["resultMessage"]
      czb_car_user_info.save!
      pp response
    end
    pp response
  end

  # UserSystem::ChezhibaoCarUserInfo.query_data  从车置宝批量查询数据
  def self.query_data
    ids = ""
    i = 0
    cuis = UserSystem::ChezhibaoCarUserInfo.where("czb_id is not null and czb_status is null")
    cuis.find_each do |cui|
      i=i+1
      if ids.blank?
        ids << cui.czb_id
      else
        ids << ",#{cui.czb_id}"
      end
      # 每200个更新一次
      if i%20 ==0
        UserSystem::ChezhibaoCarUserInfo.query_and_update_czb_id ids
        i = 0
        ids = ""
      end
    end
    if i>0
      UserSystem::ChezhibaoCarUserInfo.query_and_update_czb_id ids
    end
  end


  # 从车置宝根据id查询数据
  def self.query_and_update_czb_id ids
    return if ids.blank?
    response = RestClient.post ProcuctionUrl, {service: 'unify.data.query.car',
                                               client: CLIENT,
                                               carid: UserSystem::ChezhibaoCarUserInfo.encrypt(ids),
                                               source: SOURCE}
    response = JSON.parse response
    if response["resultCode"] == 1
      response["resultData"].each do |data|
        cui = UserSystem::ChezhibaoCarUserInfo.where("czb_id = ?", data["carid"]).first
        cui.czb_status = data["status"]
        cui.czb_status_message = data["statusMsg"]
        cui.yaoyue_time = Time.now
        cui.yaoyue_day = Date.today
        if [2, 3,5,6, 7,8].include?  data["status"]
          cui.czb_yaoyue = '成功'
        elsif [1,4].include? data["status"]
          cui.czb_yaoyue = '失败'
        end
        cui.save!
      end
    else
      pp 'WARN:  接口更新异常'
      pp response["resultMessage"]
    end
  end

  def self.q
    d = Date.parse('2016-04-17')
    while true
      count_maoshuju = UserSystem::ChezhibaoCarUserInfo.where("czb_id is not null and created_at >= '#{d.chinese_format_day} 00:00:00' and created_at <= '#{d.chinese_format_day} 23:59:59'").count
      count_chenggong = UserSystem::ChezhibaoCarUserInfo.where("czb_id is not null and yaoyue_day = ? and czb_yaoyue = '成功'", d).count
      pp "#{d} 成功数据/毛数据 = #{count_chenggong}/#{count_maoshuju} = #{if count_maoshuju == 0 then 'NaN' else (((count_chenggong.to_f/count_maoshuju)*10000).to_i).to_f/100 end}%"

      d = d+1.day
      break if Date.today < d
    end
  end

  def self.encrypt str
    response = `java -classpath #{Rails.root.to_s}/lib/a/commons-codec-1.10.jar:#{Rails.root.to_s}/lib a.Des #{str} #{KEY}`
    response = response.split("\n")[1]
    response = response.split("：")[1]
    response
  end
end
__END__
测试环境：key = jhsdhsrr, source = 458
生成环境：key=jhcsvtjh,source = 458