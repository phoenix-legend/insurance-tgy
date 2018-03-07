class UserSystem::JinzhenguCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'
  SIGN = '33f886aa-24a6-4335-8e36-0304215e1e7f'

  CITY = ["北京","深圳","东莞","南宁","郑州","武汉","福州","洛阳","扬州","临沂","长沙","厦门","新乡",
          "徐州","济宁","南京","莆田","南阳","宿迁","苏州","泉州","安阳","无锡","兰州","哈尔滨","赣州","常州",
          "广州","南昌","十堰","沈阳","济南","珠海","襄阳","大连","绵阳","青岛","宜昌",
          "鞍山","遂宁","太原","中山","荆州","呼和浩特","宜宾","西安","佛山","包头","德阳",
          "上海","惠州","常德","南充","成都","株洲","泸州","昆明","柳州","湘潭","烟台","内江","杭州","贵阳","长春","达州","天津",
          "宁波","石家庄","重庆","唐山","合肥","廊坊","蚌埠","邯郸","马鞍山","沧州","芜湖","保定",
          "吉安","运城","南通","菏泽","台州","淮安","淄博","湖州","泰安","金华","潍坊","嘉兴","威海",
          "汕头","大同","咸阳","乌鲁木齐","许昌","大庆","吉林","泰州","德州","锦州","镇江","抚顺","盐城","桂林","绍兴","营口","枣庄","温州","银川","松原","漳州","聊城","日照","东营","乐山","眉山","焦作","辽阳","佳木斯","齐齐哈尔","铁岭","鄂尔多斯","衡水","邢台","临汾","阳泉","长治","承德","秦皇岛","江门","滨州","阜阳","六安","安庆","铜陵","资阳","自贡","曲靖","广安","衢州","信阳","黄石","孝感"
  ]



  # UserSystem::JinzhenguCarUserInfo.create_user_info_from_car_user_info car_user_info
  def self.create_user_info_from_car_user_info car_user_info


    if car_user_info.is_pachong == false and car_user_info.is_real_cheshang == false and UserSystem::JinzhenguCarUserInfo::CITY.include?(car_user_info.city_chinese)
      begin

        UserSystem::JinzhenguCarUserInfo.create_car_info name: car_user_info.name.gsub('(个人)', ''),
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
                                                          jinzhengu_upload_status: '未上传',
                                                          site_name: car_user_info.site_name,
                                                          created_day: car_user_info.tt_created_day
      rescue Exception => e
        pp '更新朋友E车异常'
        pp e
      end
    end
  end

  # 创建优车车主信息
  def self.create_car_info options

    cui = UserSystem::JinzhenguCarUserInfo.find_by_car_user_info_id options[:car_user_info_id]
    return unless cui.blank?

    cui = UserSystem::JinzhenguCarUserInfo.find_by_phone options[:phone]
    return unless cui.blank?

    cui = UserSystem::JinzhenguCarUserInfo.new options
    cui.save!

    cui.created_day = cui.created_at.chinese_format_day
    cui.save!

    UserSystem::JinzhenguCarUserInfo.upload_jinzhengu cui
  end


  def self.upload_jinzhengu yc_car_user_info

    yc_car_user_info.name = yc_car_user_info.name.gsub('(个人)', '')
    yc_car_user_info.save!

    begin
    if yc_car_user_info.phone.blank? #or yc_car_user_info.brand.blank?
      yc_car_user_info.jinzhengu_upload_status = '信息不完整'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.name.blank?
      yc_car_user_info.jinzhengu_upload_status = '姓名不对'
      yc_car_user_info.save!
      return
    end

    unless yc_car_user_info.phone.match /\d{11}/
      yc_car_user_info.jinzhengu_upload_status = '手机号不正确'
      yc_car_user_info.save!
      return
    end

    if not CITY.include? yc_car_user_info.city_chinese
      pp '城市不对'
      yc_car_user_info.jinzhengu_upload_status = '城市不对'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_real_cheshang
      pp '车商'
      yc_car_user_info.jinzhengu_upload_status = '车商'
      yc_car_user_info.save!
      return
    end

    if yc_car_user_info.is_pachong
      pp '爬虫'
      yc_car_user_info.jinzhengu_upload_status = '爬虫'
      yc_car_user_info.save!
      return
    end

    


    cui = yc_car_user_info.car_user_info
    cui.phone_city ||= UserSystem::YoucheCarUserInfo.get_city_name2(yc_car_user_info.phone)
    cui.save!






    rescue
    end


    # response = RestClient.post "http://api.fecar.com/msg/sell", params.to_json, :content_type => 'application/json'

    host_name = "http://clueapi.jingzhengu.com/Interface/JZGReceivingClues.ashx" #正式环境
    param = {
        Sign: SIGN,
        StyleName: cui.brand,
        CityName: cui.city_chinese,
        RegDate: "#{cui.che_ling}年1月",
        Mileage: cui.milage,
        ClueType: '卖车',
        ContactsName: cui.name,
        ContactsPhone: cui.phone
    }



    response = RestClient.post host_name, {
        ClusData: param.to_json
    }



    response = JSON.parse response.body
    pp response

    yc_car_user_info.jinzhengu_upload_status = '已上传'
    if response["status"] == 100
      yc_car_user_info.jinzhengu_id = response["status"]
      yc_car_user_info.jinzhengu_status_message = "#{response['data']}~#{response['msg']}"
    else
      yc_car_user_info.jinzhengu_id = response["status"]
      yc_car_user_info.jinzhengu_status_message = "#{response['data']}~#{response['msg']}"
    end
    yc_car_user_info.save!

  end

end
__END__
