module Ganji

  #  Ganji.get_car_user_list  单线程sleep 版
  # def self.get_car_user_list_danxiancheng party = 0
  #
  #   # return if Time.now.hour > 2 and Time.now.hour < 4
  #
  #   city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
  #
  #   city_hash.each_pair do |areaid, areaname|
  #     begin
  #       pp "现在跑赶集.. #{areaname}"
  #       1.upto 1 do |i|
  #         url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
  #
  #         content = RestClient.get url, {
  #             'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  #             'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
  #
  #         }
  #         content = content.body
  #
  #         content = Nokogiri::HTML(content)
  #         car_infos = content.css(".list-item")
  #         pp "car infos length is #{car_infos.length}"
  #         break if car_infos.blank?
  #         car_number = car_infos.length
  #         exists_car_number = 0
  #         car_infos.each do |car_info|
  #           url = car_info.css('a')[0].attributes["href"].value
  #           url = url.split('?')[0]
  #           chexing = car_info.css('a')[0].text
  #           cheling_licheng = car_info.css('.meta')[0].text
  #           cheling_licheng.strip!
  #           cheling = cheling_licheng.split('/')[0]
  #           licheng = cheling_licheng.split('/')[1]
  #           cheling.gsub!('年', '')
  #           cheling = Date.today.year - cheling.to_i
  #           price = car_info.css('.price').text
  #           is_cheshang = false
  #           cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
  #                                                                  che_ling: cheling,
  #                                                                  milage: licheng,
  #                                                                  detail_url: url,
  #                                                                  city_chinese: areaname,
  #                                                                  price: price,
  #                                                                  site_name: 'ganji',
  #                                                                  is_cheshang: is_cheshang
  #
  #
  #           unless cui_id.blank?
  #             begin
  #               Ganji.update_one_detail cui_id
  #             rescue Exception => e
  #               pp "赶集出错"
  #               pp e
  #             end
  #           end
  #           exists_car_number = exists_car_number + 1 if cui_id.blank?
  #         end
  #         # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
  #         if car_number - exists_car_number < 3
  #           puts '赶集 本页数据全部存在，跳出'
  #           break
  #         end
  #       end
  #       ActiveRecord::Base.connection.close
  #
  #     rescue Exception => e
  #       ActiveRecord::Base.connection.close
  #       pp e
  #     end
  #   end
  # end

  #  Ganji.get_car_user_list_mult_threads 多线程 3g版
  # def self.get_car_user_list_3g party = 0
  #
  #   city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
  #   threads = []
  #   city_hash.each_pair do |areaid, areaname|
  #     if threads.length > 10
  #       while true
  #         threads.delete_if { |thread| thread.status == false }
  #         if threads.length < 3
  #           break
  #         else
  #           sleep 0.5
  #         end
  #       end
  #     end
  #     t = Thread.new do
  #       begin
  #         pp "现在跑赶集.. #{areaname}"
  #         1.upto 1 do |i|
  #           url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=1&deal_type=1&page=#{i}"
  #           content = RestClient.get url, {
  #               'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  #               'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
  #
  #           }
  #           content = content.body
  #           content = Nokogiri::HTML(content)
  #           car_infos = content.css(".list-item")
  #           pp "car infos length is #{car_infos.length}"
  #           break if car_infos.blank?
  #           car_number = car_infos.length
  #           exists_car_number = 0
  #           car_infos.each do |car_info|
  #             url = car_info.css('a')[0].attributes["href"].value
  #             url = url.split('?')[0]
  #             chexing = car_info.css('a')[0].text
  #             cheling_licheng = car_info.css('.meta')[0].text
  #             cheling_licheng.strip!
  #             cheling = cheling_licheng.split('/')[0]
  #             licheng = cheling_licheng.split('/')[1]
  #             cheling.gsub!('年', '')
  #             cheling = Date.today.year - cheling.to_i
  #             price = car_info.css('.price').text
  #             is_cheshang = false
  #             cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: chexing,
  #                                                                    che_ling: cheling,
  #                                                                    milage: licheng,
  #                                                                    detail_url: url,
  #                                                                    city_chinese: areaname,
  #                                                                    price: price,
  #                                                                    site_name: 'ganji',
  #                                                                    is_cheshang: is_cheshang
  #
  #
  #             unless cui_id.blank?
  #               begin
  #                 Ganji.update_one_detail cui_id
  #               rescue Exception => e
  #                 pp "赶集出错"
  #                 pp e
  #               end
  #             end
  #             exists_car_number = exists_car_number + 1 if cui_id.blank?
  #           end
  #           # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
  #           if car_number - exists_car_number < 3
  #             puts '赶集 本页数据全部存在，跳出'
  #             break
  #           end
  #         end
  #       rescue Exception => e
  #         pp e
  #       end
  #     end
  #     threads << t
  #   end
  #   1.upto(2000) do
  #     sleep(1)
  #     # pp '休息.......'
  #     threads.delete_if { |thread| thread.status == false }
  #     break if threads.blank?
  #   end
  # end


  # 从www网站上获取列表, 3g版由于拿不到及时性高的数据作废
  # Ganji.get_car_user_list 0
  def self.get_car_user_list party = 0

    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party
    threads = []

    city_hash.each_pair do |areaid, areaname|
      if threads.length > 10
        while true
          threads.delete_if { |thread| thread.status == false }
          if threads.length < 10
            break
          else
            sleep 0.1
          end
        end
      end
      t = Thread.new do
        Ganji.get_car_user_list_one_city areaname, areaid
      end
      threads << t


    end
    1.upto(200) do
      sleep(1)
      # pp '休息.......'
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end

  end



  # 从www网站上获取列表, 3g版由于拿不到及时性高的数据作废
  # Ganji.get_car_user_list_one_city_list 1, ['上海']
  def self.get_car_user_list_one_city_list party, citys

    # citys = ['上海']
    city_hash = ::UserSystem::CarUserInfo.get_ganji_sub_cities party, citys
    # threads = []

    (1..60).each do |i|
      city_hash.each_pair do |areaid, areaname|

        pp "活线程数量 #{Thread.list.length} "
        if Thread.list.length > 15
          while true
            # threads.delete_if { |thread| thread.status == false || thread.status == nil || thread.status == "aborting"}
            if Thread.list.length < 17
              # sleep 1
              break
            else
              sleep 0.2
            end
          end
        end
        sleep 1
        t = Thread.start do

          pp "执行开始 #{areaname}  #{Time.now}"
          Ganji.get_car_user_list_one_city areaname, areaid
          pp "执行结束 #{areaname} #{Time.now}"
        end
        # t.join
        # threads << t
      end
    end

    Thread.list.each do |thread|
      thread.join
    end

    # 1.upto(200) do
    #   sleep(1)
    #   # pp '休息.......'
    #   # threads.delete_if { |thread| thread.status == false }
    #   break if Thread.list.length == 0 #threads.blank?
    # end

  end

  def self.get_car_user_list_one_city areaname, areaid
    begin
      # pp "现在跑赶集.. #{areaname}"

      url = "http://#{areaid}.ganji.com/ershouche/a1/"
      # pp "发起请求 #{areaname}  #{Time.now}"
      content = RestClient.get url, {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
          'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; wap_list_view_type=pic; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; GANJISESSID=f4096cfc2cde87d4b1622848d2afce66; mobversionbeta=3g; index_city_refuse=refuse; GANJI_SID=d727f98d-2205-42b7-c9e5-796c36bd8984; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; cityDomain=hz; webimverran=82; statistics_clientid=me; ErshoucheDetailPageScreenType=1440; citydomain=sh; __utmt=1; Hm_lvt_8dba7bd668299d5dabbd8190f14e4d34=1490169006; Hm_lpvt_8dba7bd668299d5dabbd8190f14e4d34=1490174240; ganji_login_act=1490174240592; lg=1; vehicle_list_view_type=1; _gl_tracker=%7B%22ca_source%22%3A%22-%22%2C%22ca_name%22%3A%22-%22%2C%22ca_kw%22%3A%22-%22%2C%22ca_id%22%3A%22-%22%2C%22ca_s%22%3A%22self%22%2C%22ca_n%22%3A%22-%22%2C%22ca_i%22%3A%22-%22%2C%22sid%22%3A56930235227%7D; __utma=32156897.2034222174.1460360232.1490168931.1490174031.6; __utmb=32156897.10.10.1490174031; __utmc=32156897; __utmz=32156897.1490168931.5.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)'
      }
      # pp "收到请求 #{areaname} #{Time.now}"
      content = content.body



      content.gsub!('list-pic clearfix cursor_pointer ', 'dlclass')
      content.gsub!('comNum js-price', 'priceclass')

      content = Nokogiri::HTML(content)



      car_infos = content.css('.dlclass')
      # car_infos = content.css(".list-item")
      pp "car infos length is #{car_infos.length}"
      return if car_infos.blank?

      car_infos.each do |car_info|
        if car_info.to_s.match /ico-stick-yellow/
          pp '置'
          next
        end

        if car_info.to_s.match /商家/
          pp '商'
          next
        end

        car_ganji_number = begin
          car_info.attributes["id"].value rescue ''
        end
        next if car_ganji_number.blank?
        car_ganji_number.gsub!('puid-', '')
        url = "http://wap.ganji.com/#{areaid}/ershouche/#{car_ganji_number}x"
        chexing = car_info.css('.infor .infor-titbox a').text
        cheling = car_info.css('.infor .infor-dep .js-license strong').text
        licheng = car_info.css('.infor .infor-dep .js-roadHaul strong').text.to_i
        cheling.gsub!('年', '')
        cheling = Date.today.year - cheling.to_i
        price = car_info.css('.priceclass').text
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




  def self.update_one_detail car_user_info_id
    # car_user_info_id = 4922735
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/
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
      pp "开始跑明细 #{car_user_info.id}"
      # sleep 1+rand(2) if RestClientProxy.get_local_ip != '10-19-104-142'
      response = RestClient.get(car_user_info.detail_url, {
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
          'Cookie' => 'ganji_uuid=5283133772326517092624; ganji_xuuid=f60ba7d5-b4de-4c7b-b8e0-890ad74ebaea.1463541968024; citydomain=xiangyang; Hm_lvt_73a12ba5aced499cae6ff7c0a9a989eb=1463541966,1463794955; __utma=32156897.2034222174.1460360232.1463548883.1463794938.4; wap_list_view_type=pic; __utmganji_v20110909=0xe17e1688f8364e8228f5a20bbf08f82; GANJISESSID=8295e329b8cd9f5ebc25d9e09e1e7800; index_city_refuse=refuse; gr_user_id=8fcb69d6-a9e2-43f2-b05d-955ce16276a5; cityDomain=sh; gr_session_id_b500fd00659c602c=2f3e7532-899b-4dab-8670-1eb629322b9c; mobversionbeta=2.0; Hm_lvt_66fdcdd2a4078dde0960b72e77483d4e=1481157061; Hm_lpvt_66fdcdd2a4078dde0960b72e77483d4e=1481157567; ganji_temp=on'
      })
      response = response.body
      # response = RestClientProxy.get car_user_info.detail_url, {}
      # detail_content = response.body
      # pp detail_content
      # detail_content = detail_content.force_encoding('UTF-8')
      detail_content = response

      # if ! detail_content.valid_encoding?
      #   detail_content = detail_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      # end

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

      detail_content = Nokogiri::HTML(detail_content)
      detail_content = detail_content.css('.mod-detail')
      fabushijian = detail_content.css('.detail-meta span')[0].text
      fabushijian.strip!
      fabushijian.gsub!('发布:', '')

      phone = detail_content.css('.phone-contact a')[0].attributes['href'].value.gsub('tel:', '')


      name = ''
      note = ''
      details = detail_content.css('.detail-describe p')
      is_cheshang = "0"
      details.each do |detail|
        case detail.text
          when /详细信息/
            note = detail.text
            note.gsub!('详细信息：', '')
          when /联系人/
            name = detail.text
            if name.match /商家/
              is_cheshang = '1'
            end
            name.gsub!('联系人：', '')
            name.gsub!(/\[商家\]|\[个人\]/, '')
        end
      end

      # phone = detail_content.css('.tel-area-phone')[0].attributes["data-phone"].value

      # name = detail_content.css('.car-shop').css('p')[0].text
      # name.gsub!(/\s|\n|个人|联系人/, '')
      #
      # note = detail_content.css('.comm-area').text
      # note.gsub!('  ', '')
      # note.gsub!(/\r|\n/, '')


      # fabushijian = begin
      #   detail_content.css('.fabushijian').text[0..10] rescue '刚刚'
      # end


      pp "开始跑明细 #{car_user_info.id}  准备更新"
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            fabushijian: fabushijian,
                                            is_cheshang: is_cheshang

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