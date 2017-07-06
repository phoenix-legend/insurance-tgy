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
          Ganji.get_car_user_list_one_city_list 1, cities
        end

        return
      end
    end


    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
    (1..10).each do |i|
      city_hash.each_pair do |areaid, areaname|
        if Thread.list.length > 1  #大并发为8
          while true
            if Thread.list.length < 2 #大并发为10
              break
            else
              sleep 0.2
            end
          end
        end
        sleep 0.3
        Thread.start do
          # Ganji.get_car_user_list_one_city areaname, areaid
          Ganji.get_car_user_list_one_city_api_webservice areaname, areaid
        end
      end
    end

    if party == 0 and RestClientProxy.get_local_ip == RestClientProxy::HOSTNAME_WUBA1
      Ganji.get_car_user_list 1
      Ganji.get_car_user_list 2
    end
  end


  # 多线程获取汽车列表, 一个城市
  # Ganji.get_car_user_list_one_city_list 1, ['上海']
  def self.get_car_user_list_one_city_list party, citys

    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party, citys
    (1..10).each do |i|
      city_hash.each_pair do |areaid, areaname|


        pp "活线程数量 #{Thread.list.length} "
        if Thread.list.length > 1  #大并发为8
          while true
            if Thread.list.length < 2  #大并发为10
              break
            else
              sleep 0.5
            end
          end
        end
        sleep 0.4
        Thread.start do
          Ganji.get_car_user_list_one_city_api_webservice areaname, areaid
        end
      end
    end


  end


  # 获取一个城市的汽车列表, 从api获取
  def self.get_car_user_list_one_city_api_webservice areaname, areaid
    begin
      # areaid2 = 100

      brand = UserSystem::CarBrand.first

      areaid2 = UserSystem::CarUserInfo::GANJI_CITY_API[areaname]
      if areaid2.blank?
        pp "网页  #{areaname}  #{Time.now.chinese_format}"
        Ganji.get_car_user_list_one_city areaname, areaid
        return
      end
      pp "接口  #{areaname}  #{Time.now.chinese_format}"
      url = "http://mobapi.ganji.com/datashare/HTTP/1.1"
      customerid = "801"
      userid = "DE361EB315646E5CCF29674326801321"
      # response = RestClient.post url,
      response = RestClientProxy.post url,
                                 {jsonArgs: '{"customerId":"'+customerid+'","cityScriptIndex":"'+ "#{areaid2}" +'","categoryId":"6","pageIndex":"0","pageSize":"40","majorCategoryScriptIndex":"1","queryFilters":[{"name":"deal_type","operator":"=","value":"0"},{"name":"agent","operator":"=","value":"0"}],"sortKeywords":[{"field":"post_at","sort":"desc"}]}',
                                  showType: 0},
                                 {'User-Agent' => "Dalvik/2.1.0 (Linux; U; Android 6.0.1; SM-G6100 Build/MMB29M)",
                                  'interface' => "SearchPostsByJson2",
                                  'agehcy' => 'eoe01',
                                  'userId' => userid,
                                  'versionId' => '7.3.1',
                                  'model' => 'samsung/SM-G6100',
                                  'contentformat' => 'json2',
                                  'CustomerId' => customerid,
                                  'clientAgent' => 'samsung/SM-G6100#1080*1920#3.0#6.0.1',
                                  'GjData-Version' => '1.0',
                                  'uniqueId' => '93c6fcc41a2fbcb954a10a1bd87c53cb',
                                 }
      # response = JSON.parse response.body
      response = JSON.parse response

      # pp response
      car_infos = response["posts"]
      pp "接口 #{car_infos.length} 条记录 #{areaname}"
      car_infos.each do |car_info|

        k = car_info["detail_url"].match /puid=(\d*)&/
        car_ganji_number = k[1]
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
          begin
            Ganji.update_one_detail cui_id
          rescue Exception => e
            ActiveRecord::Base.connection.close
            pp "赶集出错"
            pp e
          end
        end
      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp e
    end
  end

  #获取一个城市的汽车列表, 从网页获取,
  def self.get_car_user_list_one_city areaname, areaid
    begin
      # pp "现在跑赶集.. #{areaname}"
      brand = UserSystem::CarBrand.first

      url = "http://#{areaid}.ganji.com/ershouche/a1/"
      # pp "发起请求 #{areaname}  #{Time.now}"
      content = RestClientProxy.get url, {
          'User-Agent' => RestClientProxy.rand_ua ,
          'Cookie' => 'gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; cityDomain=hz; webimverran=82; ganji_uuid=5283133772326517092624; ganji_xuuid=3255599f-19cb-4209-de05-2078bfda3f6a.1497849984212; __utmt=1; GANJISESSID=6ffddb27ce3486fbabbe75da706e56bb; _gl_tracker=%7B%22ca_source%22%3A%22-%22%2C%22ca_name%22%3A%22-%22%2C%22ca_kw%22%3A%22-%22%2C%22ca_id%22%3A%22-%22%2C%22ca_s%22%3A%22self%22%2C%22ca_n%22%3A%22-%22%2C%22ca_i%22%3A%22-%22%2C%22sid%22%3A48384010257%7D; __utma=32156897.2034222174.1460360232.1490174031.1497849984.7; __utmb=32156897.4.10.1497849984; __utmc=32156897; __utmz=32156897.1490168931.5.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); Hm_lvt_8dba7bd668299d5dabbd8190f14e4d34=1497849984; Hm_lpvt_8dba7bd668299d5dabbd8190f14e4d34=1497850043; ganji_login_act=1497850043498; lg=1; vehicle_list_view_type=1'
      }
      # pp "收到请求 #{areaname} #{Time.now}"
      # content = content.body


      content.gsub!('list-pic clearfix cursor_pointer ', 'dlclass')
      content.gsub!('comNum js-price', 'priceclass')

      content = Nokogiri::HTML(content)


      car_infos = content.css('.dlclass')
      # car_infos = content.css(".list-item")
      pp "car infos length is #{car_infos.length}"
      return if car_infos.blank?

      car_infos.each do |car_info|
        if car_info.to_s.match /ico-stick-yellow/
          pp '置'
          next
        end

        if car_info.to_s.match /商家/
          pp '商'
          next
        end

        car_ganji_number = begin
          car_info.attributes["id"].value rescue ''
        end
        next if car_ganji_number.blank?
        car_ganji_number.gsub!('puid-', '')
        url = "http://wap.ganji.com/#{areaid}/ershouche/#{car_ganji_number}x"
        chexing = car_info.css('.infor .infor-titbox a').text
        cheling = car_info.css('.infor .infor-dep .js-license strong').text
        licheng = car_info.css('.infor .infor-dep .js-roadHaul strong').text.to_i
        cheling.gsub!('年', '')
        cheling = Date.today.year - cheling.to_i
        price = car_info.css('.priceclass').text
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
          begin
            Ganji.update_one_detail cui_id
          rescue Exception => e
            pp "赶集出错"
            pp e
          end
        end
      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp e
    end
  end


  def self.update_one_detail car_user_info_id
    # car_user_info_id = 9880700
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/
    system_name = Personal::Role.system_name
    if system_name == 'ali'
      response = RestClient.post 'http://che.uguoyuan.cn/api/v1/update_user_infos/vps_urls', {urls: car_user_info.detail_url}
      response = JSON.parse(response.body)

      detail_urls = response["data"]

      if detail_urls.blank?
        car_user_info.tt_upload_status = 'skip'
        car_user_info.save!
        return
      end
    end


    begin
      pp "开始跑明细 #{car_user_info.id}"
      # sleep 1+rand(2) if RestClientProxy.get_local_ip != '10-19-104-142'
      # response = RestClient.get(car_user_info.detail_url, {
      #     'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
      #     'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
      # })
      # response = response.body

      response = RestClientProxy.get(car_user_info.detail_url, {
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
          'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
      })



      # response = RestClientProxy.get car_user_info.detail_url, {}
      # detail_content = response.body
      # pp detail_content
      # detail_content = detail_content.force_encoding('UTF-8')
      detail_content = response

      # if ! detail_content.valid_encoding?
      #   detail_content = detail_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      # end

      if detail_content.match /您访问的速度太快|爬虫/
        redis = Redis.current
        redis[car_user_info.detail_url] = 'n'
        redis.expire car_user_info.detail_url, 60
        sleep 30

        car_user_info.destroy
      end
      # pp '-----'
      # pp detail_content
      # pp '-----'

      detail_content = Nokogiri::HTML(detail_content)
      detail_content = detail_content.css('.mod-detail')
      fabushijian = Time.now.strftime("%m-%d")
      begin
        fabushijian = detail_content.css('.detail-meta span')[0].text
        fabushijian.strip!
        fabushijian.gsub!('发布:', '')
      rescue Exception => e
      end

      phone = detail_content.css('.phone-contact a')[0].attributes['href'].value.gsub('tel:', '')


      name = ''
      note = ''
      details = detail_content.css('.detail-describe p')
      is_cheshang = "0"
      details.each do |detail|
        case detail.text
          when /详细信息/
            note = detail.text
            note.gsub!('详细信息：', '')
          when /联系人/
            name = detail.text
            if name.match /商家/
              is_cheshang = '1'
            end
            name.gsub!('联系人：', '')
            name.gsub!(/\[商家\]|\[个人\]/, '')
        end
      end

      # phone = detail_content.css('.tel-area-phone')[0].attributes["data-phone"].value

      # name = detail_content.css('.car-shop').css('p')[0].text
      # name.gsub!(/\s|\n|个人|联系人/, '')
      #
      # note = detail_content.css('.comm-area').text
      # note.gsub!('  ', '')
      # note.gsub!(/\r|\n/, '')


      # fabushijian = begin
      #   detail_content.css('.fabushijian').text[0..10] rescue '刚刚'
      # end


      pp "开始跑明细 #{car_user_info.id}  准备更新"
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            fabushijian: fabushijian,
                                            is_cheshang: is_cheshang
      ActiveRecord::Base.connection.close

    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp '-------------------------------------'
      pp e
      pp $@
      # pp detail_content
      redis = Redis.current
      redis[car_user_info.detail_url] = 'n'
      redis.expire car_user_info.detail_url, 60
      car_user_info.destroy
      # car_user_info.need_update = false
      # car_user_info.save
    end


  end


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


  # {'User-Agent' => "Dalvik/2.1.0 (Linux; U; Android 6.0.1; SM-G6100 Build/MMB29M)",
  #  'interface' => "SearchPostsByJson2",
  #  'agency' => 'eoe01',
  #  'userId' => 'DE361EB315646E5CCF29674326801321',
  #  'versionId' => '7.3.1',
  #  'model' => 'samsung/SM-G6100',
  #  'contentformat' => 'json2',
  #  'CustomerId' => '801',
  #  'clientAgent' => 'samsung/SM-G6100#1080*1920#3.0#6.0.1',
  #  'GjData-Version' => '1.0',
  #  'uniqueId' => '93c6fcc41a2fbcb954a10a1bd87c53cb',
  # }


  #  Ganji.get_car_user_list  单线程sleep 版
  # def self.get_car_user_list_danxiancheng party = 0
  #
  #   # return if Time.now.hour > 2 and Time.now.hour < 4
  #
  #   city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
  #
  #   city_hash.each_pair do |areaid, areaname|
  #     begin
  #       pp "现在跑赶集.. #{areaname}"
  #       1.upto 1 do |i|
  #         url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
  #
  #         content = RestClient.get url, {
  #             'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  #             'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
  #
  #         }
  #         content = content.body
  #
  #         content = Nokogiri::HTML(content)
  #         car_infos = content.css(".list-item")
  #         pp "car infos length is #{car_infos.length}"
  #         break if car_infos.blank?
  #         car_number = car_infos.length
  #         exists_car_number = 0
  #         car_infos.each do |car_info|
  #           url = car_info.css('a')[0].attributes["href"].value
  #           url = url.split('?')[0]
  #           chexing = car_info.css('a')[0].text
  #           cheling_licheng = car_info.css('.meta')[0].text
  #           cheling_licheng.strip!
  #           cheling = cheling_licheng.split('/')[0]
  #           licheng = cheling_licheng.split('/')[1]
  #           cheling.gsub!('年', '')
  #           cheling = Date.today.year - cheling.to_i
  #           price = car_info.css('.price').text
  #           is_cheshang = false
  #           cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
  #                                                                  che_ling: cheling,
  #                                                                  milage: licheng,
  #                                                                  detail_url: url,
  #                                                                  city_chinese: areaname,
  #                                                                  price: price,
  #                                                                  site_name: 'ganji',
  #                                                                  is_cheshang: is_cheshang
  #
  #
  #           unless cui_id.blank?
  #             begin
  #               Ganji.update_one_detail cui_id
  #             rescue Exception => e
  #               pp "赶集出错"
  #               pp e
  #             end
  #           end
  #           exists_car_number = exists_car_number + 1 if cui_id.blank?
  #         end
  #         # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
  #         if car_number - exists_car_number < 3
  #           puts '赶集 本页数据全部存在，跳出'
  #           break
  #         end
  #       end
  #       ActiveRecord::Base.connection.close
  #
  #     rescue Exception => e
  #       ActiveRecord::Base.connection.close
  #       pp e
  #     end
  #   end
  # end

  #  Ganji.get_car_user_list_mult_threads 多线程 3g版
  # def self.get_car_user_list_3g party = 0
  #
  #   city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
  #   threads = []
  #   city_hash.each_pair do |areaid, areaname|
  #     if threads.length > 10
  #       while true
  #         threads.delete_if { |thread| thread.status == false }
  #         if threads.length < 3
  #           break
  #         else
  #           sleep 0.5
  #         end
  #       end
  #     end
  #     t = Thread.new do
  #       begin
  #         pp "现在跑赶集.. #{areaname}"
  #         1.upto 1 do |i|
  #           url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
  #           content = RestClient.get url, {
  #               'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  #               'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
  #
  #           }
  #           content = content.body
  #           content = Nokogiri::HTML(content)
  #           car_infos = content.css(".list-item")
  #           pp "car infos length is #{car_infos.length}"
  #           break if car_infos.blank?
  #           car_number = car_infos.length
  #           exists_car_number = 0
  #           car_infos.each do |car_info|
  #             url = car_info.css('a')[0].attributes["href"].value
  #             url = url.split('?')[0]
  #             chexing = car_info.css('a')[0].text
  #             cheling_licheng = car_info.css('.meta')[0].text
  #             cheling_licheng.strip!
  #             cheling = cheling_licheng.split('/')[0]
  #             licheng = cheling_licheng.split('/')[1]
  #             cheling.gsub!('年', '')
  #             cheling = Date.today.year - cheling.to_i
  #             price = car_info.css('.price').text
  #             is_cheshang = false
  #             cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
  #                                                                    che_ling: cheling,
  #                                                                    milage: licheng,
  #                                                                    detail_url: url,
  #                                                                    city_chinese: areaname,
  #                                                                    price: price,
  #                                                                    site_name: 'ganji',
  #                                                                    is_cheshang: is_cheshang
  #
  #
  #             unless cui_id.blank?
  #               begin
  #                 Ganji.update_one_detail cui_id
  #               rescue Exception => e
  #                 pp "赶集出错"
  #                 pp e
  #               end
  #             end
  #             exists_car_number = exists_car_number + 1 if cui_id.blank?
  #           end
  #           # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
  #           if car_number - exists_car_number < 3
  #             puts '赶集 本页数据全部存在，跳出'
  #             break
  #           end
  #         end
  #       rescue Exception => e
  #         pp e
  #       end
  #     end
  #     threads << t
  #   end
  #   1.upto(2000) do
  #     sleep(1)
  #     # pp '休息.......'
  #     threads.delete_if { |thread| thread.status == false }
  #     break if threads.blank?
  #   end
  # end


end