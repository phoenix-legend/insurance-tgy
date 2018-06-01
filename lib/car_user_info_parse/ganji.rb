module Ganji


  def self.test
    1.upto 100000 do |o|


      Ganji.get_car_user_list 2, 'web'
      Ganji.get_car_user_list 0, 'web'
      Ganji.get_car_user_list 1, 'web'

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

    (1..10).each do |i|
      city_hash.each_pair do |areaid, areaname|
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


  # Ganji.get_car_user_list_one_city_web '北京', 'bj'
  def self.get_car_user_list_one_city_web areaname, areaid
    begin
      begin

        user_agents = ["Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1", "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0", "Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0", "Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/29.0", "Mozilla/5.0 (X11; OpenBSD amd64; rv:28.0) Gecko/20100101 Firefox/28.0", "Mozilla/5.0 (X11; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0", "Mozilla/5.0 (Windows NT 6.1; rv:27.3) Gecko/20130101 Firefox/27.3", "Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:27.0) Gecko/20121011 Firefox/27.0", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1 QIHU 360SE", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17 QIHU 360EE", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36 QIHU 360SE", "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; 360SE)", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/1.0.154.53 Safari/525.19", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/1.0.154.36 Safari/525.19", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/7.0.540.0 Safari/534.10", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.4 (KHTML, like Gecko) Chrome/6.0.481.0 Safari/534.4", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.86 Safari/533.4", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.2 (KHTML, like Gecko) Chrome/4.0.223.3 Safari/532.2", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/4.0.201.1 Safari/532.0", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/3.0.195.27 Safari/532.0", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/530.5 (KHTML, like Gecko) Chrome/2.0.173.1 Safari/530.5", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.558.0 Safari/534.10", "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/540.0 (KHTML,like Gecko) Chrome/9.1.0.0 Safari/540.0", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.14 (KHTML, like Gecko) Chrome/9.0.600.0 Safari/534.14", "Mozilla/5.0 (X11; U; Windows NT 6; en-US) AppleWebKit/534.12 (KHTML, like Gecko) Chrome/9.0.587.0 Safari/534.12", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.0 Safari/534.13", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.11 Safari/534.16", "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.20 (KHTML, like Gecko) Chrome/11.0.672.2 Safari/534.20", "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.792.0 Safari/535.1", "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.872.0 Safari/535.2", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.36 Safari/535.7", "Mozilla/5.0 (Windows NT 6.0; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.66 Safari/535.11", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.45 Safari/535.19", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/535.24 (KHTML, like Gecko) Chrome/19.0.1055.1 Safari/535.24", "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.6 (KHTML, like Gecko) Chrome/20.0.1090.0 Safari/536.6", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/22.0.1207.1 Safari/537.1", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.15 (KHTML, like Gecko) Chrome/24.0.1295.0 Safari/537.15", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36", "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1467.0 Safari/537.36", "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1623.0 Safari/537.36", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.103 Safari/537.36", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.38 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", "Opera/5.11 (Windows 98; U) [en]", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98) Opera 5.12 [en]", "Opera/6.0 (Windows 2000; U) [fr]", "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT 4.0) Opera 6.01 [en]", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) Opera 7.10 [en]", "Opera/9.02 (Windows XP; U; ru)", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en) Opera 9.24", "Opera/9.51 (Macintosh; Intel Mac OS X; U; en)", "Opera/9.70 (Linux i686 ; U; en) Presto/2.2.1", "Opera/9.80 (Windows NT 5.1; U; cs) Presto/2.2.15 Version/10.00", "Opera/9.80 (Windows NT 6.1; U; sv) Presto/2.7.62 Version/11.01", "Opera/9.80 (Windows NT 6.1; U; en-GB) Presto/2.7.62 Version/11.00", "Opera/9.80 (Windows NT 6.1; U; zh-tw) Presto/2.7.62 Version/11.01", "Opera/9.80 (Windows NT 6.0; U; en) Presto/2.8.99 Version/11.10", "Opera/9.80 (X11; Linux i686; U; ru) Presto/2.8.131 Version/11.11", "Opera/9.80 (Windows NT 5.1) Presto/2.12.388 Version/12.14", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.12 Safari/537.36 OPR/14.0.1116.4", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.29 Safari/537.36 OPR/15.0.1147.24 (Edition Next)", "Opera/9.80 (Linux armv6l ; U; CE-HTML/1.0 NETTV/3.0.1;; en) Presto/2.6.33 Version/10.60", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36 OPR/20.0.1387.91", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Oupeng/10.2.1.86910 Safari/534.30", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36 OPR/26.0.1656.60", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36 OPR/31.0.1857.0", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36 OPR/32.0.1948.25", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; fi-fi) AppleWebKit/420+ (KHTML, like Gecko) Safari/419.3", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; de-de) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.7", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/312.8 (KHTML, like Gecko) Safari/312.6", "Mozilla/5.0 (Windows; U; Windows NT 5.1; cs-CZ) AppleWebKit/523.15 (KHTML, like Gecko) Version/3.0 Safari/523.15", "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_5_6; it-it) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16", "Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-HK) AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5", "Mozilla/5.0 (Windows; U; Windows NT 6.1; sv-SE) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/6.1.3 Safari/537.75.14", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.3.10 (KHTML, like Gecko) Version/8.0.3 Safari/600.3.10", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.39 (KHTML, like Gecko) Version/9.0 Safari/601.1.39", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13) AppleWebKit/603.1.13 (KHTML, like Gecko) Version/10.1 Safari/603.1.13"]
        user_agent = user_agents[rand(90)]

        brand = UserSystem::CarBrand.first
        url = "http://#{areaid}.ganji.com/ershouche/a1/"
        response = RestClient.get url, {
            'User-Agent' => user_agent,
            'Cookie' => '58uuid=8a7e90f0-4ee1-488b-a7b6-1cce58a5274d; ASP.NET_SessionId=ASP.NET_SessionId; ErshoucheDetailPageScreenType=1280; GANJISESSID=bebpra2e3mo4ftbmhfun5gh327; Hm_lpvt_8dba7bd668299d5dabbd8190f14e4d34=1524230889; Hm_lvt_8dba7bd668299d5dabbd8190f14e4d34=1522121510,1524067933; __utma=32156897.987309773.1522121513.1524067936.1524229740.13; __utmb=32156897.9.10.1524229740; __utmc=32156897; __utmganji_v20110909=accfae81-7dd4-4f7c-b53d-5ab8630d8390; __utmt=1; __utmz=32156897.1524067936.12.10.utmcsr=sz.ganji.com|utmccn=(referral)|utmcmd=referral|utmcct=/; _gl_tracker=%7B%22ca_source%22%3A%22-%22%2C%22ca_name%22%3A%22-%22%2C%22ca_kw%22%3A%22-%22%2C%22ca_id%22%3A%22-%22%2C%22ca_s%22%3A%22self%22%2C%22ca_n%22%3A%22-%22%2C%22ca_i%22%3A%22-%22%2C%22sid%22%3A729790238%7D; _wap__utmganji_wap_caInfo_V2=%7B%22ca_name%22%3A%22-%22%2C%22ca_source%22%3A%22-%22%2C%22ca_id%22%3A%22-%22%2C%22ca_kw%22%3A%22-%22%7D; _wap__utmganji_wap_newCaInfo_V2=%7B%22ca_n%22%3A%22-%22%2C%22ca_s%22%3A%22self%22%2C%22ca_i%22%3A%22-%22%7D; als=0; cityDomain=bj; citydomain=bj; ganji_login_act=1524230893474; ganji_uuid=4143608234090131128650; ganji_xuuid=62952546-bbf5-48cf-913f-ea8587af686a.1522121506362; gr_user_id=a0664bfa-d41b-498d-9850-c1984ff6b757; init_refer=http%253A%252F%252Fsh.ganji.com%252Fershouche%252Fa1%252F; is_fold_show_more=0; mobversionbeta=3g; new_session=0; new_uv=11; statistics_clientid=me; statistics_clientid=me; vehicle_list_view_type=2; xxzl_deviceid=Fq4oiksDRumZZDm%2B7P9PU3Y1IW8gm8GTQ2xnIEG5I6v%2FSsaBYTBEWgneJP%2BhGbAb;'
        }

        if response.body.match /访问过于频繁|您访问的速度太快|爬虫/
          sleep 30
          pp "被封,访问频繁"
          return
        end

        body = Nokogiri::HTML(response.body)

        body.css('.list-pic.clearfix.cursor_pointer').each do |clue|
          cid = clue.attribute('id').value.split('-').last


          option = {
              cid: cid,

              title: clue.css('.infor-title.pt_tit.js-title').first.content, # 标题
              age: clue.css('.js-license').first.content.strip, # 车龄
              total_km: clue.css('.js-roadHaul').first.content.strip, # 行驶公里数
              price: clue.css('.v-Price').first.content.strip, # 价格
          }

          age = option[:age].gsub!("万公里", "")


          cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: option[:title],
                                                                 che_ling: 2018-age.to_i,
                                                                 milage: option[:total_km],
                                                                 detail_url: "http://wap.ganji.com/#{areaid}/ershouche/#{option[:cid]}x",
                                                                 city_chinese: areaname,
                                                                 price: option[:price],
                                                                 site_name: 'ganji',
                                                                 is_cheshang: false


          return if cui_id.blank?

          cui = UserSystem::CarUserInfo.find cui_id


          sleep 20+rand(20)
          response = RestClient.get(cui.detail_url)

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

          sleep 20+rand(20)
        end


      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      ActiveRecord::Base.connection.close
      pp e
    end
  end


end