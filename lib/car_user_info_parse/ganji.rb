module Ganji

  # Ganji.get_car_user_list
  def self.get_car_user_list
    city_hash = ::UserSystem::CarUserInfo::GANJI_CITY
    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 15
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 3
      end
      t = Thread.new do
        begin
          pp "现在跑赶集.. #{areaname}"
          1.upto 3 do |i|
            url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
            # url = "http://wap.ganji.com/bj/ershouche/?back=search&agent=1&deal_type=1&page=1"
            content = RestClient.get url
            content = content.body
            break if content.blank?

            content = Nokogiri::HTML(content)
            car_infos = content.css(".mod-list .list-item")
            break if car_infos.blank?
            car_number = car_infos.length
            exists_car_number = 0
            car_infos.each do |car_info|
              p1 = car_info.css('p')[0]
              detail_url = p1.css('a')[0].attributes["href"].value
              chexing = p1.css('a')[0].text
              cheshang = begin
                p1.css('.fc-green')[0].text rescue ''
              end


              p2 = car_info.css('p')[1]
              meta = p2.css('.meta')[0].text
              meta = meta.gsub(' ', '')
              meta = meta.gsub("\n", '')
              meta = meta.gsub("\r", '')
              cheling = begin
                meta.split('/')[0] rescue ''
              end
              licheng = begin
                meta.split('/')[1] rescue ''
              end
              cheling = cheling.gsub('年', '')
              licheng = licheng.gsub('万公里', '')
              cheling = 2016-cheling.to_i

              price = p2.css('.price')[0].text
              price = price.gsub('万元', '')
              is_cheshang = 0
              if cheshang == '[好车]'
                is_cheshang = 1
              end
              result = UserSystem::CarUserInfo.create_car_user_info che_xing: chexing,
                                                                    che_ling: cheling,
                                                                    milage: licheng,
                                                                    detail_url: detail_url.split('?')[0],
                                                                    city_chinese: areaname,
                                                                    price: price,
                                                                    site_name: 'ganji',
                                                                    is_cheshang: is_cheshang

              exists_car_number = exists_car_number + 1 if result == 1
            end
            # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
            if car_number - exists_car_number < 8
              puts '赶集 本页数据全部存在，跳出'
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
      # pp '休息.......'
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end
  end
  # Ganji.update_detail
  def self.update_detail
    threads = []
    # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'ganji'
    car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'ganji', UserSystem::CarUserInfo::CURRENT_ID]
    car_user_infos.each do |car_user_info|
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?



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
          note, phone , name = '', '', ''
          ps = detail_content.css('.detail-describe p')
          next if ps.blank?
          ps.each do |p|
            text = begin p.text rescue '' end
            case text
              when /联系人：/
                name = text
              when /电话：/
                phone = text
              when /详细信息：/
                note = text
            end
          end
          brand = ps[1].css('a').text

          note = note.gsub('详细信息：','')
          name = name.gsub('联系人：', '')
          phone = phone.gsub('电话：','')
          fabushijian = detail_content.css('.mod-detail .detail-meta span')[0].text
          fabushijian = fabushijian.gsub("发布:", '')
          fabushijian = fabushijian.gsub("\n", '')
          fabushijian = fabushijian.gsub("\r", '')
          fabushijian = fabushijian.gsub("  ", '')
          fabushijian = "2016-#{fabushijian}"


          UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                                name: name,
                                                phone: phone,
                                                note: note,
                                                fabushijian: fabushijian,
                                                brand: brand

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