module Wuba

  # Wuba.get_car_user_list
  # 获取58部分城市的车辆列表
  def self.get_car_user_list lest_number = 20, sub_city_party = 0
    # city_hash = ::UserSystem::CarUserInfo::WUBA_CITY
    city_hash = ::UserSystem::CarUserInfo.get_58_sub_cities sub_city_party
    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 30
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 1
      end
      t = Thread.new do
        begin
          pp "现在跑58.. #{areaname}"
          1.upto 1 do |i|
            # i = 1
            url = "http://#{areaid}.58.com/ershouche/0/pn#{i}/"
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
                car_number = car_number -1
                pp tr.to_s
                pp 'Exception  车型获取失败'
                next
              end

              price = 2
              begin
                price = tr.css('.tc .pri')[0].text
              rescue
                car_number = car_number -1
                pp tr.to_s
                pp 'Exception  价格获取失败'
                next
              end

              cheling = tr.css('.t p')[0].children[0].text
              cheling = cheling.gsub(/购于|年|\n|\r|\s/, '')
              milage = begin
                tr.css('.t p')[0].children[2].text rescue '8.0'
              end
              milage = milage.gsub(/万|公里/, '')
              url = tr.css('td .t')[0].attributes["href"].value
              begin
                if url.match /http:\/\/short/
                  url_short = url
                  url = Wuba.get_normal_url_by_short_url_and_city url, areaid
                  # pp "翻译58shorturl #{url_short} 为 #{url}"
                  next if url.blank?
                end

                # 如果58抓到的数据不是当前城市的，直接不进数据库
                zhengze = "http://#{areaid}.58.com"
                url_sx = url.match Regexp.new zhengze
                if url_sx.blank?
                  next
                end
              rescue

              end

              result = UserSystem::CarUserInfo.create_car_user_info che_xing: chexing,
                                                                    price: price,
                                                                    che_ling: cheling,
                                                                    milage: milage,
                                                                    detail_url:   url.split('?')[0],
                                                                    city_chinese: areaname,
                                                                    site_name: '58'

              if result == 0
                u = url.split('?')[0]

                unless u.blank?
                  c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
                  Wuba.update_one_detail c.id if not c.blank?
                end
              end
              exists_car_number = exists_car_number + 1 if result == 1
            end
            if car_number - exists_car_number < lest_number
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
  def self.update_one_detail car_user_info_id
    # car_user_info_id = 1055829
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/


    begin
      puts '更新明细'
      pp car_user_info.detail_url
      response = RestClient.get car_user_info.detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}

      detail_content = response.body
      # detail_content.gsub!('intro-per intro-center','personname')
      # detail_content.gsub!('intro-per','personname')
      detail_content.gsub!('person-name','personname')
      detail_content.gsub!('abstract-info-txt clear','fbsj')
      detail_content.gsub!('detailinfo-box desClose','notenote')
      detail_content.gsub!('person-phoneNumber','persophone')



      detail_content = Nokogiri::HTML(detail_content)

      name = detail_content.css('.personname').text
      name.gsub!(/\(|\)|个人/,'')

      phone = detail_content.css('persophone').text
      phone_is_shangjia = if (phone.match /\*/).nil? then  false else true end

      time = detail_content.css('.fbsj').text
      time.gsub!('发布：','')
      time.strip!


      note = begin detail_content.css('.notenote').text rescue '' end
      note.gsub!('联系我时，请说是在58同城上看到的，谢谢！','')


      phone_is_shangjia = true if name.match /瓜子/

      # time = detail_content.css('.mtit_con_left .time').text
      # name = detail_content.css('.lineheight_2').children[3].text
      # note = begin
      #   detail_content.css('.part_detail').children[2].text.gsub(/\t|\r|\n/, '') rescue '暂无'
      # end
      if phone_is_shangjia
        # 对于商家，也不存在口令，直接return
        UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                              name: name,
                                              phone: phone,
                                              note: note,
                                              fabushijian: time,
                                              is_cheshang: "1"
        return
      end

      id = car_user_info.detail_url.match /ershouche\/(\d{8,15})x\.shtml/
      id = id[1]
      id_response = RestClient.get("http://app.58.com/api/windex/scandetail/car/#{id}/")
      id_response = id_response.body
      id_response = Nokogiri::HTML(id_response)
      # phone = id_response.css('.nums').text
      # phone = phone.gsub('-', '')


      kouling = id_response.css('.info-short_url').text
      kouling = kouling.match(/http(.)*$/)[0]
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            # phone: phone,
                                            note: note,
                                            fabushijian: time,
                                            wuba_kouling: kouling

      car_user_info = car_user_info.reload
      UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info
      car_user_info = car_user_info.reload
      if car_user_info.is_real_cheshang or car_user_info.is_pachong or !car_user_info.is_city_match
        car_user_info.wuba_kouling_status = 'cheshang-butijiao'
        car_user_info.save!
      else
        # 只抓非车商手机号
        unless kouling.blank?
          UserSystem::KouLingCarUserInfo.create_kouling_car_user_info car_user_info.id
        end
      end


    rescue Exception => e
      pp e
      pp $@
      car_user_info.need_update = false
      car_user_info.save
    end
  end


  def self.get_normal_url_by_short_url_and_city short_url, city_code
    begin
      params = URI.decode_www_form(short_url)
      params_hash = {}
      params.each do |p|
        params_hash[p[0]] = p[1]
      end
      entry_id = params_hash["entinfo"]
      entry_id = entry_id.split('_')[0]
      url = "http://#{city_code}.58.com/ershouche/#{entry_id}x.shtml"
      return url
    rescue Exception => e
      pp e
      pp '解析short url  出错'
      return nil
    end
  end


end

__END__


  # Wuba.update_detail
  # def self.update_detail
  #   threads = []
  #   # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: '58'
  #   car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, '58', UserSystem::CarUserInfo::CURRENT_ID]
  #   car_user_infos.each do |car_user_info|
  #     next unless car_user_info.name.blank?
  #     next unless car_user_info.phone.blank?
  #     next if car_user_info.detail_url.match /zhineng/
  #
  #     if threads.length > 15
  #       sleep 2
  #     end
  #     threads.delete_if { |thread| thread.status == false }
  #     t = Thread.new do
  #       begin
  #         puts '开始跑明细'
  #
  #         # detail_content = `curl '#{car_user_info.detail_url}'`
  #         # car_user_info = UserSystem::CarUserInfo.find(199946)
  #         pp car_user_info.detail_url
  #         response = RestClient.get(car_user_info.detail_url)
  #
  #         detail_content = response.body
  #         detail_content = Nokogiri::HTML(detail_content)
  #         time = detail_content.css('.mtit_con_left .time').text
  #         name = detail_content.css('.lineheight_2').children[3].text
  #         note = begin
  #           detail_content.css('.part_detail').children[2].text.gsub(/\t|\r|\n/, '') rescue '暂无'
  #         end
  #
  #
  #         id = car_user_info.detail_url.match /ershouche\/(\d{8,15})x\.shtml/
  #         id = id[1]
  #         id_response = RestClient.get("http://app.58.com/api/windex/scandetail/car/#{id}/")
  #         id_response = id_response.body
  #         id_response = Nokogiri::HTML(id_response)
  #         phone = id_response.css('.nums').text
  #         phone = phone.gsub('-', '')
  #         UserSystem::CarUserInfo.update_detail id: car_user_info.id,
  #                                               name: name,
  #                                               phone: phone,
  #                                               note: note,
  #                                               fabushijian: time
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