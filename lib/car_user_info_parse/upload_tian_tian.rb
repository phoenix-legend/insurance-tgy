module UploadTianTian

  CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "东莞", "重庆", "佛山"]

  CITY1 = ["上海", "成都", "深圳", "南京", "广州", "杭州", "东莞", "佛山"]
  CITY2 = ["武汉", "天津", "重庆", "苏州"]
  # CITY2= []


  # CITY = ["上海"]

  # 需要上传的数据。
  # def self.need_upload
  #   pp '开始批量上传'
  #   car_user_infos = ::UserSystem::CarUserInfo.where "tt_upload_status = 'weishangchuan' and id > #{::UserSystem::CarUserInfo::CURRENT_ID} and phone is not null and brand is not null and is_cheshang = 0"
  #   pp "本次批量上传#{car_user_infos.length}个"
  #   pp "*************************************"
  #   car_user_infos
  # end

  # def self.upload_tt
  #   user_infos = UploadTianTian.need_upload
  #   user_infos.each do |user_info|
  #     UploadTianTian.upload_one_tt user_info
  #   end
  # end

  def self.upload_one_tt car_user_info

    is_select = true

    car_user_info = car_user_info.reload

    if not car_user_info.tt_id.blank?
      return # 如果已经提交，就不再提交
    end

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

    #晚上带[]的，全部认为是车商
    # 白天带[]的，留给4A
    # if not car_user_info.che_xing.blank?
    #   if car_user_info.che_xing.match /\[/ and car_user_info.che_xing.match /\]/
    #     is_select = false
    #   end
    #   if car_user_info.che_xing.match /【/ and car_user_info.che_xing.match /】/
    #     is_select = false
    #   end
    # end



    # if car_user_info.is_repeat_one_month
    #   car_user_info.tt_upload_status = '自判重复'
    #   is_select = false
    # end

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
    # unless car_user_info.price.blank?
    #   car_user_info.price.gsub!('万', '')
    #   if car_user_info.price.to_f <= 1.0
    #     car_user_info.tt_upload_status = '金额小于1万'
    #     is_select = false
    #   end
    # end
    # 车年龄大于10年的，跳过
    # unless car_user_info.che_ling.blank?
    #   che_ling = car_user_info.che_ling.to_i
    #   if Time.now.year-che_ling>15
    #     car_user_info.tt_upload_status = '车年龄大于15年'
    #     is_select = false
    #   end
    # end
    car_user_info.save!


    #其它渠道再往胡磊那里传
    # qudao = "23-23-1"
    # if car_user_info.site_name == 'baixing' or car_user_info.site_name == 'zuoxi'
    #   qudao = "23-23-4"
    # elsif car_user_info.site_name == '58'
    #   qudao = "23-23-5"
    # end

    if is_select

      #赶集8城市不往郭正那里进入,给埃侍一体化平台留点机会
      return if car_user_info.site_name == 'ganji' and CITY1.include?(car_user_info.city_chinese)

      # 所有的全部导入到郭正的渠道
      if UploadTianTian::CITY.include? car_user_info.city_chinese
        UploadTianTian.tt_pai_v2_0_guozheng car_user_info
        return
      end

      #如果符合郭正的城市条件，优先给郭正渠道
      # if UploadTianTian::CITY2.include? car_user_info.city_chinese
      #   UploadTianTian.tt_pai_v2_0_guozheng car_user_info
      #   return
      # end

      #如果符合郭正的城市条件，优先给郭正渠道
      # if UploadTianTian::CITY.include? car_user_info.city_chinese and car_user_info.site_name == '58'
      #   UploadTianTian.tt_pai_v2_0_guozheng car_user_info
      #   return
      # end


      # if not UploadTianTian::CITY1.include? car_user_info.city_chinese
      #   return
      # end

      # domain = "sandbox.openapi.ttpai.cn"
      # s = "256a18c39baf24f120a191c9454e4f03"
      # domain = "openapi.ttpai.cn"
      # s = "1579089ae5ae1d9b559f3082c4e44148"
      # user_info = car_user_info
      # params = []
      # user_info = user_info.reload
      # return if car_user_info.tt_upload_status != 'weishangchuan'
      # params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
      # params << [:mobile, UploadTianTian.escape2(user_info.phone)]
      # params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
      # params << [:brand, UploadTianTian.escape2(user_info.brand)]
      # pp "渠道为#{qudao}"
      # params << [:source, UploadTianTian.escape2(qudao)]
      # params << [:appkey, UploadTianTian.escape2('shiaicaigou')]
      #
      # params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
      #
      # response = RestClient.get "#{domain}/api/v1.1/ttp_sign_up?#{URI.encode_www_form params}"
      # pp response
      # response = JSON.parse response.body
      # error = response["error"]
      # message = response["message"]
      # id = begin
      #   response["result"]["id"] rescue -1
      # end
      # user_info.tt_source = qudao
      # user_info.tt_created_day = user_info.created_at.chinese_format_day
      # user_info.tt_id = id if not id.blank?
      # user_info.tt_code = error
      # user_info.tt_message = message
      # user_info.tt_upload_status = '已上传'
      # user_info.save!
    end
  end


  #郭正的天天拍2.0接口，新合同
  #UploadTianTian.tt_pai_v2_0_guozheng
  def self.tt_pai_v2_0_guozheng user_info

    #测试环境
    # domain = "sandbox.openapi.ttpai.cn"
    # s = "3ee710fd91922986627461fccf8f7886"
    # appkey = 'flower'
    # qudao = '2-307'

    s = "83c78d166b59e953032eef673296faef"
    appkey = 'flower'
    qudao = '2-307-317'
    domain = "openapi.ttpai.cn"


    params = []
    user_info = user_info.reload
    return if user_info.tt_upload_status != 'weishangchuan'
    params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
    params << [:mobile, UploadTianTian.escape2(user_info.phone)]
    params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
    params << [:brand, UploadTianTian.escape2(user_info.brand)]
    params << [:source, UploadTianTian.escape2(qudao)]
    params << [:appkey, UploadTianTian.escape2(appkey)]
    params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
    response = RestClient.get "#{domain}/api/v2.0/ttp_sign_up?#{URI.encode_www_form params}"
    pp response
    response = JSON.parse response.body
    error = response["error"]
    message = response["message"]
    id = begin
      response["result"]["id"] rescue -1
    end
    user_info.tt_source = qudao
    user_info.tt_created_day = user_info.created_at.chinese_format_day
    user_info.tt_id = id if not id.blank?
    user_info.tt_code = error
    user_info.tt_message = message
    user_info.tt_upload_status = '已上传'
    user_info.save!
  end


  def self.escape2 str
    str = CGI::escape str
    str
  end


  def self.update_car_user_info options
    car_user_info = ::UserSystem::CarUserInfo.find options[:id]
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
  # 天天数据查询接口1.0版本，主要用于胡磊三个渠道数据更新
  def self.query_order
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null").order(id: :desc)
    i = 0
    car_user_infos.find_each do |car_user_info|
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{car_user_info.tt_source}"
      response = RestClient.get url
      response = JSON.parse response
      pp "#{response["result"]["invite"]} ~~  #{car_user_info.tt_id}"
      if not response["result"]["invite"].blank? and car_user_info.tt_yaoyue.blank?
        car_user_info.tt_yaoyue = response["result"]["invite"]
        car_user_info.tt_yaoyue_time = DateTime.now.chinese_format
        car_user_info.tt_yaoyue_day = car_user_info.tt_yaoyue_time.chinese_format_day
        car_user_info.save!
        i = i+1
      end
    end
    pp "本次新增#{i}个。 "
  end

  # UploadTianTian.query_order2
  # 天天接口查询2.0版本，目前用于郭正一个渠道更新数据
  def self.query_order2
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and tt_source = '2-307-317'")
    i = 0
    car_user_infos.find_each do |car_user_info|
      # car_user_info = ::UserSystem::CarUserInfo.where("tt_id  = 21924728").first
      url = "http://openapi.ttpai.cn/api/v2.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{car_user_info.tt_source}"
      response = RestClient.get url
      response = JSON.parse response
      pp "#{response["result"]["invite"]} ~~  #{car_user_info.tt_id}"
      if not response["result"]["invite"].blank? and car_user_info.tt_yaoyue.blank?
        car_user_info.tt_yaoyue = response["result"]["invite"]
        car_user_info.tt_yaoyue_time = DateTime.now.chinese_format
        car_user_info.tt_yaoyue_day = car_user_info.tt_yaoyue_time.chinese_format_day
        car_user_info.save!
        i = i+1
      end
    end
    pp "本次新增#{i}个。 "
  end


  # UploadTianTian.get_now_status  参数为是否实时
  def self.get_now_status shishi=false
    last_day = 29
    if shishi
      UploadTianTian.query_order
      #UserSystem::CarUserInfo.get_kaixin_info # 给开新那边导数据
    end

    # pp "-----------------------------------------------------------------"
    # yx_month_counts = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and created_at > ? and created_at < ?", Date.new(Date.today.year, Date.today.month, 1), Date.new(Date.today.year, Date.today.month, last_day)).count
    # tj_month_counts = ::UserSystem::CarUserInfo.where("tt_id is not null  and created_at > ? and created_at < ?", Date.new(Date.today.year, Date.today.month, 1), Date.new(Date.today.year, Date.today.month, last_day)).count
    # pp "本月意向总数：#{yx_month_counts}"
    # pp "本月意向率：#{(yx_month_counts.to_f/tj_month_counts.to_f).round(3)*100}%"
    #
    #
    # pp "------------------------今天各渠道意向率-----------------------------------------"
    # # 赶集网成交率
    # ['ganji', 'baixing', 'che168', 'taoche', '58'].each do |s|
    #   yixiang = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and site_name = '#{s}' and created_at > ? and created_at < ?", Date.today.chinese_format, Date.tomorrow.chinese_format).count
    #   tijiao = ::UserSystem::CarUserInfo.where("tt_id is not null and site_name = '#{s}'  and created_at > ? and created_at < ?", Date.today.chinese_format, Date.tomorrow.chinese_format).count
    #   pp "#{s}: #{yixiang}/#{tijiao}=#{(yixiang.to_f/tijiao.to_f).round(3)*100}%"
    # end
    #
    # pp "------------------------总体各渠道意向率-----------------------------------------"
    # # 赶集网成交率
    # ['ganji', 'baixing', 'che168', 'taoche', '58'].each do |s|
    #   yixiang = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '成功' and site_name = '#{s}'").count
    #   tijiao = ::UserSystem::CarUserInfo.where("tt_id is not null and site_name = '#{s}'").count
    #   pp "#{s}: #{yixiang}/#{tijiao}=#{(yixiang.to_f/tijiao.to_f).round(3)*100}%"
    # end
    pp "现在时间：#{Time.now.chinese_format}"

    ''
  end


  # module UploadTianTian
  def self.yiloushuju d=nil
    d = d||'2016-02-24'
    cuis = ::UserSystem::CarUserInfo.where("tt_id is not null  and tt_yaoyue = '成功' and tt_yaoyue_time > '#{d} 00:00:00' and tt_yaoyue_time < '#{d} 23:59:59'")
    success = 0
    weizhi = 0
    shibai = 0
    cuis.each do |car_user_info|
      # source = "23-23-1"
      # if car_user_info.site_name == 'baixing'
      #   source = "23-23-4"
      # elsif car_user_info.site_name == '58'
      #   source = "23-23-5"
      # end
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{car_user_info.tt_source}"

      response = RestClient.get url
      response = JSON.parse response
      if response["result"]["invite"]=='成功'
        success = success+1
      end
      if response["result"]["invite"]=='失败'
        shibai = shibai+1
      end
      if response["result"]["invite"].blank?
        weizhi = weizhi+1
      end

      if response["result"]["invite"]=='失败'
        # pp "id:#{car_user_info.tt_id},意向：#{UploadTianTian.aaa response["result"]["invite"]}, 到检：#{UploadTianTian.aaa response["result"]["detection"]}, 拍卖：#{UploadTianTian.aaa response["result"]["auction"]},成交：#{UploadTianTian.aaa response["result"]["deal"]},渠道：#{source},日期：#{d}"
      end

    end
    pp "#{d}: 成功#{success}个，未知#{weizhi}个,失败#{shibai}个，总共#{cuis.length}个"

  end

  # end

  def self.aaa str
    if str.blank?
      "未知"
    else
      str
    end
  end

  def self.get_qudao_zongjie
    cuis = ::UserSystem::CarUserInfo.where("tt_yaoyue = '成功' and tt_source is null")
    cuis.each do |cui|
      source = "23-23-1"
      if cui.site_name == 'baixing' or cui.site_name == 'zuoxi'
        source = "23-23-4"
      elsif cui.site_name == '58'
        source = "23-23-5"
      end
      pp cui.id
      cui.tt_source = source if cui.tt_source.blank?
      cui.tt_created_day = cui.created_at.chinese_format_day if cui.tt_created_day.blank?
      # cui.tt_yaoyue_day = cui.tt_yaoyue_time.chinese_format_day unless cui.tt_yaoyue_time.blank?
      cui.save!
    end

    #  统计某个渠道某天有多少提交，多少成功意向
    # select tt_yaoyue_day,tt_source, count(*) from car_user_infos where tt_id is not null and tt_yaoyue = '成功' and tt_yaoyue_day is not null group by tt_source, tt_yaoyue_day order by tt_yaoyue_day asc
    #
    # select tt_created_day,tt_source, count(*) from car_user_infos where tt_id is not null and tt_created_day is not null group by tt_source, tt_created_day order by tt_created_day asc
  end


  # 检查有多少数据的城市与真实城市不相符
  def self.tttt
    cuis = ::UserSystem::CarUserInfo.where("tt_yaoyue = '成功' and site_name = '58'")

    invert_wuba_city = UserSystem::CarUserInfo::WUBA_CITY.invert
    aa = 0
    cuis.each do |cui|
      sx = invert_wuba_city[cui.city_chinese]
      zhengze = "http://(#{sx}).58.com"
      a = cui.detail_url.match Regexp.new zhengze
      if a.blank?
        pp "#{cui.city_chinese},#{cui.detail_url}"
        aa = aa+1
      end
    end
    pp aa
  end

  # 指定日期区间的意向数据。
  # UploadTianTian.xiazai_tt_detail_by_day '2016-03-01', '2016-03-31'
  def self.xiazai_tt_detail_by_day start_day = '2016-04-01', end_day = '2016-04-30'
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    ['23-23-1', '23-23-4', '23-23-5'].each_with_index do |qudao, i|
      cuis = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_source = '#{qudao}' and tt_yaoyue_day >= '#{start_day}' and  tt_yaoyue_day <= '#{end_day}' and tt_yaoyue = '成功' and tt_yaoyue_day is not null")
      cuis.order(tt_yaoyue_day: :asc, tt_source: :asc)
      sheet1 = book.create_worksheet name: "#{qudao}意向列表"
      ['ID', '渠道', '邀约日期', '状态'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      current_row = 1
      cuis.each do |car_user_info|
        [car_user_info.tt_id, car_user_info.tt_source, car_user_info.tt_yaoyue_day, car_user_info.tt_yaoyue].each_with_index do |content, i|
          sheet1.row(current_row)[i] = content
        end
        current_row += 1
      end
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}导出的成功邀约数据#{start_day}~#{end_day}.xls")
    book.write file_path
    file_path
  end


  # UploadTianTian.query_order_shibai
  #  把失败的数据，再更新一遍，以便从失败中捡漏
  def self.query_order_shibai
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '失败'").order(id: :desc)
    i = 0
    car_user_infos.find_each do |car_user_info|
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{car_user_info.tt_source}"
      response = RestClient.get url
      response = JSON.parse response

      pp response["result"]["invite"]
      pp car_user_info.tt_id
      pp '..........................'
      next if response["result"]["invite"] == '失败'
      if !response["result"]["invite"].blank? and car_user_info.tt_yaoyue == '失败'
        car_user_info.tt_yaoyue = response["result"]["invite"]
        car_user_info.tt_yaoyue_time = DateTime.now.chinese_format
        car_user_info.tt_yaoyue_day = car_user_info.tt_yaoyue_time.chinese_format_day
        car_user_info.save!
        i = i+1
      end
    end
    pp "本次新增#{i}个。 "
  end


  # 真正提交上去的和单竞争对手比较
  # UploadTianTian.really_jiao_bijiao
  def self.really_jiao_bijiao is_detail = false
    ['58', 'ganji', 'baixing', 'che168', 'taoche'].each do |site_name|
      # ['58'].each do |site_name|
      all_number = 0
      our_number = 0
      pp '---------'*7
      pp site_name

      cuis = UserSystem::CarUserInfo.where("site_name = '#{site_name}' and tt_upload_status = '已上传' and id > 1000000 and is_repeat_one_month = false ")
                 .order(id: :desc).limit(300).
          select("id, name , phone, tt_upload_status,city_chinese, tt_id, tt_message, brand, created_at, site_name,is_repeat_one_month ")
      a = []
      cuis.each do |cui|
        if cui.tt_id.blank?
          count = UserSystem::CarUserInfo.where("phone = ? and id < ?", cui.phone, cui.id).count
          if count == 0
            a<< "        #{cui.tt_message}"
            all_number += 1
          end
        else
          a<< "#{cui.tt_id}#{cui.tt_message}"
          all_number += 1
          our_number += 1
        end
      end
      pp a if is_detail
      pp "总数量 #{all_number}, 我们的数量 #{our_number}"
      pp our_number.to_f / all_number
    end

    return ''
  end


  # 忽略掉重点城市以外， 临时使用
  def self.couge
    UserSystem::KouLingCarUserInfo.all.find_each do |kl|
      begin
        cui = kl.car_user_info
        if ["上海", "成都", "深圳", "南京", "广州", "苏州", "杭州", "东莞", "重庆", "佛山"].include? cui.city_chinese
          kl.vip_flg = 'vip'
          kl.save!
        else
          kl.vip_flg = 'normal'
          kl.save!
        end
      rescue Exception => e
        next
      end
    end


    UserSystem::CarUserInfo.where("site_name = 'baixing' and need_update = ?", true).find_each do |cui|
      unless ["上海", "成都", "深圳", "南京", "广州", "苏州", "杭州", "东莞", "重庆", "佛山"].include? cui.city_chinese
        cui.need_update = false
        cui.save!
      end
    end


    UserSystem::CarUserInfo.where(city_chinese: '上海').where("id > 1148459 and tt_yaoyue = '成功'")

  end


end

__END__

-----
|\|/|
-----
|/|\|
-----