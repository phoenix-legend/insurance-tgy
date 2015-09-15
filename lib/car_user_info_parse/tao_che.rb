module TaoChe
  def self.get_car_user_list
    city_hash = ::UserSystem::CarUserInfo::PINYIN_CITY
    threads = []
    city_hash.each_pair do |pinyin, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 30
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 3
      end
      t = Thread.new do
        begin
          pp "现在跑.. #{areaname}"
          pp pinyin
          1.upto 10 do |i|
            pp "访问。。。。。。。。。"
            pp "http://#{pinyin}.m.taoche.com/buycar/pges1bxcdza/?orderid=1&page=#{i}"
            response = RestClient.get "http://#{pinyin}.m.taoche.com/buycar/pges1bxcdza/?orderid=1&page=#{i}"
            content = response.body
            content = Nokogiri::HTML(content)
            car_infos = content.css(".tc-car-list-h")
            break if car_infos.blank?
            car_number = car_infos.length
            exists_car_number = 0
            car_infos.each do |info|
              age_mil = info.css('p.time').text.strip
              age_mil = age_mil.split('/')
              result = UserSystem::CarUserInfo.create_car_user_info che_xing: info.css('h4').text.strip,
                                                                    che_ling: age_mil.first.match(/\d{4}/).to_s,
                                                                    milage: age_mil.last.match(/[\d.]{1,10}/).to_s,
                                                                    detail_url: info.css('a').first['href'],
                                                                    city_chinese: areaname,
                                                                    site_name: 'taoche'
              exists_car_number = exists_car_number + 1 if result == 1
            end
            if car_number == exists_car_number
              puts '本页数据全部存在，跳出'
              break
            end
          end
          ActiveRecord::Base.connection.close
        rescue Exception => e
          pp e
          ActiveRecord::Base.connection.close
        end
      end
      threads << t
    end


    1.upto(2000) do
      sleep(1)
      pp '抓省份。。休息.......'
      threads.each do |t|
        pp t.status
      end
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end
  end

  def self.update_detail
    threads = []
    car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'taoche'
    car_user_infos.each do |car_user_info|
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?
      if threads.length > thread_number
        sleep 2
      end
      threads.delete_if { |thread| thread.status == false }
      t = Thread.new do
        begin
          puts '开始跑明细'

          # detail_content = `curl '#{car_user_info.detail_url}'`
          response = RestClient.get(car_user_info.detail_url)

          detail_content = response.body
          detail_content = Nokogiri::HTML(detail_content)
          response = RestClient.post "http://localhost:4000/api/v1/update_user_infos/update_car_user_info", {id: car_user_info.id,
                                                                                                             name: detail_content.css('p.shjtit').first.text.strip,
                                                                                                             phone: detail_content.css('a.tel').css('p')[1].text.strip,
                                                                                                             note: (detail_content.css('div.mjmstext.mizaos').first.text),
                                                                                                             price: detail_content.css('p em').first.text.strip.match(/[\d.]{1,10}/).to_s,
                                                                                                             fabushijian: content.css('div.chytext p').text.strip.match(/[\d-]{1,10}/).to_s}

        rescue Exception => e
          pp e
          car_user_info.need_update = false
          car_user_info.save
        end
        ActiveRecord::Base.connection.close
      end
      threads << t
      # pp "现在线程池中有#{threads.length}个。"
    end
  end

end