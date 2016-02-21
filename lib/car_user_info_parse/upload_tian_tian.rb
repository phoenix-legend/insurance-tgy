module UploadTianTian
  CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "东莞", "重庆"]

  # CITY = ["上海"]

  # 需要上传的数据。
  def self.need_upload
    pp '开始批量上传'
    car_user_infos = UserSystem::CarUserInfo.where "tt_upload_status = 'weishangchuan' and id > #{UserSystem::CarUserInfo::CURRENT_ID} and phone is not null and brand is not null and is_cheshang = 0"
    pp "本次批量上传#{car_user_infos.length}个"
    pp "*************************************"
    car_user_infos
  end

  def self.upload_tt

    user_infos = UploadTianTian.need_upload
    user_infos.each do |user_info|
      UploadTianTian.upload_one_tt user_info
    end
  end

  def self.upload_one_tt car_user_info

    is_select = true

    car_user_info = car_user_info.reload

    if car_user_info.phone.blank?
      is_select = false
    end

    if car_user_info.tt_upload_status != 'weishangchuan'
      is_select = false
    end

    if car_user_info.is_cheshang != 0
      car_user_info.tt_upload_status = '疑似车商'
      is_select = false
    end

    if car_user_info.name.blank?
      is_select = false
    end

    if car_user_info.brand.blank?
      is_select = false
    end

    unless UploadTianTian::CITY.include? car_user_info.city_chinese
      car_user_info.tt_upload_status = '城市不对'
      is_select = false
    end

    # 车价小于1万的，跳过
    unless car_user_info.price.blank?
      car_user_info.price.gsub!('万', '')
      if car_user_info.price.to_f <= 1.0
        car_user_info.tt_upload_status = '金额小于1万'
        is_select = false
      end
    end
    # 车年龄大于10年的，跳过
    unless car_user_info.che_ling.blank?
      che_ling = car_user_info.che_ling.to_i
      if Time.now.year-che_ling>15
        car_user_info.tt_upload_status = '车年龄大于15年'
        is_select = false
      end
    end
    car_user_info.save!

    qudao = "23-23-1"
    if car_user_info.site_name == 'baixing'
      qudao = "23-23-4"
    elsif car_user_info.site_name == '58'
      qudao = "23-23-5"
    end

    if is_select
      # domain = "sandbox.openapi.ttpai.cn"
      # s = "256a18c39baf24f120a191c9454e4f03"
      domain = "openapi.ttpai.cn"
      s = "1579089ae5ae1d9b559f3082c4e44148"
      user_info = car_user_info
      params = []
      user_info = user_info.reload
      return if car_user_info.tt_upload_status != 'weishangchuan'
      params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
      params << [:mobile, UploadTianTian.escape2(user_info.phone)]
      params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
      params << [:brand, UploadTianTian.escape2(user_info.brand)]
      pp "渠道为#{qudao}"
      params << [:source, UploadTianTian.escape2(qudao)]
      params << [:appkey, UploadTianTian.escape2('shiaicaigou')]

      params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]

      response = RestClient.get "#{domain}/api/v1.1/ttp_sign_up?#{URI.encode_www_form params}"
      pp response
      response = JSON.parse response.body
      error = response["error"]
      message = response["message"]
      id = begin
        response["result"]["id"] rescue -1
      end
      user_info.tt_id = id
      user_info.tt_code = error
      user_info.tt_message = message
      user_info.tt_upload_status = '已上传'
      user_info.save!
    end

  end


  def self.escape2 str
    str = CGI::escape str
    str
  end


  def self.update_car_user_info options
    car_user_info = UserSystem::CarUserInfo.find options[:id]
    car_user_info.tt_code = options["code"]
    car_user_info.tt_error = options["error"]
    car_user_info.tt_message = options["message"]
    car_user_info.tt_result = options["result"]
    if car_user_info.tt_code.to_i == 200 and car_user_info.tt_error == "false"
      car_user_info.tt_upload_status = 'success'
    else
      car_user_info.tt_upload_status = 'shibai'
    end
    car_user_info.save!
  end

  # UploadTianTian.query_order
  def self.query_order
    car_user_infos = UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and site_name <> 'baixing'").order(id: :desc)
    i = 0
    car_user_infos.each do |car_user_info|
      source = "23-23-1"
      if car_user_info.site_name == 'baixing'
        source = "23-23-4"
      elsif car_user_info.site_name == '58'
        source = "23-23-5"
      end
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{source}"
      response = RestClient.get url
      response = JSON.parse response
      pp response["result"]["invite"]
      if not response["result"]["invite"].blank?
        car_user_info.tt_yaoyue = response["result"]["invite"] if (not response["result"]["invite"].blank? and car_user_info.tt_yaoyue.blank?)
        car_user_info.tt_jiance = response["result"]["detection"] if not response["result"]["detection"].blank?
        car_user_info.tt_chengjiao = response["result"]["deal"] if not response["result"]["deal"].blank?
        car_user_info.save!
        i = i+1
      end

    end

    j = UploadTianTian.query_order_baixing
    pp "百姓网#{j}个"
    pp "本次新增#{i}个。 "
    pp "总共#{i+j}个"
  end


  # UploadTianTian.query_order_baixing
  def self.query_order_baixing
    car_user_infos = UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and site_name = 'baixing'").order(id: :desc)
    i = 0
    car_user_infos.each do |car_user_info|
      source = "23-23-4"
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{source}"
      response = RestClient.get url
      response = JSON.parse response
      pp response["result"]["invite"]
      if not response["result"]["invite"].blank?
        car_user_info.tt_yaoyue = response["result"]["invite"] if (not response["result"]["invite"].blank? and car_user_info.tt_yaoyue.blank?)
        car_user_info.tt_jiance = response["result"]["detection"] if not response["result"]["detection"].blank?
        car_user_info.tt_chengjiao = response["result"]["deal"] if not response["result"]["deal"].blank?
        car_user_info.save!
        i = i+1
      end

    end
    pp "本次新增#{i}个。 "
    i
  end

  # UploadTianTian.get_now_status
  def self.get_now_status shishi=false
    last_day = 29
    if shishi
      UploadTianTian.query_order
    end
    # pp '-----------------------------------------------------------------'
    # pp '今天各渠道提交数量总数：'
    # today_counts = UserSystem::CarUserInfo.where("tt_id is not null and created_at > ? and created_at < ?", Date.today.chinese_format, Date.tomorrow.chinese_format).
    #     group("site_name").select("count(*) as count, site_name as site_name")
    # today_counts.each do |tc|
    #   pp "#{tc.site_name}: #{tc.count} 个"
    # end

    pp "-----------------------------------------------------------------"
    yx_month_counts = UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and created_at > ? and created_at < ?", Date.new(Date.today.year, Date.today.month, 1), Date.new(Date.today.year, Date.today.month, last_day)).count
    tj_month_counts = UserSystem::CarUserInfo.where("tt_id is not null  and created_at > ? and created_at < ?", Date.new(Date.today.year, Date.today.month, 1), Date.new(Date.today.year, Date.today.month, last_day)).count
    pp "本月意向总数：#{yx_month_counts}"
    pp "本月意向率：#{(yx_month_counts.to_f/tj_month_counts.to_f).round(3)*100}%"


    pp "------------------------今天各渠道意向率-----------------------------------------"
    # 赶集网成交率
    ['ganji', 'baixing', 'che168', 'taoche', '58'].each do |s|
      yixiang = UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and site_name = '#{s}' and created_at > ? and created_at < ?", Date.today.chinese_format, Date.tomorrow.chinese_format).count
      tijiao = UserSystem::CarUserInfo.where("tt_id is not null and site_name = '#{s}'  and created_at > ? and created_at < ?", Date.today.chinese_format, Date.tomorrow.chinese_format).count
      pp "#{s}: #{yixiang}/#{tijiao}=#{(yixiang.to_f/tijiao.to_f).round(3)*100}%"
    end

    pp "------------------------总体各渠道意向率-----------------------------------------"
    # 赶集网成交率
    ['ganji', 'baixing', 'che168', 'taoche', '58'].each do |s|
      yixiang = UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and site_name = '#{s}'").count
      tijiao = UserSystem::CarUserInfo.where("tt_id is not null and site_name = '#{s}'").count
      pp "#{s}: #{yixiang}/#{tijiao}=#{(yixiang.to_f/tijiao.to_f).round(3)*100}%"
    end


    ''
  end


end
