module TaoChe
  def self.get_car_user_list
    city_hash = ::UserSystem::CarUserInfo::PINYIN_CITY
    threads = []
    city_hash.each_pair do |pinyin, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 15
        pp "现在共有#{threads.length}个线程正在运行"
        while true
          threads.delete_if { |thread| thread.status == false }
          if threads.length < 15
            break
          else
            sleep 0.5
          end
        end
      end
      t = Thread.new do
        begin
          pp "现在跑.. #{areaname}"
          pp pinyin
          1.upto 2 do |i|
            pp "现在跑淘车.. #{areaname}  第 #{i}页"
            pp "http://#{pinyin}.m.taoche.com/buycar/pges1bxcdza/?orderid=1&page=#{i}"
            response = RestClient.get "http://#{pinyin}.m.taoche.com/buycar/pges1bxcdza/?orderid=1&page=#{i}"
            content = response.body
            content = Nokogiri::HTML(content)
            car_infos = content.css(".tc-car-list-h")
            break if car_infos.blank?
            pp "本页有 #{car_infos.length} 条数据"
            car_number = car_infos.length
            exists_car_number = 0
            car_infos.each do |info|
              age_mil = info.css('p.time').text.strip
              next if age_mil.blank?
              age_mil = age_mil.split('/')
              # pp "车型是：#{info.css('h4').text.strip}"
              # pp "车龄：#{age_mil.first.match(/\d{4}/).to_s}"
              # pp "链接：#{info.css('a').first['href']}"
              url = info.css('a').first['href']
              result = UserSystem::CarUserInfo.create_car_user_info che_xing: info.css('h4').text.strip,
                                                                    che_ling: age_mil.first.match(/\d{4}/).to_s,
                                                                    milage: age_mil.last.match(/[\d.]{1,10}/).to_s,
                                                                    detail_url: url,
                                                                    city_chinese: areaname,
                                                                    site_name: 'taoche'
              if result == 0
                u = url

                unless u.blank?
                  c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
                  Taoche.update_one_detail c.id if not c.blank?
                end
              end
              exists_car_number = exists_car_number + 1 if result == 1
            end
            if car_number - exists_car_number < 5
              puts '淘车本页数据全部存在，跳出'
              break
            end
          end
        rescue Exception => e
          pp e
        end
      end
      threads << t
    end


    1.upto(2000) do
      sleep(1)
      pp '抓省份。。休息.......'

      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end
  end

  def self.get_car_user_list_v2 content, areaid

    pinyin = areaid
    areaname = UserSystem::CarUserInfo::PINYIN_CITY[areaid]
    begin
      content = Nokogiri::HTML(content)
      car_infos = content.css(".tc-car-list-h")
      return if car_infos.blank?
      car_infos.each do |info|
        age_mil = info.css('p.time').text.strip
        next if age_mil.blank?
        age_mil = age_mil.split('/')
        url = info.css('a').first['href']
        result = UserSystem::CarUserInfo.create_car_user_info che_xing: info.css('h4').text.strip,
                                                              che_ling: age_mil.first.match(/\d{4}/).to_s,
                                                              milage: age_mil.last.match(/[\d.]{1,10}/).to_s,
                                                              detail_url: url,
                                                              city_chinese: areaname,
                                                              site_name: 'taoche'
        if result == 0
          u = url

          unless u.blank?
            c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
            Taoche.update_one_detail c.id if not c.blank?
          end
        end
      end
    rescue Exception => e
      pp e
    end
  end

  def self.update_one_detail car_user_info_id
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?

    begin

      response = RestClient.get(car_user_info.detail_url)

      detail_content = response.body
      detail_content = Nokogiri::HTML(detail_content)
      name = detail_content.css('.shjtit')[0].text.strip

      phone = (detail_content.css('.xqdinh p')[1].text.match /\d{11}/).to_s

      note = (detail_content.css('.mjmstext')[0].text rescue '')

      price = detail_content.css('.jiagmain p em')[0].text.match(/[\d.]{1,10}/).to_s

      fabushijian = '2010-10-01' #detail_content.css('.chytext p')[0].text.gsub('发布','').strip

      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone.to_s,
                                            note: note,
                                            price: price,
                                            fabushijian: fabushijian
    rescue Exception => e
      pp e
      car_user_info.need_update = false
      car_user_info.save
    end
  end


  # def self.update_detail
  #   threads = []
  #   # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'taoche'
  #   car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'taoche', UserSystem::CarUserInfo::CURRENT_ID]
  #   car_user_infos.each do |car_user_info|
  #     next unless car_user_info.name.blank?
  #     next unless car_user_info.phone.blank?
  #     if threads.length > 30
  #       sleep 1
  #     end
  #     threads.delete_if { |thread| thread.status == false }
  #     t = Thread.new do
  #       begin
  #         puts '开始跑明细'
  #
  #         # detail_content = `curl '#{car_user_info.detail_url}'`
  #         # url = 'http://m.taoche.com/buycar/p-6850921.html'
  #         # response = RestClient.get(url)
  #
  #         response = RestClient.get(car_user_info.detail_url)
  #
  #         detail_content = response.body
  #         detail_content = Nokogiri::HTML(detail_content)
  #         name = detail_content.css('.shjtit')[0].text.strip
  #
  #         phone = (detail_content.css('.xqdinh p')[1].text.match /\d{11}/).to_s
  #
  #         note = (detail_content.css('.mjmstext')[0].text rescue '')
  #
  #         price = detail_content.css('.jiagmain p em')[0].text.match(/[\d.]{1,10}/).to_s
  #
  #         fabushijian = '2010-10-01' #detail_content.css('.chytext p')[0].text.gsub('发布','').strip
  #
  #
  #         # response = RestClient.post "http://localhost:4000/api/v1/update_user_infos/update_car_user_info", {id: car_user_info.id,
  #         #                                                                                                    name: name,
  #         #                                                                                                    phone: phone,
  #         #                                                                                                    note: note,
  #         #                                                                                                    price: price,
  #         #                                                                                                    fabushijian: fabushijian}
  #
  #         UserSystem::CarUserInfo.update_detail id: car_user_info.id,
  #                                               name: name,
  #                                               phone: phone.to_s,
  #                                               note: note,
  #                                               price: price,
  #                                               fabushijian: fabushijian
  #
  #       rescue Exception => e
  #         pp e
  #         car_user_info.need_update = false
  #         car_user_info.save
  #         # ActiveRecord::Base.connection.close
  #       end
  #       # ActiveRecord::Base.connection.close
  #     end
  #     threads << t
  #     # pp "现在线程池中有#{threads.length}个。"
  #   end
  #   1.upto(2000) do
  #     sleep(1)
  #     # pp '休息.......'
  #     threads.delete_if { |thread| thread.status == false }
  #     break if threads.blank?
  #   end
  # end

end
