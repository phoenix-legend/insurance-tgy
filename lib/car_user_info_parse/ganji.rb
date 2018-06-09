module Ganji


  def self.test
    # sleep 1000
    # return;

    UserSystem::DeviceAccessLog.set_machine_ip

    1.upto 100000 do |o|

      code  = [0,1,2]
      code.shuffle!
      code.each do |code|
        Ganji.get_car_user_list code, 'web'
      end
    end

  end

  # 多线程获取汽车列表, 多个城市
  # Ganji.get_car_user_list 3
  def self.get_car_user_list party = 0, source = 'web'
    # 如果在表格里配置了userid, 就走api, 否则走网页抓取。
    userids = Ganji.get_user_id_random
    if userids.blank?
      source = 'web'
    else
      source = 'api'
    end


    # if File.exist? '/data/cities_name'
    #   cities = File.read '/data/cities_name'
    #   cities.strip!
    #   cities = cities.split /,|，/
    #   if not cities.blank?
    #     (1..10).each do |i|
    #       city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party, citys
    #       Ganji.get_car_user_list_city_hash city_hash, source
    #     end
    #     return
    #   end
    # end


    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
    Ganji.get_car_user_list_city_hash city_hash, source

  end

  def self.get_user_id_random
    a = UserSystem::GanjiUserId.get_userid
    a[rand(a.length - 1)]
  end

  def self.get_car_user_list_city_hash city_hash, source = 'web'



      code = city_hash.keys
      code.shuffle!

      code.each do |areaid|
        areaname = city_hash[areaid]

        sleep 5+rand(1)

        if source == 'web'
          #走web
          Ganji.get_car_user_list_one_city_web areaname, areaid
        else
          #走api
          Ganji.get_car_user_list_one_city_api_webservice_https areaname, areaid
        end


      end

  end


  # Ganji.get_car_user_list_one_city_api_webservice_https '北京', 'bj'
  def self.get_car_user_list_one_city_api_webservice_https areaname, areaid
    begin
      brand = UserSystem::CarBrand.first
      areaid2 = UserSystem::CarUserInfo::GANJI_CITY_API[areaname]
      code = areaid2
      return if areaid2.blank?
      pp "接口  #{areaname}  #{Time.now.chinese_format}"
      url = "https://app.ganji.com/datashare/HTTP/1.1"
      random_string = EricTools.generate_random_string(6, type = 3)
      integer_string = EricTools.generate_random_string(3, type = 3)
      customerid = "705"
      time = Time.now.chinese_format
      0.upto 1 do |page|
        user_id = Ganji.get_user_id_random
        pp "************** #{user_id}  ****************"
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
                  uniqueid: "00000000-0000-0000-0000-000000000000",
                  aid: user_id,
                  net: 'wifi',
                  lct: '13',
                  clientagent: 'iPhone 7 Plus#375*667#11.2.6',
                  ov: '11.2.6',
                  interface: 'SearchPostsByJson3',
                  customerid: customerid,
                  udid: '00000000-0000-0000-0000-000000000000',
                  userid: user_id
        }

        json_args = {
            pageSize: 40,
            cityScriptIndex: code.to_s,
            sortKeywords: [{"field" => "post_at", "sort" => "desc"}],
            majorCategoryScriptIndex: 1,
            categoryId: 6,
            queryFilters: [{"name" => "agent", "operator" => "=", "value" => "0"},
                           {"name" => "deal_type", "operator" => "=", "value" => "0"},
            ],
            customerid: customerid,
            pageIndex: page,
        }

        request_body ={
            :jsonArgs => json_args.to_json,
            :showType => 0,
            :showtype => 0,
            :t => "-14003#{rand(10)}7094"}

        sleep 2+rand(3)
        response = RestClient.post url, request_body, header

        # pp response
        # response = JSON.parse response.body
        # pp response
        response = JSON.parse response


        # pp response
        car_infos = response["posts"]
        pp "接口 #{car_infos.length} 条记录 #{areaname}"
        car_infos.each do |car_info|
          pp car_info["agent"]
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
      end

      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp e

    end
  end


  #获取一个城市的汽车列表, 从网页获取,


  # cd /data/projects/insurance-tgy/
  def self.auto_set
    etho = `cat     /sys/class/net/eth0/address`
    etho.gsub!("\n", '')
    pp etho
    ethos = etho.split(":")
    1.upto 6 do |k|
      if k == 1
        etho = "#{ethos[0]}:#{ethos[1]}:#{ethos[2]}:#{ethos[3]}:#{ethos[4]}:#{ethos[5]}"
      else
        etho = "#{ethos[0]}:#{ethos[1]}:#{ethos[2]}:#{ethos[3]}:#{ethos[4]}:#{EricTools.generate_random_string(2, 3)}"
      end
      pp etho
      sleep 10

      uid = Ganji.generate_user_id etho
      gui = UserSystem::GanjiUserId.new userid: uid,
                                        host_name: RestClientProxy.get_local_ip
      gui.save
    end


  end

  # Ganji.generate_user_id "52:54:00:5f:11:cd"
  # Ganji.generate_user_id "52:54:00:1a:32:52"      RestClientProxy.get_local_ip    `cat     /sys/class/net/eth0/address`


  def self.generate_user_id mac
    header = {
        "Content-Type" => "application/json",
        "cid" => "801",
        "aid" => "EE062C6D19484800111FE238F088D794",
        "vs" => "8.3.0",
        "ay" => "yingyongbaostore2",
        "rid" => "a5380584-5af6-498f-ace4-2f720cd03b9e",
        "unid" => "9cca3091c0e860e7599a053706269d46",
        "uid" => "",
        "tk" => "",
        "sid" => "b6f46d33-4cbb-40bf-8bb2-663b5cadb293",
        "of" => "self",
        "net" => "wifi",
        "isp" => "46000",
        "os" => "Android",
        "ov" => "22",
        "dv" => "vivo/vivo x6s a",
        "rl" => "720*1280",
        "ds" => 1.5,
        "ct" => "",
        "lng" => "",
        "lat" => "",
        "lct" => "",
        "lar" => "",
        "lbs" => "",
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip",
        "User-Agent" => "Dalvik/2.1.0 (Linux; U; Android 5.1.1; vivo x6s a Build/LMY48Z)",
        "Host" => "app.ganji.com",
        "Connection" => "Keep-Alive"}
    body = {"imei" => "865166027768196", "android_id" => "94b03116b33dd267", "wlan_mac" => mac, "in_code" => "944d1abf21be78d3e4ca5fbdf9ab9d54", "cellid" => "32305", "lac" => "1028"}
    url = "https://app.ganji.com/api/v1/msc/v1/common/installations"
    response = RestClient.post url, body, header
    response = JSON.parse response.body
    pp response["data"]["install_id"]

  end


  # Ganji.batch_user_id 120
  def self.batch_user_id number
    d = []
    1.upto number do |i|
      d << Ganji.generate_user_id("#{EricTools.generate_random_string(2, 3)}:#{EricTools.generate_random_string(2, 3)}:#{EricTools.generate_random_string(2, 3)}:#{EricTools.generate_random_string(2, 3)}:#{EricTools.generate_random_string(2, 3)}:#{EricTools.generate_random_string(2, 3)}")
      sleep 4
    end
    return d
  end


  ################################################################################################################################################################


  # Ganji.get_car_user_list_one_city_web '北京', 'bj'    areaname, areaid = '北京', 'bj'
  def self.get_car_user_list_one_city_web areaname, areaid
    begin
      begin


        user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"

        brand = UserSystem::CarBrand.first
        # url = "http://#{areaid}.ganji.com/ershouche/a1/"
        RestClientProxy.sleep 65
        url = "https://3g.ganji.com/#{areaid}_ershouche/a1/"
        response = RestClient.get url, {
            'User-Agent' => user_agent,
            'Cookie' => 'gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; ganji_uuid=5283133772326517092624; ganji_xuuid=3255599f-19cb-4209-de05-2078bfda3f6a.1497849984212; __utmz=32156897.1509970273.9.3.utmcsr=sh.ganji.com|utmccn=(referral)|utmcmd=referral|utmcct=/; Hm_lvt_8dba7bd668299d5dabbd8190f14e4d34=1523897869; __utma=32156897.2034222174.1460360232.1509970273.1523897870.10; xxzl_deviceid=28o%2Bt%2FAZyncjEX4xCKYb9z0OQAc%2FqMz83sOvCFMS%2B%2B1Gr9igG%2Feos3Cnj221dq0G; GANJISESSID=2s1okeped79pi0fqb8103qt3nf; mobversionbeta=3g; _wap__utmganji_wap_newCaInfo_V2=%7B%22ca_n%22%3A%22-%22%2C%22ca_s%22%3A%22self%22%2C%22ca_i%22%3A%22-%22%7D; Hm_lvt_d486038d25d7a009c28de3dca11595e2=1527854860; gr_session_id_b500fd00659c602c=70a639f5-6a53-4db8-8477-9a39c3602725_true; cityDomain=nmg; ershouche_post_browse_history=3275272413%2C34219398659501%2C2794920596; ershoucheDetailHistory=3275272413-1202-3187; Hm_lvt_42c1a7031efc9970f51536db2fbbfd19=1527857645; firstopen=on; cainfo=%7B%22ca_source%22%3A%22-%22%2C%22ca_name%22%3A%22-%22%7D; _wap__utmganji_wap_caInfo_V2=%7B%22ca_name%22%3A%22zhuzhan2wap_index_%22%2C%22ca_source%22%3A%22-%22%2C%22ca_id%22%3A%22-%22%2C%22ca_kw%22%3A%22-%22%7D; index_city_refuse=refuse; Hm_lpvt_42c1a7031efc9970f51536db2fbbfd19=1527857693; Hm_lpvt_d486038d25d7a009c28de3dca11595e2=1527857745',
            "Referer" => "https://3g.ganji.com/nmg/?a=c&ifid=shouye_chengshi&backURL=ershouche%2Fa1%2F"
        }

        if response.body.match /访问过于频繁|您访问的速度太快|爬虫/
          sleep 30
          pp "被封,访问频繁"
          return
        end

        body = Nokogiri::HTML(response.body)

        # body.css('.list-pic.clearfix.cursor_pointer').each do |clue|
        infos = body.css('.infor')
        pp infos.length
        infos.each do |clue|


          real_url = "https://3g.ganji.com/#{clue.attributes["href"].value}"
          next unless  real_url.match /ershouche/
          next if real_url.match /aozdclick/
          cid = real_url.match /ershouche\/((\d){8,12})x\?/
          cid = cid[1]
          option = {
              cid: cid,
              title: clue.css('.iName').first.content, # 标题
              age: clue.css('.iol').first.content.to_i, # 车龄
              total_km: clue.css('.line_gray').first.content.to_i, # 行驶公里数
              price: clue.css('.price').first.content.to_i, # 价格
          }




          cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: option[:title],
                                                                 che_ling: 2018-option[:age],
                                                                 milage: option[:total_km],
                                                                 detail_url: "http://wap.ganji.com/#{areaid}/ershouche/#{option[:cid]}x",
                                                                 city_chinese: areaname,
                                                                 price: option[:price],
                                                                 site_name: 'ganji',
                                                                 is_cheshang: false,
                                                                 wuba_kouling: real_url


          next if cui_id.blank?

          cui = UserSystem::CarUserInfo.find cui_id


          u = real_url

          #重大调整, 不再更新详情页, 改为提交列表页给小朋
          cid = u.match /ershouche\/(\d{8,15})x/
          cid = cid[1]
          response = RestClient.post 'http://ugods.591order.com/api/clues/upload_cid', source: 'ganji',
                                     cid:cid,
                                     city_name: areaname,
                                     title: option[:title]
          response = JSON.parse(response.body)
          if response["err"].blank?
            c.tt_message = 'xp success'
          else
            c.tt_message = "#{response["err"]}xp"
          end
          c.save
          next


          sleep 20+rand(15)
          response = RestClient.get cui.wuba_kouling,{
              'User-Agent' => user_agent
          }

          body = response.body.encode("UTF-16be", :invalid => :replace, :replace => "?").encode('UTF-8')
          if body.match /访问过于频繁|您访问的速度太快|爬虫/
            sleep 30
            return
          end


          phone_data = body.match /data-phone="(\d{11})"/
          phone = phone_data[1]


          # licensed_at_data = body.match /上牌时间<\/th>\s+<td>(\d{4})-\d{1,2}<\/td>/
          # licensed_at = licensed_at_data[1]

          # total_km_data = body.match /<td>([\d.]+)万公里<\/td>/
          # total_km = total_km_data[1]

          owner_data = body.match /<div class="connect-info fl">\s*<p class="f12">\s*([\u4e00-\u9fa5_a-zA-Z0-9]+)\s*/
          owner = owner_data[1]

          UserSystem::CarUserInfo.update_detail id: cui_id,
                                                name: owner,
                                                phone: phone,
                                                note: '',
                                                fabushijian: Time.now.chinese_format

          sleep 20+rand(15)
        end


      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp $@
      pp e
    end
  end


end