class UserSystem::AishiCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'


  CITY = [
      # "福州", "厦门",
      '苏州', "杭州", "上海",   "合肥",
      "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京","成都",
      '天津',  '武汉', '重庆',
      "郑州", "长沙", "西安", "青岛", "威海", "烟台",
      "潍坊", "无锡", "常州", "徐州", "南通", "扬州", "济南",
      "石家庄", "唐山", "太原", "宝鸡", "洛阳", "南阳", "新乡", "湘潭", "株洲", "常德",
      "岳阳", "沈阳", "大连", "营口", "泉州", "长春", "哈尔滨", "大庆",  "芜湖", "南宁", "南昌",

      "运城", "晋中", "临汾", "大同", "遵义", "兰州", "呼和浩特",
      "贵阳", "惠州", "嘉兴", "中山", "肇庆", "绵阳", "襄阳", "宜昌",
      "滨州", "德州", "东营", "济宁", "临沂", "日照", "泰安", "枣庄", "宁波", "宿迁", "泰州", "盐城", "镇江",

      "自贡", "淄博", "资阳", "驻马店", "珠海", "长治", "漳州", "张家口", "玉林", "益阳", "义乌", "宜春",
      "宜宾", "盐城", "延边", "雅安", "许昌", "邢台", "信阳", "孝感", "咸宁", "温州", "通辽", "铁岭",
      "台州", "遂宁", "随州", "松原", "四平", "十堰", "绍兴", "上饶", "商丘", "汕头", "三明", "曲靖",
      "衢州", "秦皇岛", "钦州", "齐齐哈尔", "莆田", "平顶山", "攀枝花", "宁德", "内江", "南充", "牡丹江",
      "眉山", "马鞍山", "漯河", "泸州", "龙岩", "六盘水", "六安", "柳州", "辽阳", "连云港", "乐山", "廊坊",
      "昆明", "开封", "九江", "景德镇", "荆州", "荆门", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林",
      "吉安", "黄石", "淮安", "湖州", "呼和浩特", "衡水", "邯郸", "桂林", "广元", "广安", "赣州", "阜阳",
      "抚州", "抚顺", "福州", "恩施", "鄂尔多斯", "德阳", "大理", "达州", "楚雄", "赤峰", "承德", "沧州", "北海",
      "保定", "包头", "百色", "巴中", "鞍山", "安阳", "安庆", "红河", "蚌埠", "丽水",
      "咸阳", "乌鲁木齐", "银川", "西宁", "菏泽", "铜陵", "黄冈", "鄂州", "阳泉"
  ]


  def self.get_key_numbers city_name
    if ['太原', '郑州', '长沙', '运城', '晋中', '临汾', '大同', "兰州", "呼和浩特",
        "大连", "贵阳", "惠州", "嘉兴", "中山", "肇庆", "绵阳", "襄阳", "宜昌",
        "滨州", "德州", "东营", "济宁", "临沂", "日照", "泰安", "枣庄", "宁波", "宿迁", "泰州", "盐城", "镇江",

        "自贡", "淄博", "资阳", "驻马店", "珠海", "长治", "漳州", "张家口", "玉林", "益阳", "义乌", "宜春",
        "宜宾", "盐城", "延边", "雅安", "许昌", "邢台", "信阳", "孝感", "咸宁", "温州", "通辽", "铁岭",
        "台州", "遂宁", "随州", "松原", "四平", "十堰", "绍兴", "上饶", "商丘", "汕头", "三明", "曲靖",
        "衢州", "秦皇岛", "钦州", "齐齐哈尔", "莆田", "平顶山", "攀枝花", "宁德", "内江", "南充", "牡丹江",
        "眉山", "马鞍山", "漯河", "泸州", "龙岩", "六盘水", "六安", "柳州", "辽阳", "连云港", "乐山", "廊坊",
        "昆明", "开封", "九江", "景德镇", "荆州", "荆门", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林",
        "吉安", "黄石", "淮安", "湖州", "呼和浩特", "衡水", "邯郸", "桂林", "广元", "广安", "赣州", "阜阳",
        "抚州", "抚顺", "福州", "恩施", "鄂尔多斯", "德阳", "大理", "达州", "楚雄", "赤峰", "承德", "沧州", "北海",
        "保定", "包头", "百色", "巴中", "鞍山", "安阳", "安庆", "红河", "蚌埠", "丽水",
        "咸阳", "乌鲁木齐", "银川", "西宁", "菏泽", "铜陵", "黄冈", "鄂州", "阳泉"
    ].include? city_name
      return '13cfe7dfa0dd2fe5e2a7d5fb467099a6', '4SA-1012' # Eric 秘钥
    elsif ['福州', '厦门', '上海',"苏州","合肥"].include? city_name
      if rand(10)<6
        return '13cfe7dfa0dd2fe5e2a7d5fb467099a6', '4SA-1012'
      else
        return "098f6bcd4621d373cade4e832627b4f6", "4SA-1011"
      end
    elsif [].include? city_name
      return '79ac5efb00e55d1025a1850ac6cf653a', '4SA-1013' # Eric 秘钥二
    else
      return "098f6bcd4621d373cade4e832627b4f6", "4SA-1011" # 第一次KK的密钥
    end
  end


  # 上传到埃侍
  # UserSystem::AishiCarUserInfo.upload_to_aishi ycui
  def self.upload_to_aishi ycui
    # sleep 1
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

    unless ["福州", "厦门", '苏州', "杭州", "上海",   "合肥", "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京","成都"].include? ycui.city_chinese
      if not ycui.is_city_match
        pp '城市不匹配'
        ycui.aishi_upload_status = '城市不匹配'
        ycui.save!
        return
      end
    end




    return if ycui.phone.blank?
    return if ycui.aishi_upload_status != '未上传'
    return if ycui.name.blank?


    cui = ycui.car_user_info
    cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(ycui.phone)
    cui.save!

    unless ["福州", "厦门", '苏州', "杭州", "上海",   "合肥", "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京","成都"].include? ycui.city_chinese
      if not cui.phone_city.blank?
        unless cui.city_chinese == cui.phone_city
          ycui.aishi_upload_status = '非本地车'
          ycui.save!
          return
        end
      end
    end

    # unless ['上海', '福州', '厦门'].include? ycui.city_chinese
      # if ycui.che_ling.to_i < 2009
      #   ycui.aishi_upload_status = '车龄过老'
      #   ycui.save!
      #   return
      # end

      # if ['众泰', "五菱", '长安商用', '奇瑞', '力帆', '金杯', '江淮', '哈飞', '哈弗', '东风小康', '宝骏', '五菱汽车', '五十铃', '昌河', '依维柯', '福田', '东风风神', '东风'].include? ycui.brand
      #   ycui.aishi_upload_status = '品牌外车，暂排除'
      #   ycui.save!
      #   return
      # end

      # if ycui.milage.to_f > 15
      #   ycui.aishi_upload_status = '里程太多'
      #   ycui.save!
      #   return
      # end
    # end


    # key = "033bd94b1168d7e4f0d644c3c95e35bf" #测试
    # number = "4S-10009" #测试

    # key = "5c7a8fe495a35f24f6674ac80c9843d8" #正式
    # number = "4SA-1001" #正式

    # key = "098f6bcd4621d373cade4e832627b4f6" #正式
    # number = "4SA-1011" #正式

    key, number = UserSystem::AishiCarUserInfo.get_key_numbers ycui.city_chinese

    if number == '4SA-1011' and ["福州", "厦门", '苏州', "杭州", "上海", "合肥", "福州", "厦门", "深圳", "南京", "广州", "东莞", "佛山", "北京","成都"].include? ycui.city_chinese
      number, key = '4SA-1019', 'c41430f5db8d2e6ce2f4bcbdba60150c'
    end

    require 'digest/md5'

    response = RestClient.post "http://api.formal.4scenter.com/index.php?r=apicar/signup", {mobile: ycui.phone,
                                                                                            name: ycui.name.gsub('(个人)', ''),
                                                                                            city: "#{ycui.city_chinese}市",
                                                                                            brand: ycui.brand,
                                                                                            number: number,
                                                                                            mileage: (ycui.milage).to_i*10000,
                                                                                            car_age: (Date.today.year-ycui.che_ling)*12 ,
                                                                                            sign: Digest::MD5.hexdigest("#{number}#{key}")
                                                                                         }
    response = JSON.parse response.body
    pp response
    ycui.aishi_upload_status = '已上传'
    ycui.aishi_upload_message = response["message"]
    ycui.numbers = number
    ycui.k = key
    if response["error"] == "false"
      ycui.aishi_id = response["result"]["id"]
    end
    ycui.save!
  end


  def self.create_user_info_from_car_user_info car_user_info
    if car_user_info.is_pachong == false and UserSystem::AishiCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin
        if ["苏州"].include? car_user_info.city_chinese
          youyiche_number = UserSystem::YouyicheCarUserInfo.where("phone = ? and youyiche_id is not null", car_user_info.phone).count
          return if youyiche_number > 0
        end

        if ["杭州","上海"].include? car_user_info.city_chinese
          youyiche_number = UserSystem::YouyicheCarUserInfo.where("phone = ? and youyiche_id is not null", car_user_info.phone).count
          return if youyiche_number > 0 and rand(10)>5
        end

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

    cui = UserSystem::AishiCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::AishiCarUserInfo.upload_to_aishi cui

    UserSystem::AishiCarUserInfo.upload_to_aishi UserSystem::AishiCarUserInfo.find(2048165)

  end


  # UserSystem::AishiCarUserInfo.query_aishi
  def self.query_aishi
    return unless (Time.now.hour == 13 or Time.now.hour == 17 or Time.now.hour == 21)
    return unless Time.now.min > 40
    UserSystem::AishiCarUserInfo.batch_query_aishi
  end


  #UserSystem::AishiCarUserInfo.query_chengjiao
  def self.query_chengjiao
    # key = "098f6bcd4621d373cade4e832627b4f6" #正式
    # number = "4SA-1011" #正式
    UserSystem::AishiCarUserInfo.where("aishi_id is not null and id > 100000 and  aishi_yaoyue = '成功'").find_each do |cui|
      # next if cui.aishi_yaoyue == '失败'
      # next if cui.aishi_yaoyue == '成功'
      next if cui.aishi_upload_message.match /交易成功/
      response = RestClient.post 'http://api.formal.4scenter.com/index.php?r=apicar/querysignupone', {number: cui.numbers,
                                                                                                      sign: Digest::MD5.hexdigest("#{cui.numbers}#{cui.k}"),
                                                                                                      id: cui.aishi_id
                                                                                                   }
      response = JSON.parse response.body
      if response["result"]["status"] == '交易成功'
        cui.aishi_upload_message = "#{Date.today.chinese_format_day} 交易成功"
        cui.save!
      end
    end
  end


  # UserSystem::AishiCarUserInfo.batch_query_aishi
  def self.batch_query_aishi
    UserSystem::AishiCarUserInfo.where("aishi_id is not null and id > 1300000 and (aishi_yaoyue is null or aishi_yaoyue = '未知')").find_each do |cui|
      next if cui.aishi_yaoyue == '成功'
      next if cui.aishi_yaoyue == '失败'
      response = nil
      begin
        response = RestClient.post 'http://api.formal.4scenter.com/index.php?r=apicar/querysignupone', {number: cui.numbers,
                                                                                                        sign: Digest::MD5.hexdigest("#{cui.numbers}#{cui.k}"),
                                                                                                        id: cui.aishi_id
                                                                                                     }


      rescue
        pp '接口报错'
        next
      end
      response = JSON.parse response.body
      pp response
      if response["result"]["status"] == '未创建'
        cui.business1_status = '失败'
        cui.business1_name = '未创建'
        cui.aishi_yaoyue = '失败'
        cui.aishi_yaoyue_time = Time.now.chinese_format
        cui.aishi_yaoyue_day = Time.now.chinese_format_day
        cui.save!
        next
      end
      # next if cui.shiai_message == response
      cui.shiai_message = response.to_hash.to_s
      next if response["result"]["status"].blank?

      cui.business_last_status = response["result"]["status"]

      business1_status = begin
        response["result"]["log"][0]["msg"] rescue ''
      end
      business1_name = begin
        response["result"]["log"][0]["name"] rescue ''
      end
      cui.business1_status = business1_status
      cui.business1_name = business1_name
      cui.save!

      # 处理瓜子的情况
      if cui.business1_name == '瓜子'
        cui.aishi_yaoyue = if ['检测成功', '竞拍成功', '竞拍失败', '交易成功', '交易失败'].include? cui.business_last_status
                             '成功'
                           elsif ['创建失败', '检测失败', '邀约失败'].include? cui.business_last_status
                             '失败'
                           else
                             '未知'
                           end
        if cui.changed?
          cui.aishi_yaoyue_time = Time.now.chinese_format
          cui.aishi_yaoyue_day = Time.now.chinese_format_day
        end
        cui.save!
      end

      if cui.business1_name == '又一车'
        cui.aishi_yaoyue = if ['检测成功', '竞拍成功', '竞拍失败', '交易成功', '交易失败'].include? cui.business_last_status
                             '成功'
                           elsif ['创建失败', '检测失败', '邀约失败'].include? cui.business_last_status
                             '失败'
                           else
                             '未知'
                           end
        if cui.changed?
          cui.aishi_yaoyue_time = Time.now.chinese_format
          cui.aishi_yaoyue_day = Time.now.chinese_format_day
        end
        cui.save!
      end

      if cui.business1_name.match /人人/
        cui.aishi_yaoyue = if ['检测成功', '竞拍成功', '竞拍失败', '交易成功', '交易失败','邀约成功'].include? cui.business_last_status
                             '成功'
                           elsif ['创建失败', '检测失败', '邀约失败'].include? cui.business_last_status
                             '失败'
                           else
                             '未知'
                           end
        if cui.changed?
          cui.aishi_yaoyue_time = Time.now.chinese_format
          cui.aishi_yaoyue_day = Time.now.chinese_format_day
        end
        cui.save!
      end

      if cui.business1_name.match /朋友/
        cui.aishi_yaoyue = if ['检测成功', '竞拍成功', '竞拍失败', '交易成功', '交易失败','邀约成功'].include? cui.business_last_status
                             '成功'
                           elsif ['创建失败', '检测失败', '邀约失败'].include? cui.business_last_status
                             '失败'
                           else
                             '未知'
                           end
        if cui.changed?
          cui.aishi_yaoyue_time = Time.now.chinese_format
          cui.aishi_yaoyue_day = Time.now.chinese_format_day
        end
        cui.save!
      end
    end
  end

  # def self.xxx
  #   UserSystem::AishiCarUserInfo.where("aishi_id is not null").find_each do |cui|
  #     pp cui.id
  #     next if cui.business1_status.blank?
  #     next if cui.business1_name != '瓜子'
  #     cui.aishi_yaoyue = if ['检测成功', '竞拍成功', '竞拍失败', '交易成功', '交易失败'].include? cui.business_last_status
  #                          '成功'
  #                        elsif ['创建失败', '检测失败', '邀约失败'].include? cui.business_last_status
  #                          '失败'
  #                        else
  #                          '未知'
  #                        end
  #     cui.save!
  #   end
  # end


end
__END__
