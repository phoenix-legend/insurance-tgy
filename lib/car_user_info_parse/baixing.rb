module Baixing

  # Baixing.get_car_user_list
  def self.get_car_user_list
    pp "现在时间:#{Time.now.chinese_format}"
    city_hash = ::UserSystem::CarUserInfo::BAIXING_PINYIN_CITY
    city_hash.each_pair do |areaid, areaname|
      begin
        pp "现在跑..百姓 #{areaname}"
        1.upto 3 do |i|
          sleep 1
          url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}"  # url = "http://shanghai.baixing.com/m/ershouqiche/?page=1"
          content = RestClient.get url,{'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
          content = content.body
          break if content.blank?
          content.gsub!('item top', 'eric')
          content.gsub!('item pinned', 'eric')
          content.gsub!('item regular', 'eric')
          content = Nokogiri::HTML(content)
          car_infos = content.css('.eric')
          car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
          break if car_infos.blank?
          car_number = car_infos.length
          exists_car_number = 0
          car_infos.each do |car_info|
            detail_url = car_info.css('a')[0].attributes['href'].value
            # price = car_info.css('.price').text
            # chexing = car_info.css('a').children[0].text
            is_cheshang = 0
            result = UserSystem::CarUserInfo.create_car_user_info che_ling: "2010",
                                                                  milage: 8.8,
                                                                  detail_url: detail_url,
                                                                  city_chinese: areaname,
                                                                  # price: price,
                                                                  site_name: 'baixing',
                                                                  is_cheshang: is_cheshang
            if result == 0
              u = detail_url

              unless u.blank?
                c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
                Baixing.update_one_detail c.id if not c.blank?
              end
            end

            exists_car_number = exists_car_number + 1 if result == 1
          end
          if car_number - exists_car_number < 8
            puts '百姓 本页数据全部存在，跳出'
            break
          end
        end
      rescue Exception => e
        pp e
      end
    end
  end

  def self.update_one_detail car_user_info_id
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id
    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?

    begin
      puts '更新明细'
      detail_url = car_user_info.detail_url.gsub('baixing.com/ershouqiche/', 'baixing.com/m/ershouqiche/')
      sleep 2
      response = RestClient.get(detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'})
      if response.match /此信息未通过审核/
        car_user_info.need_update = false
        car_user_info.save
        return
      end

      detail_content1 = response.body
      detail_content1.gsub!('content normal-content long-content', 'eric_content')
      detail_content = Nokogiri::HTML(detail_content1)
      licheng = '80000'
      phone = detail_content.css(".num")[0].text
      che_xing = detail_content.css(".title h1").text
      name = '先生女士'
      note = begin detail_content.css(".eric_content")[0].text rescue '' end
      fabushijian = '2010-01-01'
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            fabushijian: fabushijian,
                                            # brand: brand,
                                            che_xing: che_xing,
                                            milage: licheng
    rescue Exception => e
      pp e
      pp $@
      car_user_info.need_update = false
      car_user_info.save
    end

  end

  # Baixing.update_detail
  def self.update_detail

    # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'baixing'
    car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'baixing', UserSystem::CarUserInfo::CURRENT_ID]

    car_user_infos.each do |car_user_info|

      pp car_user_info.id
      pp car_user_info.detail_url
      car_user_info = car_user_info.reload
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?

      begin
        puts '开始跑明细'
        # car_user_info = UserSystem::CarUserInfo.find 689516

        detail_url = car_user_info.detail_url.gsub('baixing.com/ershouqiche/', 'baixing.com/m/ershouqiche/')
        sleep 2
        response = RestClient.get(detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'})
        if response.match /此信息未通过审核/
          car_user_info.need_update = false
          car_user_info.save
          next
        end

        detail_content1 = response.body
        detail_content1.gsub!('content normal-content long-content', 'eric_content')
        detail_content = Nokogiri::HTML(detail_content1)
        licheng = '80000'
        phone = detail_content.css(".num")[0].text
        che_xing = detail_content.css(".title h1").text
        name = '先生女士'
        note = begin detail_content.css(".eric_content")[0].text rescue '' end
        fabushijian = '2010-01-01'
        UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                              name: name,
                                              phone: phone,
                                              note: note,
                                              fabushijian: fabushijian,
                                              # brand: brand,
                                              che_xing: che_xing,
                                              milage: licheng
      rescue Exception => e
        pp e
        pp $@
        car_user_info.need_update = false
        car_user_info.save
      end
    end


  end


end
