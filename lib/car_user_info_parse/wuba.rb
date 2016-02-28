module Wuba

  # Wuba.get_car_user_list
  def self.get_car_user_list
    city_hash = ::UserSystem::CarUserInfo::WUBA_CITY
    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 15
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 3
      end
      t = Thread.new do

        begin
          pp "现在跑58.. #{areaname}"
          1.upto 5 do |i|
            # i = 1
          url  = "http://#{areaid}.58.com/ershouche/0/pn#{i}/"
          pp url
            content = RestClient.get url
            content = content.body
            break if content.blank?
            content = Nokogiri::HTML(content)
            trs = content.css('.tbimg tr')
            car_number = trs.length
            exists_car_number = 0
            trs.each do |tr|
              chexing = ''
              next if tr.to_s.match /google|7天可退/
              begin
                chexing = tr.css('td .t')[0].text
              rescue
                pp tr.to_s
                pp 'Exception  车型获取失败'
                next
              end

              price = 2
              begin
                price = tr.css('.tc .pri')[0].text
              rescue
                pp tr.to_s
                pp 'Exception  价格获取失败'
                next
              end

              cheling = tr.css('.t p')[0].children[0].text
              cheling = cheling.gsub(/购于|年|\n|\r|\s/, '')
              milage = tr.css('.t p')[0].children[2].text
              milage = milage.gsub(/万|公里/, '')
              url = tr.css('td .t')[0].attributes["href"].value

              result = UserSystem::CarUserInfo.create_car_user_info che_xing: chexing,
                                                                    price: price,
                                                                    che_ling: cheling,
                                                                    milage: milage,
                                                                    detail_url: url.split('?')[0],
                                                                    city_chinese: areaname,
                                                                    site_name: '58'
              exists_car_number = exists_car_number + 1 if result == 1
            end
            if car_number - exists_car_number < 5
              pp '58 本页数据全部存在，跳出'
              break
            end

          end


          ActiveRecord::Base.connection.close
        rescue Exception => e
          pp e
          pp $@
          ActiveRecord::Base.connection.close

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


  # Wuba.update_detail
  def self.update_detail
    threads = []
    car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: '58'
    car_user_infos.each do |car_user_info|
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?
      next if car_user_info.detail_url.match /zhineng/

      if threads.length > 15
        sleep 2
      end
      threads.delete_if { |thread| thread.status == false }
      t = Thread.new do
        begin
          puts '开始跑明细'

          # detail_content = `curl '#{car_user_info.detail_url}'`
          # car_user_info = UserSystem::CarUserInfo.find(199946)
          pp car_user_info.detail_url
          response = RestClient.get(car_user_info.detail_url)

          detail_content = response.body
          detail_content = Nokogiri::HTML(detail_content)
          time = detail_content.css('.mtit_con_left .time').text
          name = detail_content.css('.lineheight_2').children[3].text

          id = car_user_info.detail_url.match /ershouche\/(\d{8,15})x\.shtml/
          id = id[1]
          id_response = RestClient.get("http://app.58.com/api/windex/scandetail/car/#{id}/")
          id_response = id_response.body
          id_response = Nokogiri::HTML(id_response)
          phone = id_response.css('.nums').text
          note = '暂无'
          phone = phone.gsub('-','')
          UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                                name: name,
                                                phone: phone,
                                                note: note,
                                                fabushijian: time

        rescue Exception => e
          pp e
          pp $@
          car_user_info.need_update = false
          car_user_info.save
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


end