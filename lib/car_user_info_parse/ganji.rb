module Ganji

  # Ganji.get_car_user_list  多线程版本
  # def self.get_car_user_list party = 0
  #   city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
  #   threads = []
  #   city_hash.each_pair do |areaid, areaname|
  #     threads.delete_if { |thread| thread.status == false }
  #     if threads.length > 20
  #       pp "现在共有#{threads.length}个线程正在运行"
  #       sleep 1
  #     end
  #     t = Thread.new do
  #       begin
  #         pp "现在跑赶集.. #{areaname}"
  #         1.upto 3 do |i|
  #           url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
  #           # url = "http://wap.ganji.com/sh/ershouche/?back=search&agent=1&deal_type=1&page=1"
  #           content = RestClient.get url
  #           content = content.body
  #           break if content.blank?
  #
  #           content = Nokogiri::HTML(content)
  #           # car_infos = content.css(".mod-list .list-item")
  #           car_infos = content.css(".infor")
  #           break if car_infos.blank?
  #           car_number = car_infos.length
  #           exists_car_number = 0
  #           car_infos.each do |car_info|
  #             detail_url = car_info.attributes["href"].value
  #             chexing = car_info.css('.iName').text
  #             chexing.gsub!(/\n|\s/,'')
  #
  #             price = car_info.css('.price').text
  #             price.gsub!('万元', '')
  #
  #             cheling_licheng = car_info.css('.iol').text
  #             cheling = begin cheling_licheng.split('年')[0] rescue 2012 end
  #             cheling.gsub!('\n|\s','')
  #             licheng = begin cheling_licheng.split(/上牌|万公里/)[1] rescue 2012 end
  #             is_cheshang = (chexing.match /个人/).blank?
  #             cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
  #                                                                    che_ling: cheling,
  #                                                                    milage: licheng,
  #                                                                    detail_url: detail_url.split('?')[0],
  #                                                                    city_chinese: areaname,
  #                                                                    price: price,
  #                                                                    site_name: 'ganji',
  #                                                                    is_cheshang: is_cheshang
  #
  #
  #
  #
  #               unless cui_id.blank?
  #                 Ganji.update_one_detail cui_id
  #               end
  #
  #
  #
  #             exists_car_number = exists_car_number + 1 if cui_id.blank?
  #           end
  #           # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
  #           if car_number - exists_car_number < 3
  #             puts '赶集 本页数据全部存在，跳出'
  #             break
  #           end
  #         end
  #         ActiveRecord::Base.connection.close
  #       rescue Exception => e
  #         pp e
  #         ActiveRecord::Base.connection.close
  #       end
  #     end
  #     threads << t
  #   end
  #
  #   1.upto(2000) do
  #     sleep(1)
  #     # pp '休息.......'
  #     threads.delete_if { |thread| thread.status == false }
  #     break if threads.blank?
  #   end
  # end


  #  Ganji.get_car_user_list  单线程sleep 版
  def self.get_car_user_list party = 0

    return if Time.now.hour > 2 and Time.now.hour < 4

    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party

    city_hash.each_pair do |areaid, areaname|
      begin
        pp "现在跑赶集.. #{areaname}"
        1.upto 3 do |i|
          sleep 4+rand(4) if  RestClientProxy.get_local_ip != '10-19-104-142'
          url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
          # url = "http://wap.ganji.com/sh/ershouche/?back=search&agent=1&deal_type=1&page=1"
          # url = "http://wap.ganji.com/su/ershouche/?back=search&agent=1&deal_type=1&page=1"
          url = 'http://wap.ganji.com/cq/ershouche/?back=search&agent=1&deal_type=1&page=1'
          content = RestClientProxy.get url
          # content = RestClientProxy.get url, {}
          # content = content.body

          if ! content.valid_encoding?
            content = content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
          end

          if content.blank?
            pp '..........'
            break
          end

          content = Nokogiri::HTML(content)
          # car_infos = content.css(".mod-list .list-item")
          car_infos = content.css(".inforBox .infor")
          pp "car infos length is #{car_infos.length}"
          break if car_infos.blank?
          car_number = car_infos.length
          exists_car_number = 0

          car_infos.each do |car_info|
            detail_url = car_info.attributes["href"].value
            detail_url.gsub!('_', '/')
            chexing = car_info.css('.iName').text
            chexing.gsub!(/\n|\s/, '')

            price = car_info.css('.price').text
            price.gsub!('万元', '')

            cheling_licheng = car_info.css('.iol').text
            cheling = begin
              cheling_licheng.split('年')[0] rescue 2012
            end
            cheling.gsub!('  ', '')
            cheling.gsub!('\n|\s|\r', '')
            licheng = begin
              cheling_licheng.split(/上牌|万公里/)[1] rescue 2012
            end
            is_cheshang = (chexing.match /个人/).blank?
            next if chexing.length > 200
            cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
                                                                   che_ling: cheling,
                                                                   milage: licheng,
                                                                   detail_url: "http://wap.ganji.com#{detail_url.split('?')[0]}",
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


            exists_car_number = exists_car_number + 1 if cui_id.blank?
          end
          # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
          if car_number - exists_car_number < 3
            puts '赶集 本页数据全部存在，跳出'
            break
          end
        end
          # ActiveRecord::Base.connection.close
      rescue Exception => e
        pp e
        # ActiveRecord::Base.connection.close
      end
    end
  end

  #  Ganji.get_car_user_list  单线程sleep 版
  def self.get_car_user_list_v2 content, areaid

    begin
      areaname = UserSystem::CarUserInfo::GANJI_CITY[areaid]
      return if content.blank?
      content = Nokogiri::HTML(content)
      car_infos = content.css(".infor")
      return if car_infos.blank?


      car_infos.each do |car_info|
        detail_url = car_info.attributes["href"].value
        detail_url.gsub!('_', '/')
        chexing = car_info.css('.iName').text
        chexing.gsub!(/\n|\s/, '')

        price = car_info.css('.price').text
        price.gsub!('万元', '')

        cheling_licheng = car_info.css('.iol').text
        cheling = begin
          cheling_licheng.split('年')[0] rescue 2012
        end
        cheling.gsub!('  ', '')
        cheling.gsub!('\n|\s|\r', '')
        licheng = begin
          cheling_licheng.split(/上牌|万公里/)[1] rescue 2012
        end
        is_cheshang = (chexing.match /个人/).blank?
        cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: "~#{chexing}",
                                                               che_ling: cheling,
                                                               milage: licheng,
                                                               detail_url: "http://wap.ganji.com#{detail_url.split('?')[0]}",
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
    rescue Exception => e
      pp e
    end

  end

  # Ganji.update_detail
  # def self.update_detail
  #   threads = []
  #   # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'ganji'
  #   car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'ganji', UserSystem::CarUserInfo::CURRENT_ID]
  #   car_user_infos.each do |car_user_info|
  #     next unless car_user_info.name.blank?
  #     next unless car_user_info.phone.blank?
  #
  #
  #     if threads.length > 30
  #       sleep 1
  #     end
  #     threads.delete_if { |thread| thread.status == false }
  #     t = Thread.new do
  #       begin
  #         puts '开始跑明细'
  #
  #         # detail_content = `curl '#{car_user_info.detail_url}'`
  #         pp car_user_info.detail_url
  #         response = RestClient.get(car_user_info.detail_url)
  #         pp
  #         detail_content = response.body
  #         detail_content = Nokogiri::HTML(detail_content)
  #         note, phone, name = '', '', ''
  #         ps = detail_content.css('.detail-describe p')
  #         next if ps.blank?
  #         ps.each do |p|
  #           text = begin
  #             p.text rescue ''
  #           end
  #           case text
  #             when /联系人：/
  #               name = text
  #             when /电话：/
  #               phone = text
  #             when /详细信息：/
  #               note = text
  #           end
  #         end
  #         brand = ps[1].css('a').text
  #
  #         note = note.gsub('详细信息：', '')
  #         name = name.gsub('联系人：', '')
  #         phone = phone.gsub('电话：', '')
  #         fabushijian = detail_content.css('.mod-detail .detail-meta span')[0].text
  #         fabushijian = fabushijian.gsub("发布:", '')
  #         fabushijian = fabushijian.gsub("\n", '')
  #         fabushijian = fabushijian.gsub("\r", '')
  #         fabushijian = fabushijian.gsub("  ", '')
  #         fabushijian = "2016-#{fabushijian}"
  #
  #
  #         UserSystem::CarUserInfo.update_detail id: car_user_info.id,
  #                                               name: name,
  #                                               phone: phone,
  #                                               note: note,
  #                                               fabushijian: fabushijian,
  #                                               brand: brand
  #
  #       rescue Exception => e
  #         pp e
  #         pp $@
  #         car_user_info.need_update = false
  #         car_user_info.save
  #       end
  #       ActiveRecord::Base.connection.close
  #     end
  #     threads << t
  #     # pp "现在线程池中有#{threads.length}个。"
  #   end
  #
  #   1.upto(2000) do
  #     sleep(1)
  #     # pp '休息.......'
  #     threads.delete_if { |thread| thread.status == false }
  #     break if threads.blank?
  #   end
  #
  # end


  def self.update_one_detail car_user_info_id
    # car_user_info_id = 1270818
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/


    begin
      pp "开始跑明细 #{car_user_info.id}"
      sleep 4+rand(4) if  RestClientProxy.get_local_ip != '10-19-104-142'
      response = RestClientProxy.get(car_user_info.detail_url)
      # response = RestClientProxy.get car_user_info.detail_url, {}
      # detail_content = response.body
      # pp detail_content
      # detail_content = detail_content.force_encoding('UTF-8')
      detail_content = response

      if ! detail_content.valid_encoding?
        detail_content = detail_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      end

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
      detail_content.gsub!('fc8d f12', 'fabushijian')
      detail_content = Nokogiri::HTML(detail_content)

      phone = detail_content.css('.tel-area-phone')[0].attributes["data-phone"].value

      name = detail_content.css('.car-shop').css('p')[0].text
      name.gsub!(/\s|\n|个人|联系人/, '')

      note = detail_content.css('.comm-area').text
      note.gsub!('  ', '')
      note.gsub!(/\r|\n/, '')


      fabushijian = begin
        detail_content.css('.fabushijian').text[0..10] rescue '刚刚'
      end


      pp "开始跑明细 #{car_user_info.id}  准备更新"
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            fabushijian: fabushijian

    rescue Exception => e
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


end