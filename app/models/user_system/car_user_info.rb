class UserSystem::CarUserInfo < ActiveRecord::Base
  require 'rest-client'

  def self.create_car_user_info options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return 1 if user_infos.length > 0

    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return 0
  end

  def self.send_email

  end


  #UserSystem::CarUserInfo.update_che168_detail2
  def self.update_che168_detail2 run_list = true, thread_number = 5
    while true
      if run_list
        begin
          UserSystem::CarUserInfo.che168_get_car_list
        rescue Exception => e
        end
      end
      threads = []
      car_user_infos = UserSystem::CarUserInfo.where need_update: true
      car_user_infos.each do |car_user_info|
        next unless car_user_info.name.blank?
        next unless car_user_info.phone.blank?
        pp '------------------------------------'
        pp "现在线程池中有#{threads.length}个。"
        if threads.length > thread_number
          sleep 2
        end
        threads.delete_if { |thread| thread.status == false }
        t = Thread.new do
          begin
            puts '新的线程已创建'
            # detail_content = `curl '#{car_user_info.detail_url}'`
            response = RestClient.get(car_user_info.detail_url)
            detail_content = response.body
            detail_content = Nokogiri::HTML(detail_content)
            connect_info = detail_content.css("#LinkInfo")[0]
            name = connect_info.css(".info").text.strip
            phone = connect_info.css("#callPhone")[0].attributes["data-telno"].value
            note = detail_content.css(".cardet-message-2sc .text")[0].text
            time = detail_content.css(".noa .time")[0].text.gsub("发布日期：", '')
            response = RestClient.post 'http://127.0.0.1:3000/api/v1/update_user_infos/update_car_user_info', {id: car_user_info.id,
                                                                                                               name: name,
                                                                                                               phone: phone,
                                                                                                               note: note,
                                                                                                               fabushijian: time}
            pp response
          rescue Exception => e
          end
        end
        threads << t
        pp "现在线程池中有#{threads.length}个。"
      end

      begin
        UserSystem::CarUserInfo.send_email
      rescue Exception => e
      end
      sleep 60*60
    end
  end


  def self.che168_get_car_list
    car_price_start = 1
    car_price_end = 1000
    # 所有的省份。
    # provinces = {"440000" => "广东", "370000" => "山东", "330000" => "浙江", "320000" => "江苏", "130000" => "河北", "410000" => "河南", "110000" => "北京", "210000" => "辽宁",  "310000" => "上海", "500000" => "重庆", "350000" => "福建", "450000" => "广西", "520000" => "贵州", "620000" => "甘肃", "460000" => "海南", "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林", "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川", "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南"}
    provinces = {"440000" => "广东", "330000" => "浙江", "370000" => "山东",
                 "320000" => "江苏", "120000" => "天津", "130000" => "河北",
                 "340000" => "安徽", "350000" => "福建", "430000" => "湖南",
                 "230000" => "黑龙江", "420000" => "湖北", "410000" => "河南",
                 "110000" => "北京", "210000" => "辽宁", "310000" => "上海",
                 "610000" => "陕西", "510000" => "四川", "140000" => "山西",
                 "500000" => "重庆", "410000" => "河南"}

    # @陈小朋，测试的时候用这组province
    # provinces = {"310000" => "上海"}
    # 广州，深圳，宁波，东莞，唐山，厦门，上海，西安，重庆，杭州，天津，苏州，成都，福州，长沙，北京，南京，温州，哈尔滨，石家庄，合肥，郑州，武汉，太原，沈阳，无锡，大连，济南，佛山，青岛

    provinces.each_pair do |key, v|
      pp "现在跑 #{v}"
      city_content = `curl 'http://m.che168.com/Handler/GetArea.ashx?pid=#{key}'`
      city_content = JSON.parse city_content
      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if not ["广州","深圳","宁波","东莞","唐山","厦门","上海","西安","重庆","杭州","天津","苏州","成都","福州", "长沙","北京","南京","温州","哈尔滨","石家庄","合肥","郑州","武汉","太原","沈阳","无锡","大连","济南", "佛山","青岛"].include? areaname
          next
        end

        pp "现在跑 #{areaname}"
        1.upto 1000000000 do |i|
          content = `curl 'http://m.che168.com/handler/getcarlist.ashx?num=200&pageindex=#{i}&brandid=0&seriesid=0&specid=0&price=#{car_price_start}_#{car_price_end}&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0' -H 'Host: m.che168.com' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:39.0) Gecko/20100101 Firefox/39.0' -H 'Accept: application/json' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3' -H 'deflate' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://m.che168.com/guangzhou/1_10/1-5-0-6-0-0-00/?pvareaid=100421' -H 'Cookie: sessionid=e4434ae5-a74f-430f-bf16-2301fe709574; sessionip=27.203.171.229; area=371099; Hm_lvt_5a373383174a999f435969fc84eef6ec=1437745123; Hm_lpvt_5a373383174a999f435969fc84eef6ec=1437748038; userarea=0; SessionSeries=0; sheight=; __utma=247243734.1237350500.1437745133.1437745133.1437747639.2; __utmc=247243734; __utmz=247243734.1437745133.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _ga=GA1.2.1237350500.1437745133; BroswerCategory=77d%7C26d%7C71d%7C165d%7C15d%7C12d%7C47d%7C38d%7C36d%7C1d%7C86d%7C; BroswerSeries=552%2C434%2C657%2C153%2C; authenticationarea=0; historysearch=china|0|0|1|10,china|0|0|8|10; uarea=440100%7Cguangzhou; sessionvisit=182dfd58-da85-4c78-9e75-0740e76a52c1; _gat=1' -H 'Connection: keep-alive'`
          # content = ActiveSupport::Gzip.decompress(content)
          break if content.blank?
          pp content
          a = JSON.parse content
          break if a.length == 0
          car_number = a.length
          exists_car_number = 0
          a.each do |info|
            result = UserSystem::CarUserInfo.create_car_user_info che_xing: info["carname"],
                                                                  che_ling: info["date"],
                                                                  milage: info['milage'],
                                                                  detail_url: "http://m.che168.com#{info["url"]}",
                                                                  city_chinese: areaname,
                                                                  site_name: 'che168'
            exists_car_number = exists_car_number + 1 if result == 1
          end
          if car_number == exists_car_number
            puts '本页数据全部存在，跳出'
            break
          end
        end
      end
    end
  end

end
__END__

获取省份列表
    profince_content = `curl 'http://m.che168.com/selectarea.aspx?brandpinyin=&seriespinyin=&specid=&price=1_10&carageid=5&milage=0&carsource=1&store=6&level=0&currentareaid=440100&market=00&key=&backurl=#areaG'`
    profince_content = Nokogiri::HTML(profince_content)
    citys = {}
    profince_content.css(".widget .w-main .w-sift-area a").each do |sheng|
      pp sheng.attributes
      pp sheng

        citys[(sheng.attributes["data-pid"].value rescue '')] = sheng.text.strip



    end
    pp citys




  广州，深圳，宁波，东莞，唐山，厦门，上海，西安，重庆，杭州，天津，苏州，成都，福州，长沙，北京，南京，温州，哈尔滨，石家庄，合肥，郑州，武汉，太原，沈阳，无锡，大连，济南，佛山，青岛