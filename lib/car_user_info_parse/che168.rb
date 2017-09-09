module Che168

  # Che168.get_car_user_list
  def self.get_car_user_list party = 0
    car_price_start = 1
    car_price_end = 1000
    number_per_page = 10
    # city_hash = ::UserSystem::CarUserInfo::ALL_CITY
    city_hash = ::UserSystem::CarUserInfo.get_che168_sub_cities party

    (1..200).each do |i|
      city_hash.each_pair do |areaid, areaname|

        if Thread.list.length > 8
          while true
            if Thread.list.length < 10
              break
            else
              sleep 0.5
            end
          end
        end
        Thread.start do
          begin
            pp "现在跑168.. #{areaname}"
            1.upto 1 do |i|
              content = RestClient.get "http://m.che168.com/handler/getcarlist.ashx?num=#{number_per_page}&pageindex=#{i}&brandid=0&seriesid=0&specid=0&price=#{car_price_start}_#{car_price_end}&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0"
              content = content.body
              break if content.blank?
              a = JSON.parse content
              break if a.length == 0
              car_number = a.length
              exists_car_number = 0
              a.each do |info|
                url = "http://m.che168.com#{info["url"]}"
                url = begin
                  url.split('#')[0] rescue ''
                end
                next if url.match /m\.hao\.autohome\.com\.cn/
                result = UserSystem::CarUserInfo.create_car_user_info che_xing: info["carname"],
                                                                      che_ling: info["date"],
                                                                      milage: info['milage'],
                                                                      detail_url: url,
                                                                      city_chinese: areaname,
                                                                      site_name: 'che168'

                if result == 0
                  u = url

                  unless u.blank?
                    c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
                    Che168.update_one_detail c.id if not c.blank?
                  end
                end

                exists_car_number = exists_car_number + 1 if result == 1
              end
              if car_number - exists_car_number < 3
                puts 'che 168 本页数据全部存在，跳出'
                break
              end
            end
            ActiveRecord::Base.connection.close
          rescue Exception => e
            pp e
          end
          ActiveRecord::Base.connection.close
        end

      end
    end

  end

  def self.get_car_user_list_v2 content, areaid
    areaname = UserSystem::CarUserInfo::ALL_CITY[areaid]

    begin
      pp "现在跑168.. #{areaname}"
      return if content.blank?
      a = JSON.parse content
      return if a.length == 0
      a.each do |info|
        url = "http://m.che168.com#{info["url"]}"
        url = begin
          url.split('#')[0] rescue ''
        end
        next if url.match /m\.hao\.autohome\.com\.cn/
        result = UserSystem::CarUserInfo.create_car_user_info che_xing: "~#{info["carname"]}",
                                                              che_ling: info["date"],
                                                              milage: info['milage'],
                                                              detail_url: url,
                                                              city_chinese: areaname,
                                                              site_name: 'che168'

        if result == 0
          u = url

          unless u.blank?
            c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
            Che168.update_one_detail c.id if not c.blank?
          end
        end
      end
    rescue Exception => e
      pp e
    end
  end

  def self.update_detail
    threads = []
    # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'che168'
    car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'che168', UserSystem::CarUserInfo::CURRENT_ID]
    car_user_infos.each do |car_user_info|
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?
      next if car_user_info.detail_url.match /m\.hao\.autohome\.com\.cn/
      if threads.length > 15
        sleep 2
      end
      threads.delete_if { |thread| thread.status == false }
      t = Thread.new do
        begin
          puts '开始跑明细'

          # detail_content = `curl '#{car_user_info.detail_url}'`
          # pp car_user_info.detail_url
          # k = "http://m.che168.com/personal/23235774.html?type=1"
          response = RestClient.get(car_user_info.detail_url)
          pp
          detail_content = response.body
          phone = detail_content.match /tel:(\d{11})/
          phone = phone[1]
          detail_content = Nokogiri::HTML(detail_content)
          # connect_info = detail_content.css("#callPhone")[0]
          name = "车主"#connect_info.css("span").text.strip
          # phone = products_content.match /tel:(\d{11})/#connect_info.attributes["data-telno"].value.strip
          note = begin
            detail_content.css("#js-message")[0].text.strip rescue ''
          end
          # time = detail_content.css(".carousel-images h2")[0].text.gsub("发布", '').strip[0..9]

          price = begin  detail_content.css(".info-price")[0].text.gsub("¥", '').strip end

          UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                                name: name,
                                                phone: phone,
                                                note: note,
                                                price: price
                                                # fabushijian: time

        rescue Exception => e
          pp e
          pp $@
          car_user_info.need_update = false
          car_user_info.save
          ActiveRecord::Base.connection.close
        end
        ActiveRecord::Base.connection.close
      end
      threads << t
      # pp "现在线程池中有#{threads.length}个。"
    end

    1.upto(2000) do
      sleep(1)
      # pp '休息.......'
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end

  end


  def self.update_one_detail car_user_info_id
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /m\.hao\.autohome\.com\.cn/

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


      # detail_content = `curl '#{car_user_info.detail_url}'`
      pp car_user_info.detail_url

      # k = "http://m.che168.com/personal/23235774.html?type=1"
      response = RestClient.get car_user_info.detail_url,
                                'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
                                'Cookie' => '_ga=GA1.2.84789044.1442387486; sessionid=25e4b37e-7b66-480d-b17a-5e0fab529500; sessionip=114.111.166.28; area=110199; __utma=247243734.84789044.1442387486.1463541274.1463541274.1; isShowTool2=1; UsedCarBrowseHistory=0%3A20405753; Hm_lvt_0f2ac73eb429af8bb7f48d01f2a25a25=1490752053; Hm_lpvt_0f2ac73eb429af8bb7f48d01f2a25a25=1490752053; _ga=GA1.3.84789044.1442387486; _gat=1; sessionuid=25e4b37e-7b66-480d-b17a-5e0fab529500'


      detail_content = response.body
      detail_content = Nokogiri::HTML(detail_content)
      # connect_info = detail_content.css("#callPhone")[0]
      name = "车主"#connect_info.css("span").text.strip
      # phone = connect_info.attributes["data-telno"].value.strip
      phone = (response.body.match /tel:(\d{11})/)[1]
      note = begin
        detail_content.css("#js-message")[0].text.strip rescue ''
      end
      time = begin detail_content.css(".carousel-tt b")[1].text.gsub("发布", '').strip[0..9] end
      price = begin detail_content.css(".info-price")[0].text.gsub("¥", '').strip end

      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            price: price,
                                            fabushijian: time

    rescue Exception => e
      pp e
      pp $@
      car_user_info.need_update = false
      car_user_info.save
    end
  end


end