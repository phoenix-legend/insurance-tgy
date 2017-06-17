module UploadTianTian


  CITY = ["杭州", "深圳", "西安", "珠海", "中山",
          "北京", #先临时取消北京
          "上海", "苏州", "南京", "天津", "广州", "佛山", "重庆", "成都", '绍兴', '滁州', '顺德', '惠州', '东莞', '武汉', '宁波',
          '合肥', '长沙', '青岛', '郑州', '南宁', "温州", "太原", "沈阳", "无锡", "昆明", "厦门", "南昌"]


  CITY_YL = ["上海", "北京", "苏州", "南京", "天津", "佛山", "重庆", "成都", '绍兴', '滁州', '顺德', '惠州', '武汉', '宁波',
             '合肥', '长沙', '青岛', '郑州', '东莞', '南宁', "杭州", "深圳", "西安", "广州", "珠海", "中山",
             "温州", "太原", "沈阳", "无锡", "昆明", "厦门", "南昌"]

  # UploadTianTian::CITY_YL.each do |city|
  #   cuis = ::UserSystem::CarUserInfo.where("city_chinese = ? and tt_code is not null and created_at > '2017-06-01 00:00:00' and created_at < '2017-06-08 00:00:00'", city).
  #       group(:tt_created_day).
  #       select("tt_created_day, count(*) as c")
  #
  #   all_count = 0
  #   cuis.each do |cui|
  #     all_count += cui.c
  #   end
  #
  #   pp "#{city} :  #{all_count/7}"
  # end

  # ["郑州", "合肥", "深圳"].each do |city|
  #   number_14 = ::UserSystem::CarUserInfo.where("city_chinese = ? and tt_code is not null and created_at > '2017-06-14 00:00:00' and created_at < '2017-06-14 18:00:00'", city).count
  #   number_14_yx = ::UserSystem::CarUserInfo.where("city_chinese = ? and tt_code is not null and tt_id is not null and created_at > '2017-06-14 00:00:00' and created_at < '2017-06-14 18:00:00'", city).count
  #   pp "#{city}14日有效率: #{number_14_yx.to_f/number_14}"
  #
  #   number_16 = ::UserSystem::CarUserInfo.where("city_chinese = ? and tt_code is not null and created_at > '2017-06-16 00:00:00' and created_at < '2017-06-16 18:00:00'", city).count
  #   number_16_yx =_ ::UserSystem::CarUserInfo.where("city_chinese = ? and tt_code is not null and tt_id is not null and  created_at > '2017-06-16 00:00:00' and created_at < '2017-06-16 18:00:00'", city).count
  #   pp "#{city}16日有效率: #{number_16_yx.to_f/number_16}"
  # end


  SOURCE_YL = '2-775-778' #yl这边的source
  SOURCE_HL_ZL_KK = '23-23-15' #通过一体化直连过去的source, 我们只用它来查询
  SOURCE_HL_ZL_QQ = '2-263-282' #通过一体化直连过去的source, 我们只用它来查询

  SOURCE_QQ = '2-263-266'
  SOURCE_KK1 = '23-23-1'
  SOURCE_KK2 = '23-23-4'
  SOURCE_KK3 = '23-23-5'


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

    unless UploadTianTian::CITY.include? car_user_info.city_chinese
      car_user_info.tt_upload_status = '城市不对'
      # is_select = false
      car_user_info.save!
      return
    end

    return if car_user_info.brand.blank?

    return unless ['58', 'ganji', 'baixing', 'che168', 'zuoxi'].include? car_user_info.site_name

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

    if false and car_user_info.city_chinese == '北京'
      return if car_user_info.name.blank?
      ['图', '照片', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇', 'QQ', '经理', '老板', '总', '求购', '赶集'].each do |kw|
        if car_user_info.name.include? kw or car_user_info.che_xing.include? kw
          car_user_info.tt_upload_status = '疑似走私车或车商'
          car_user_info.save!
          return
        end
      end

      # 2016-12-5 去掉
      # if car_user_info.name.match /^小/ and car_user_info.name.length == 2
      #   car_user_info.tt_upload_status = '疑似走私车或车商'
      #   car_user_info.save!
      #   return
      # end


      if /^[a-z|A-Z|0-9|-|_]+$/.match car_user_info.name
        car_user_info.tt_upload_status = '疑似走私车'
        car_user_info.save!
        return
      end

      #还有用手机号，QQ号做名字的。
      if /[0-9]+/.match car_user_info.name
        car_user_info.tt_upload_status = '疑似走私车'
        car_user_info.save!
        return
      end

      #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
      tmp_chexing = car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
      tmp_note = car_user_info.note.gsub(/\s|\.|~|-|_/, '')
      if tmp_chexing.match /\d{9,11}|身份证|驾驶证/ or tmp_note.match /\d{9,11}|身份证|驾驶证/
        car_user_info.tt_upload_status = '疑似走私车'
        car_user_info.save!
        return
      end

      # 2016-12-5 去掉
      # if ['金杯', '五菱汽车', "五菱", '五十铃', '昌河', '奥迪', '宝马', '宾利', '奔驰', '路虎', '保时捷', '江淮', '东风小康', '依维柯', '长安商用', '福田', '东风风神', '东风', '一汽'].include? car_user_info.brand
      #   car_user_info.tt_upload_status = '品牌外车，暂排除'
      #   car_user_info.save!
      #   return
      # end

      # unless car_user_info.note.blank?
      #   ['QQ', '求购', '牌照', '批发', '私家一手车', '一手私家车', '身份', '身 份', '身~份', '个体经商', '过不了户', '帮朋友', '外地',
      #    '贷款', '女士一手', '包过户', '原漆', '原版漆', '当天开走', '美女', '车辆说明', '车辆概述', '选购', '一个螺丝',
      #    '精品', '驾驶证', '驾-驶-证', '车况原版', '随时过户', '来电有惊喜', '值得拥有', '包提档过户',
      #    '车源', '神州', '分期', '分 期', '必须过户', '抵押', '原车主', '店内服务', '选购', '微信', 'wx', '微 信',
      #    '威信', '加微', '评估师点评', '车主自述', "溦 信", '电话量大', '包你满意', '刷卡', '办理', '纯正', '抢购', '心动', '本车', '送豪礼'].each do |kw|
      #     if car_user_info.note.include? kw
      #       car_user_info.tt_upload_status = '疑似车商'
      #       car_user_info.save!
      #       return
      #     end
      #   end
      # end

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
      car_user_info.save!
      return
    end

    if car_user_info.brand.blank?
      is_select = false
      car_user_info.save!
      return
    end


    unless UploadTianTian::CITY.include? car_user_info.city_chinese
      car_user_info.tt_upload_status = '城市不对'
      is_select = false
      car_user_info.save!
      return
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


    if is_select

      #城市符合的情况下,给源鹿
      # if CITY_YL.include? car_user_info.city_chinese
      yl_count = UserSystem::CarUserInfo.where("tt_created_day = ? and tt_source in ('#{SOURCE_YL}') and tt_id is not null", Date.today).count
      if yl_count > 650 # 整体规模达到350个。
        car_user_info.tt_upload_status = 'yl超限'
        car_user_info.save!
        return
      end
      UploadTianTian.tt_pai_v2_0_yl car_user_info
      return
      # end

      #北京拿出三成给YL
      # if ['北京'].include? car_user_info.city_chinese #and  rand(100) < 80
      #   yl_count = UserSystem::CarUserInfo.where("tt_created_day = ? and tt_source in ('#{SOURCE_YL}') and tt_id is not null", Date.today).count
      #   if yl_count > 370 # 整体规模达到350个。
      #     car_user_info.tt_upload_status = 'yl超限'
      #     car_user_info.save!
      #     return
      #   end
      #   UploadTianTian.tt_pai_v2_0_yl car_user_info
      #   return
      # end

      # if ['北京'].include? car_user_info.city_chinese
      #   return
      # end

      #58全部给RO
      # if ['58'].include? car_user_info.site_name
      #   UploadTianTian.tt_pai_v2_0_yl car_user_info
      #   return
      # end

      #南宁, 东莞拿出七成给YL
      # if ['南宁','东莞'].include? car_user_info.city_chinese #and rand(100) < 80
      #   yl_count = UserSystem::CarUserInfo.where("tt_created_day = ? and tt_source in ('#{SOURCE_YL}') and tt_id is not null", Date.today).count
      #   if yl_count > 370 # 整体规模达到350个。
      #     car_user_info.tt_upload_status = 'yl超限'
      #     car_user_info.save!
      #     return
      #   end
      #   UploadTianTian.tt_pai_v2_0_yl car_user_info
      #   return
      #
      # end


      # yl_count = UserSystem::CarUserInfo.where("tt_created_day = ? and tt_source in ('#{SOURCE_QQ}', '#{SOURCE_KK1}','#{SOURCE_KK2}','#{SOURCE_KK3}') and tt_id is not null", Date.today).count
      # if yl_count > 150
      #   car_user_info.tt_upload_status = 'hl&kk超限'
      #   car_user_info.save!
      #   return
      # end
      # if rand(100) < 43 and ['58', 'ganji', 'baixing', 'che168'].include? car_user_info.site_name
      #   UploadTianTian.tt_pai_v2_0_qq car_user_info
      #   return
      # end
      # UploadTianTian.tt_pai_v1_0_hulei car_user_info
      # return
    end
  end


  # UploadTianTian.tt_pai_v1_0_hulei
  # 2017-03-27 胡磊直连注销
  # def self.tt_pai_v1_0_hulei car_user_info
  #   qudao = "23-23-1"
  #   if car_user_info.site_name == 'baixing' or car_user_info.site_name == 'zuoxi'
  #     qudao = "23-23-4"
  #   elsif car_user_info.site_name == '58'
  #     qudao = "23-23-5"
  #   end
  #
  #   domain = "openapi.ttpai.cn"
  #   s = "1579089ae5ae1d9b559f3082c4e44148"
  #   user_info = car_user_info
  #   params = []
  #   user_info = user_info.reload
  #   return if car_user_info.tt_upload_status != 'weishangchuan'
  #   params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
  #   params << [:mobile, UploadTianTian.escape2(user_info.phone)]
  #   params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
  #   params << [:brand, UploadTianTian.escape2(user_info.brand)]
  #   pp "渠道为#{qudao}"
  #   params << [:source, UploadTianTian.escape2(qudao)]
  #   params << [:appkey, UploadTianTian.escape2('shiaicaigou')]
  #
  #   params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
  #
  #   response = RestClient.get "#{domain}/api/v1.1/ttp_sign_up?#{URI.encode_www_form params}"
  #   pp response
  #   response = JSON.parse response.body
  #   error = response["error"]
  #   message = response["message"]
  #   id = begin
  #     response["result"]["id"] rescue -1
  #   end
  #   user_info.tt_source = qudao
  #   user_info.tt_created_day = user_info.created_at.chinese_format_day
  #   user_info.tt_id = id if not id.blank?
  #   user_info.tt_code = error
  #   user_info.tt_message = message
  #   user_info.tt_upload_status = '已上传'
  #   user_info.save!
  #   # UploadTianTian.upload_to_hulei_not_yitihua cui
  # end


  #郭正的天天拍2.0接口，新合同
  #UploadTianTian.tt_pai_v2_0_guozheng
  # def self.tt_pai_v2_0_guozheng user_info
  #
  #   # 现在要全部给唐金
  #   UploadTianTian.tt_pai_v2_0_tangjin user_info
  #   return
  #
  #   redis_key = "#{ Date.today.chinese_format_day}_tangjin_upload_number"
  #   redis = Redis.current
  #   if redis['to_tangjin_qudao_number']
  #     redis.expire 'to_tangjin_qudao_number', 7*24*60*60
  #   end
  #   if redis[redis_key].to_i < redis['to_tangjin_qudao_number'].to_i
  #     UploadTianTian.tt_pai_v2_0_tangjin user_info
  #     return
  #   end
  #
  #
  #   #测试环境
  #   # domain = "sandbox.openapi.ttpai.cn"
  #   # s = "3ee710fd91922986627461fccf8f7886"
  #   # appkey = 'flower'
  #   # qudao = '2-307'
  #
  #   #正式环境，已废弃
  #   # s = "83c78d166b59e953032eef673296faef"
  #   # appkey = 'flower'
  #   # qudao = '2-307-317'
  #   # domain = "openapi.ttpai.cn"
  #
  #   s = 'ce7807d55f0a40fbbd5ddb0f1c92756c'
  #   appkey = 'tree'
  #   qudao = '2-306-314'
  #   domain = "openapi.ttpai.cn"
  #
  #
  #   params = []
  #   user_info = user_info.reload
  #   return if user_info.tt_upload_status != 'weishangchuan'
  #   params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
  #   params << [:mobile, UploadTianTian.escape2(user_info.phone)]
  #   params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
  #   params << [:brand, UploadTianTian.escape2(user_info.brand)]
  #   params << [:source, UploadTianTian.escape2(qudao)]
  #   params << [:appkey, UploadTianTian.escape2(appkey)]
  #   params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
  #   response = RestClient.get "#{domain}/api/v2.0/ttp_sign_up?#{URI.encode_www_form params}"
  #   pp response
  #   response = JSON.parse response.body
  #   error = response["error"]
  #   message = response["message"]
  #   id = begin
  #     response["result"]["id"] rescue -1
  #   end
  #   user_info.tt_source = qudao
  #   user_info.tt_created_day = user_info.created_at.chinese_format_day
  #   user_info.tt_id = id if not id.blank?
  #   user_info.tt_code = error
  #   user_info.tt_message = message
  #   user_info.tt_upload_status = '已上传'
  #   user_info.save!
  # end


  #天天这边给唐金搞的新接口
  #UploadTianTian.tt_pai_v2_0_tangjin
  # def self.tt_pai_v2_0_tangjin user_info
  #   s = 'ed0c79e867028c60ce4137407728538c'
  #   appkey = 'xiaomeigui'
  #   qudao = '2-474-602'
  #   domain = "openapi.ttpai.cn"
  #
  #   #使用redis统计当天送上去的数据量
  #
  #   params = []
  #   user_info = user_info.reload
  #   return if user_info.tt_upload_status != 'weishangchuan'
  #   params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
  #   params << [:mobile, UploadTianTian.escape2(user_info.phone)]
  #   params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
  #   params << [:brand, UploadTianTian.escape2(user_info.brand)]
  #   params << [:source, UploadTianTian.escape2(qudao)]
  #   params << [:appkey, UploadTianTian.escape2(appkey)]
  #   params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
  #   response = RestClient.get "#{domain}/api/v2.0/ttp_sign_up?#{URI.encode_www_form params}"
  #   pp response
  #   response = JSON.parse response.body
  #   error = response["error"]
  #   message = response["message"]
  #   id = begin
  #     response["result"]["id"] rescue -1
  #   end
  #   user_info.tt_source = qudao
  #   user_info.tt_created_day = user_info.created_at.chinese_format_day
  #   user_info.tt_id = id if not id.blank?
  #   user_info.tt_code = error
  #   user_info.tt_message = message
  #   user_info.tt_upload_status = '已上传'
  #   user_info.save!
  #   if user_info.tt_id.to_i > 0
  #     redis_key = "#{ Date.today.chinese_format_day}_tangjin_upload_number"
  #     redis = Redis.current
  #     if redis[redis_key].blank?
  #       redis[redis_key] = 0
  #       redis.expire redis_key, 2*24*60*60
  #     else
  #       redis[redis_key] = redis[redis_key].to_i + 1
  #     end
  #   end
  # end

  #天天这边给俺搞的新接口
  # 2017-03-27  不直连天天, 改用接口
  #UploadTianTian.tt_pai_v2_0_qq
  # def self.tt_pai_v2_0_qq user_info
  #   s = '1579089ae5ae1d9b559f3082c4e44148'
  #   appkey = 'shiaicaigou'
  #   qudao = '2-263-266'
  #   domain = "openapi.ttpai.cn"
  #
  #   params = []
  #   user_info = user_info.reload
  #   return if user_info.tt_upload_status != 'weishangchuan'
  #   params << [:name, UploadTianTian.escape2(user_info.name.gsub('(个人)', ''))]
  #   params << [:mobile, UploadTianTian.escape2(user_info.phone)]
  #   params << [:city, UploadTianTian.escape2(user_info.city_chinese)]
  #   params << [:brand, UploadTianTian.escape2(user_info.brand)]
  #   params << [:source, UploadTianTian.escape2(qudao)]
  #   params << [:appkey, UploadTianTian.escape2(appkey)]
  #   params << [:sign, UploadTianTian.escape2(Digest::MD5.hexdigest("#{user_info.phone}#{s}"))]
  #   response = RestClient.get "#{domain}/api/v2.0/ttp_sign_up?#{URI.encode_www_form params}"
  #   pp response
  #   response = JSON.parse response.body
  #   error = response["error"]
  #   message = response["message"]
  #   id = begin
  #     response["result"]["id"] rescue -1
  #   end
  #   user_info.tt_source = qudao
  #   user_info.tt_created_day = user_info.created_at.chinese_format_day
  #   user_info.tt_id = id if not id.blank?
  #   user_info.tt_code = error
  #   user_info.tt_message = message
  #   user_info.tt_upload_status = '已上传'
  #   user_info.save!
  #   UploadTianTian.upload_to_hulei_not_yitihua user_info
  #
  # end


  def self.tt_pai_v1_0_hulei user_info
    params = {}
    qudao = '23-23-1'
    user_info = user_info.reload
    return if user_info.tt_upload_status != 'weishangchuan'

    n, s = "4SA-1011", '098f6bcd4621d373cade4e832627b4f6'

    params[:number] = n
    params[:sign] = Digest::MD5.hexdigest("#{n}#{s}")
    params[:key_data] = user_info.created_at.chinese_format
    params[:city] = "#{user_info.city_chinese}市"
    params[:mobile] = user_info.phone
    params[:brand] = user_info.brand
    params[:name] = user_info.name
    response = RestClient.post 'http://api.formal.4scenter.com/index.php?r=apicar/ttpinsert', params
    response = JSON.parse response.body
    pp response
    # response = response[0]


    error = response["error"]
    message = response["message"]

    user_info.tt_created_day = user_info.created_at.chinese_format_day
    user_info.tt_upload_status = "4Aerror#{message}"
    if error.to_s == 'true'
      user_info.tt_message = "4Aerror#{message}"

      user_info.save!
      return
    end


    id = begin
      response["result"]["ttpdate"]["result"]["id"] rescue ''
    end
    message = "4A#{response["result"]["id"]}~#{response["result"]["ttpdate"]["message"]}"

    user_info.tt_source = qudao
    user_info.tt_chengjiao = n

    ttp_error_code = if response["result"]["ttpdate"]["error"].to_s == "true" then
                       1
                     else
                       0
                     end
    user_info.tt_id = id if not id.blank?
    user_info.tt_code = ttp_error_code
    user_info.tt_message = message
    user_info.tt_upload_status = '已上传'
    user_info.save!
    # UploadTianTian.upload_to_hulei_not_yitihua user_info

  end

  def self.tt_pai_v2_0_qq user_info


    params = {}
    qudao = SOURCE_QQ
    user_info = user_info.reload
    return if user_info.tt_upload_status != 'weishangchuan'

    # n, s = "4SA-1011", 'dcd7f18c776dbaddfea4ce0ed5d2cfc3'

    n, s = '4SA-1012', "13cfe7dfa0dd2fe5e2a7d5fb467099a6"
    params[:number] = n
    params[:sign] = Digest::MD5.hexdigest("#{n}#{s}")
    params[:key_data] = user_info.created_at.chinese_format
    params[:city] = "#{user_info.city_chinese}市"
    params[:mobile] = user_info.phone
    params[:brand] = user_info.brand
    params[:name] = user_info.name
    response = RestClient.post 'http://api.formal.4scenter.com/index.php?r=apicar/ttpinsert', params
    response = JSON.parse response.body
    pp response
    # response = response[0]


    error = response["error"]
    message = response["message"]

    user_info.tt_created_day = user_info.created_at.chinese_format_day
    user_info.tt_upload_status = "4Aerror#{message}"
    if error.to_s == 'true'
      user_info.tt_message = "4Aerror#{message}"
      user_info.save!
      return
    end


    id = begin
      response["result"]["ttpdate"]["result"]["id"] rescue ''
    end
    message = "4A#{response["result"]["id"]}~#{response["result"]["ttpdate"]["message"]}"

    user_info.tt_source = qudao
    user_info.tt_chengjiao = n

    ttp_error_code = if response["result"]["ttpdate"]["error"].to_s == "true" then
                       1
                     else
                       0
                     end
    user_info.tt_id = id if not id.blank?
    user_info.tt_code = ttp_error_code
    user_info.tt_message = message
    user_info.tt_upload_status = '已上传'
    user_info.save!
    # UploadTianTian.upload_to_hulei_not_yitihua user_info

  end


  #天天芮欧(源鹿)
  #UploadTianTian.tt_pai_v2_0_yl
  def self.tt_pai_v2_0_yl user_info

    s = 'b2fc17d41d78dc579bcdaefab3555c2a'
    appkey = 'fenghuang'
    qudao = SOURCE_YL
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
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and id > 5000000 and tt_source in ('23-23-4','23-23-5','23-23-1') and tt_created_day > ?", Date.today - 30).order(id: :desc)
    i = 0
    car_user_infos.find_each do |car_user_info|
      s = if car_user_info.tt_chengjiao == '4SA-1011' then
            SOURCE_HL_ZL_KK
          else
            car_user_info.tt_source
          end
      url = "http://openapi.ttpai.cn/api/v1.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{s}"
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
  # 天天接口查询2.0版本，目前QQ胡磊直连和YL直连更新
  def self.query_order2
    # car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and id > 5000000 and tt_source in ('#{SOURCE_YL}','2-307-317', '2-306-314','2-474','2-474-602', '2-263-266') and tt_created_day > ?", Date.today - 30)
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue is null and id > 5000000 and tt_source in ('#{SOURCE_YL}', '#{SOURCE_QQ}') and tt_created_day > ?", Date.today - 30)
    i = 0
    car_user_infos.find_each do |car_user_info|
      # car_user_info = ::UserSystem::CarUserInfo.where("tt_id  = 21924728").first
      s = if car_user_info.tt_chengjiao == '4SA-1012' then
            SOURCE_HL_ZL_QQ
          else
            car_user_info.tt_source
          end
      url = "http://openapi.ttpai.cn/api/v2.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{s}"
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
  # UploadTianTian.xiazai_tt_yaoyue_detail_by_day '2016-12-01', '2016-12-31'
  def self.xiazai_tt_yaoyue_detail_by_day start_day = '2016-04-01', end_day = '2016-04-30'
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    # ['23-23-1', '23-23-4', '23-23-5','2-307-317','2-306-314'].each_with_index do |qudao, i|
    ['23-23-1', '23-23-4', '23-23-5'].each_with_index do |qudao, i|
      # ['2-307-317', '2-306-314'].each_with_index do |qudao, i|
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


  # UploadTianTian.xiazai_tt_create_detail_by_day '2016-08-01', '2016-08-31'
  # 下载某时间段内的天天创建
  def self.xiazai_tt_create_detail_by_day start_day = '2016-04-01', end_day = '2016-04-30'
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    # ['23-23-1', '23-23-4', '23-23-5'].each_with_index do |qudao, i|
    ['2-307-317', '2-306-314', '2-474', '2-474-602'].each_with_index do |qudao, i|
      # ['2-263-266'].each_with_index do |qudao, i|
      cuis = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_source = '#{qudao}' and tt_created_day >= '#{start_day}' and  tt_created_day <= '#{end_day}'")
      cuis.order(tt_yaoyue_day: :asc, tt_source: :asc)
      sheet1 = book.create_worksheet name: "#{qudao}意向列表"
      ['ID', '渠道', '创建日期'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      current_row = 1
      cuis.each do |car_user_info|
        [car_user_info.tt_id, car_user_info.tt_source, car_user_info.tt_created_day].each_with_index do |content, i|
          sheet1.row(current_row)[i] = content
        end
        current_row += 1
      end
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}导出的成功创建数据#{start_day}~#{end_day}.xls")
    book.write file_path
    file_path
  end


  # UploadTianTian.query_order_shibai
  #  把失败的数据，再更新一遍，以便从失败中捡漏
  # 2017-01-06 增加  只捡最近45天的漏
  def self.query_order_shibai

    return unless Time.now.day > 27
    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '失败' and tt_source in ('23-23-1','23-23-4','23-23-5') and tt_created_day > ? ", Date.today - 45).order(id: :desc)
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


    car_user_infos = ::UserSystem::CarUserInfo.where("tt_id is not null and tt_yaoyue = '失败' and tt_source in ('2-307-317', '2-306-314','2-474','2-474-602', '#{SOURCE_QQ}') and tt_created_day > ?", Date.today - 45)
    i = 0
    car_user_infos.find_each do |car_user_info|
      # car_user_info = ::UserSystem::CarUserInfo.where("tt_id  = 21924728").first
      url = "http://openapi.ttpai.cn/api/v2.0/query_ttp_sign_up?id=#{car_user_info.tt_id}&source=#{car_user_info.tt_source}"
      response = RestClient.get url
      response = JSON.parse response
      pp "#{response["result"]["invite"]} ~~  #{car_user_info.tt_id}"
      next if response["result"]["invite"] == '失败'
      if not response["result"]["invite"].blank? and car_user_info.tt_yaoyue == '失败'
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

  #实时在胡磊那边备份一次
  # UploadTianTian.upload_to_hulei_not_yitihua cui
  def self.upload_to_hulei_not_yitihua cui
    cui = cui.reload
    return if cui.tt_id.blank?
    return unless cui.tt_jiance.blank?

    n, s = 1, 2
    if [SOURCE_KK1, SOURCE_KK2, SOURCE_KK3].include? cui.tt_source
      n, s = "4SA-1011", 'dcd7f18c776dbaddfea4ce0ed5d2cfc3'
    elsif [SOURCE_QQ].include? cui.tt_source
      n, s = '4SA-1012', "13cfe7dfa0dd2fe5e2a7d5fb467099a6"
    else
      return
    end


    url = 'http://api.formal.4scenter.com//index.php?r=apicar/getresponse'


    k = {"response_id" => cui.tt_id,
         "number" => n,
         "sign" => Digest::MD5.hexdigest("#{n}#{s}"),
         "source" => 'ttpc',
         "key_data" => cui.created_at.chinese_format,
         "city" => cui.city_chinese,
         "mobile" => cui.phone,
         "brand" => cui.brand,
         "name" => cui.name}


    response = RestClient.post url, k

    response = JSON.parse response
    if response["error"] == 'false'
      cui.tt_jiance = response["result"]["id"]
      cui.save!
    end

  end

end

__END__

-----
|\|/|
-----
|/|\|
-----