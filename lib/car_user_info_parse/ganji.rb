module Ganji
  # 多线程获取汽车列表, 多个城市
  # Ganji.get_car_user_list 3
  def self.get_car_user_list party = 0
    if File.exist? '/data/cities_name'
      cities = File.read '/data/cities_name'
      cities.strip!
      cities = cities.split /,|，/
      if not cities.blank?
        (1..10).each do |i|
          city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party, citys
          Ganji.get_car_user_list_city_hash city_hash
        end
        return
      end
    end


    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
    Ganji.get_car_user_list_city_hash city_hash

  end

  def self.get_car_user_list_city_hash city_hash

    (1..10).each do |i|
      city_hash.each_pair do |areaid, areaname|
        sleep rand(5)+2
        Ganji.get_car_user_list_one_city_api_webservice_https areaname, areaid
      end
    end
  end


  # Ganji.get_car_user_list_one_city_api_webservice_https '北京', 'bj'
  def self.get_car_user_list_one_city_api_webservice_https areaname, areaid
    begin
      brand = UserSystem::CarBrand.first
      areaid2 = UserSystem::CarUserInfo::GANJI_CITY_API[areaname]
      return if areaid2.blank?
      pp "接口  #{areaname}  #{Time.now.chinese_format}"
      url = "https://app.ganji.com/datashare/HTTP/1.1"
      random_string = EricTools.generate_random_string(6, type = 3)
      integer_string = EricTools.generate_random_string(3, type = 3)
      customerid = "705"
      time = Time.now.chinese_format
      # heder = {host: 'app.ganji.com',
      #          uid: '',
      #          contentformat: 'json2',
      #          "gjdata-version" => '1.0',
      #          accept: '*/*',
      #          sid: "213AD020-B832-4BC2-B166-DC7F59C992A5",
      #          lbs: '',
      #          clienttimestamp: time,
      #          agency: 'appstore',
      #          'content-length' => 275,
      #          cookie: " cityDomain=#{areaid}; mobversionbeta=3g; GANJISESSID=01000148d9e44aa1118ac24b7c76f76d; __utmganji_v20110909=b250e28e-dcdb-43e3-809a-51edf4e87c59",
      #          'user-agent' => 'GJLife/7.9.11 CFNetwork/811.5.4 Darwin/16.6.0',
      #          cityscriptindex: areaid2,
      #          isp: '46002',
      #          vs: '7.9.11',
      #          unid: "5A5F7809-FCCE-408F-9314-9F66F22DF62B",
      #          versionid: '7.9.11',
      #          lar: '174',
      #          rl: '375*667',
      #          seqid: "62FEFCD7-B308-4510-941B-#{random_string}6246E6",
      #          model: 'Generic/iphone',
      #          'accept-language' => 'zh-cn',
      #          lng: 116.483742, #"11#{rand(3)+3}.#{integer_string}788",
      #          ct: '12',
      #          tk: '',
      #          cid: '705',
      #          os: 'iOS',
      #          lat: 39.996632, #"3#{rand(3)+3}.#{integer_string}681",
      #          ay: 'appstore',
      #          'content-type' => 'application/x-www-form-urlencoded',
      #          clienttest: 'false',
      #          of: 'self',
      #          rid: "5366013A-DC83-42A6-8182-52860EC60BB9", #"15985A0D-C062-4312-A778-49#{random_string}B610",
      #          connection: 'keep-alive',
      #          dv: 'iPhone 6S',
      #          uniqueid: "5A5F7809-FCCE-408F-9314-9F66F22DF62B", #"5A5F7809-FCCE-408F-9314-#{random_string}2DF62B",
      #          aid: " 9577341F88ABAAA36DFD4B9732317AA1", #"9577341F88AB#{random_string}AA4B9732317AA1",
      #          net: 'wifi',
      #          lct: '12',
      #          clientagent: 'iPhone 6S#375*667#10.3.2',
      #          ov: '10.3.2',
      #          interface: 'SearchPostsByJson3',
      #          customerid: customerid,
      #          userid: "9577341F88ABAAA36DFD4B9732317AA1"
      # }


      header = {host: 'app.ganji.com',
                uid: '',
                contentformat: 'json2',
                "gjdata-version" => '1.0',
                accept: '*/*',
                sid: "46493C8B-5CEF-4BB7-B70C-68C3AA7B5985",
                xasmaid: 'smartid null',
                lbs: '',
                clienttimestamp: time,
                agency: 'appstore',
                'content-length' => 275,
                cookie: "GANJISESSID=msncj1f72nbt6dil23lfr7pcem",
                'user-agent' => 'GJLife/8.7.0 CFNetwork/894 Darwin/17.4.0',
                cityscriptindex: code,
                isp: '46002',
                vs: '8.7.0',
                xadid: 'mngUubSQjS365TxDlWW09qD/w8z4wvXU0OnAJVyJyq24HEDSSNeK8p3naqeksoiZ',
                unid: "00000000-0000-0000-0000-000000000000",
                versionid: '8.7.0',
                lar: '208',
                rl: '375*667',
                seqid: "5BF7804D-F73F-472B-9EA2-7D3C8A43E7CA",
                model: 'Generic/iphone',
                'accept-language' => 'zh-cn',
                lng: 121.406670,

                ct: '13',
                tk: '',
                cid: '705',
                os: 'iOS',
                lat: 30.908260,

                ay: 'appstore',
                'content-type' => 'application/x-www-form-urlencoded',
                clienttest: 'false',
                of: 'self',
                rid: "C60EF675-7FF7-4621-929E-20956C6A7304",
                connection: 'keep-alive',
                dv: 'iPhone 7 Plus',
                uniqueid: "00000000-0000-0000-0000-000000000000", #"5A5F7809-FCCE-408F-9314-#{random_string}2DF62B",
                aid: " 293079DA64CE1187C116570734B2E931",#"9577341F88AB#{random_string}AA4B9732317AA1",
                net: 'wifi',
                lct: '13',
                clientagent: 'iPhone 7 Plus#375*667#11.2.6',
                ov: '11.2.6',
                interface: 'SearchPostsByJson3',
                customerid: customerid,
                udid: '00000000-0000-0000-0000-000000000000',
                userid: "293079DA64CE1187C116570734B2E931"
      }

      json_args = {
          pageSize: 40,
          cityScriptIndex: areaid2.to_s,
          # sortKeywords: [{"field" => "post_at","sort" => "desc"}],
          majorCategoryScriptIndex: 1,
          categoryId: 6,
          queryFilters: [{"name" => "agent", "operator" => "=", "value" => "0"},
                         {"name" => "deal_type", "operator" => "=", "value" => "0"},
          # "name" => "sort","operator" => "=","value" => "2"
          ],
          customerid: customerid,
          pageIndex: 0,
      }


      request_body ={
          :jsonArgs => json_args.to_json,
          :showType => 0,
          :showtype => 0,
          :t => "-14003#{rand(10)}7094"}

      response = RestClient.post url, request_body, heder

      # response = JSON.parse response.body
      response = JSON.parse response

      pp response

      # pp response
      car_infos = response["posts"]
      pp "接口 #{car_infos.length} 条记录 #{areaname}"
      car_infos.each do |car_info|
        next if car_info["agent"] != "个人"

        # k = car_info["detail_url"].match /puid=(\d*)&/
        car_ganji_number = car_info["puid"]
        next if car_ganji_number.blank?
        url = "http://wap.ganji.com/#{areaid}/ershouche/#{car_ganji_number}x"

        chexing = car_info["title"]
        cheling = car_info["license_year"]
        licheng = car_info["road_haul"].to_i
        price = car_info["price"]["v"]
        is_cheshang = false

        cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
                                                               che_ling: cheling,
                                                               milage: licheng,
                                                               detail_url: url,
                                                               city_chinese: areaname,
                                                               price: price,
                                                               site_name: 'ganji',
                                                               is_cheshang: is_cheshang


        unless cui_id.blank?
          UserSystem::CarUserInfo.update_detail id: cui_id,
                                                name: '车主',
                                                phone: car_info['phone'],
                                                note: '',
                                                fabushijian: Time.now.chinese_format
        end
      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp e
    end
  end

  #获取一个城市的汽车列表, 从网页获取,


  # {"agent" => "个人",
  #  "CategoryName" => "车辆买卖",
  #  "CategoryId" => "6",
  #  "d_sign" => "||",
  #  "district_name" => "虹口",
  #  "puid" => "2682549345",
  #  "major_category" => "1",
  #  "majorCategoryName" => "二手车",
  #  "person" => "先生",
  #  "street_name" => "",
  #  "PostAtText" => "2分钟前",
  #  "price" => {"u" => "元", "v" => "75000"},
  #  "thumb_img" => "gjfsqq/v1bkujjd4jiuxfs7tyvjha_82-52c_6-0.jpg",
  #  "title" => "荣威7502012款 1.8T 手自一体 HYBRID混合动力版 油电混合 无事故",
  #  "url" => "ershouche",
  #  "city_index" => "100",
  #  "city" => "上海市",
  #  "UniqueId" => "N3100001100125743049",
  #  "id" => "25743049",
  #  "user_id" => "594553245",
  #  "username" => "",
  #  "more_desc" => 0,
  #  "description" =>
  #      "出售2012年荣威750一辆 1.8T油电混合动力 自排 天窗 最高配置 车子跑了5万公里路 无事故车况如新 油电混合 百公里油耗5升 自行发电不用充电 上海牌照 国4排放标准 新车入手30万 原车照片 喜欢电聊",
  #  "post_at" => "16:04",
  #  "refresh_at" => "16:04",
  #  "show_time" => "16:04",
  #  "phone" => "13761797514",
  #  "minor_category_name" => "荣威",
  #  "minor_category_url" => "rongwei",
  #  "listing_status" => {"v" => "5", "t" => "正常显示在列表页"},
  #  "display_status" => {"v" => 0, "t" => "用户个人删除"},
  #  "editor_audit_status" => {"v" => nil, "t" => nil},
  #  "show_before_audit" => "否",
  #  "post_type" => {"v" => "0", "t" => "普通贴"},
  #  "minor_category" => "1293",
  #  "tag" => "3212",
  #  "postunixtime" => "1497859440",
  #  "domain" => "sh",
  #  "latlng" => "",
  #  "detail_url" =>
  #      "http://3g.ganji.com/misc/weixin/?domain=sh&url=ershouche&puid=2682549345&from=shenghuo_qqweixin_detail",
  #  "icons" => {"ding" => "0", "image" => "1", "yan" => "0"},
  #  "biz_post_type" => "0",
  #  "district_id" => "5",
  #  "street_id" => "-1",
  #  "image_count" => "6",
  #  "im" => "",
  #  "seats" => "",
  #  "deal_type" => {"v" => "0", "t" => "转让"},
  #  "pin_che_start" => "",
  #  "pin_che_end" => "",
  #  "car_color" => {"v" => "1", "t" => "黑色"},
  #  "gearbox" => {"v" => "2", "t" => "自动"},
  #  "air_displacement" => "1",
  #  "license_date" => "5",
  #  "license_year" => "2012",
  #  "license_math" => "",
  #  "road_haul" => 5,
  #  "tag_name" => "750",
  #  "tag_url" => "rongwei750",
  #  "user_defined_category" => "",
  #  "uses" => {"v" => "", "t" => nil},
  #  "maintenance_records" => {"v" => "", "t" => nil},
  #  "iconsInfo" => {"labels" => [], "normalIcons" => []},
  #  "resize_thumb_img" =>
  #      "http://tct5.ganjistatic1.com/gjfsqq/v1bkujjd4jiuxfs7tyvjha_147-109c_7-0.jpg",
  #  "link_info" =>
  #      {"textHref" =>
  #           {"href" =>
  #                "http://jinrong.58.com/m/loan/k?from=ganji_app_esc_fzx_detail_an&gj_other_uuid=529292830&gj_other_ifid=from_ganji&gj_other_client_id=801&gj_other_version=7.3.1&gj_other_unique_id=93c6fcc41a2fbcb954a10a1bd87c53cb&gj_other_agency=eoe01&gj_other_gc_1=che",
  #            "title" => "买车钱不够，我来凑点钱>>"},
  #       "status" => 0,
  #       "errMessage" => "成功"}}


end