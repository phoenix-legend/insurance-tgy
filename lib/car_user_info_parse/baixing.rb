module Baixing

  # Baixing.get_car_user_list
  def self.get_car_user_list party = 0
    pp "现在时间:#{Time.now.chinese_format}"
    city_number = 0
    # city_hash = ::UserSystem::CarUserInfo::BAIXING_PINYIN_CITY
    city_hash = ::UserSystem::CarUserInfo.get_baixing_sub_cities party
    city_hash.each_pair do |areaid, areaname|

      if UserSystem::CarUserInfo::CITY3.include? areaname
        city_number += 1
        if city_number%7 == 0
          pp '...... 跑一类城市'
          UserSystem::CarUserInfo.run_baixing 0  #常规城市跑7个， 一类重点城市跑一遍
        end

        if city_number%13 == 0
          pp '...... 跑二类城市'
          UserSystem::CarUserInfo.run_baixing 1  #常规城市跑13个， 二类重点城市跑一遍
        end
      end
      begin
        pp "现在跑..百姓 #{areaname}"
        1.upto 3 do |i|
          url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}" # url = "http://haerbin.baixing.com/m/ershouqiche/?page=1&per_page=10"
          content = RestClientProxy.get url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}

          if content.blank?
            pp '内容为空'
            break
          end
          # content.gsub!('item top', 'eric')
          # content.gsub!('item pinned', 'eric')
          content.gsub!('item special', 'eric')
          content = Nokogiri::HTML(content)
          car_infos = content.css('.eric')
          car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
          if car_infos.blank?
            pp 'car info 不存在'
            break
          end
          car_number = car_infos.length
          exists_car_number = 0
          car_infos.each do |car_info|
            detail_url = car_info.css('a')[0].attributes['href'].value
            # price = car_info.css('.price').text
            # chexing = car_info.css('a').children[0].text
            is_cheshang = 0
            next if detail_url.match /redirect/
            result = UserSystem::CarUserInfo.create_car_user_info che_ling: "3010",
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
            pp "百姓 本页数据全部存在，跳出 #{car_number}"
            break
          end
        end
      rescue Exception => e
        pp e
      end
    end
  end


  #Baixing.get_car_user_list_v2 content, areaid
  def self.get_car_user_list_v2 content, areaid
    areaname = UserSystem::CarUserInfo::BAIXING_PINYIN_CITY[areaid]
    return if areaname.blank?
    begin
      return if content.blank?
      content.gsub!('item special', 'eric')
      content = Nokogiri::HTML(content)
      car_infos = content.css('.eric')
      car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
      return if car_infos.blank?
      car_infos.each do |car_info|
        detail_url = car_info.css('a')[0].attributes['href'].value
        is_cheshang = 0
        next if detail_url.match /redirect/
        result = UserSystem::CarUserInfo.create_car_user_info che_ling: "4010",
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
      end
    rescue Exception => e
      pp e
    end

  end

  # Baixing.update_one_detail
  def self.update_one_detail car_user_info_id
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id
    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?

    begin
      puts '更新明细'
      # detail_url = "http://guangzhou.baixing.com/m/ershouqiche/a1028370758.html"
      detail_url = car_user_info.detail_url.gsub('baixing.com/ershouqiche/', 'baixing.com/m/ershouqiche/')

      response = RestClientProxy.get(detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'})

      detail_content1 = response

      if response.match /此信息未通过审核/
        car_user_info.need_update = false
        car_user_info.save
        return
      end

      detail_content1.gsub!('content normal-content long-content', 'eric_content')
      detail_content1.gsub!('content normal-content', 'eric_content')
      detail_content1.gsub!('friendly datetime', 'fabushijian')

      detail_content = Nokogiri::HTML(detail_content1)

      phone = nil
      begin
        phone = detail_content.css(".num")[0].text
      rescue Exception => e
        # pp detail_content1
        phone = detail_content.css(".contact-main-txt")[0].text
      end

      che_xing = detail_content.css(".title h1").text
      fabushijian = begin
        detail_content.css(".fabushijian").text rescue '2010-01-01'
      end

      che_ling = begin
        detail_content.css(".detail .content .info").children[0].children[0].content rescue '3010-01'
      end
      che_ling = che_ling.split('-')[0]
      licheng = begin
        detail_content.css(".detail .content .info").children[1].children[0].content rescue '80000'
      end

      metas = detail_content.css(".top-meta li")
      metas.each do |meta|
        if meta.children[0].text.match /上牌/
          che_ling = meta.children[1].text.split('年')[0]
        end
        if meta.children[0].text.match /里程/
          licheng = meta.children[1].text
        end
      end
      licheng = licheng.gsub(/万|公里/, '')

      if che_ling == '暂无'
        che_ling = '2013'
        licheng = '4'
      end


      name = '先生女士'
      note = begin
        detail_content.css(".eric_content")[0].text rescue ''
      end

      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: note,
                                            fabushijian: fabushijian,
                                            # brand: brand,
                                            che_xing: che_xing,
                                            che_ling: che_ling,
                                            licheng: licheng
    rescue Exception => e
      pp e
      pp $@
      redis = Redis.current
      redis[car_user_info.detail_url] = 'n'
      redis.expire car_user_info.detail_url, 60
      car_user_info.destroy

      # car_user_info.need_update = false
      # car_user_info.save
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
        note = begin
          detail_content.css(".eric_content")[0].text rescue ''
        end
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
