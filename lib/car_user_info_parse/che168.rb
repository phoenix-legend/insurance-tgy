module Che168

  # Che168.get_car_user_list
  def self.get_car_user_list party = 0
    car_price_start = 1
    car_price_end = 1000
    number_per_page = 10
    # city_hash = ::UserSystem::CarUserInfo::ALL_CITY
    city_hash = ::UserSystem::CarUserInfo.get_che168_sub_cities party
    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 30
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 1
      end
      t = Thread.new do
        begin
          pp "现在跑168.. #{areaname}"
          1.upto 3 do |i|
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
          # ActiveRecord::Base.connection.close
        rescue Exception => e
          pp e
          # ActiveRecord::Base.connection.close
        end
      end
      threads << t
    end
    1.upto(2000) do
      sleep(1)
      # pp '休息.......'
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
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
          pp car_user_info.detail_url
          response = RestClient.get(car_user_info.detail_url)
          pp
          detail_content = response.body
          detail_content = Nokogiri::HTML(detail_content)
          connect_info = detail_content.css("#callPhone")[0]
          name = connect_info.css("span").text.strip
          phone = connect_info.attributes["data-telno"].value.strip
          note = begin
            detail_content.css("#js-message")[0].text.strip rescue ''
          end
          time = detail_content.css(".carousel-images h2")[0].text.gsub("发布", '').strip[0..9]
          price = detail_content.css(".info-price")[0].text.gsub("¥", '').strip

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
          # ActiveRecord::Base.connection.close
        end
        # ActiveRecord::Base.connection.close
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

    begin


      # detail_content = `curl '#{car_user_info.detail_url}'`
      pp car_user_info.detail_url
      response = RestClient.get(car_user_info.detail_url)
      detail_content = response.body
      detail_content = Nokogiri::HTML(detail_content)
      connect_info = detail_content.css("#callPhone")[0]
      name = connect_info.css("span").text.strip
      phone = connect_info.attributes["data-telno"].value.strip
      note = begin
        detail_content.css("#js-message")[0].text.strip rescue ''
      end
      time = detail_content.css(".carousel-images h2")[0].text.gsub("发布", '').strip[0..9]
      price = detail_content.css(".info-price")[0].text.gsub("¥", '').strip

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