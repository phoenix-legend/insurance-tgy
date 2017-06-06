module Baixing

  #获取来自vps的detail_url, 然后判断是否存在,返回不存在的链接
  def self.get_detail_urls_for_vps urls
    return [] if urls.blank?
    redis = Redis.current
    return_urls = []
    urls.each do |url|
      next unless url.match /ershouqiche|ershouche|che168/
      next if redis[url] == 'y'
      cui = UserSystem::CarUserInfo.where detail_url: url
      next unless cui.blank?
      return_urls << url
    end

    return return_urls
  end

  #接受来自vps的参数,创建并提交到相对应的网站
  def self.create_car_user_infos_from_vps params
    result = UserSystem::CarUserInfo.create_car_user_info che_ling: "3010",
                                                          milage: 8.8,
                                                          detail_url: params[:detail_url],
                                                          city_chinese: params[:city_chinese],
                                                          site_name: params[:site_name],
                                                          is_cheshang: params[:is_cheshang]
    if result == 0
      u = params[:detail_url]
      unless u.blank?
        car_user_info = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first

        UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                              name: params[:name],
                                              phone: params[:phone],
                                              note: params[:note],
                                              fabushijian: params[:fabushijian],
                                              che_xing: params[:che_xing],
                                              che_ling: params[:che_ling],
                                              licheng: params[:milage]
      end
    end
  end

  def self.get_car_user_list_for_vps party, is_continue = "true"
    t = Time.now.to_i - 60

    city_hash = ::UserSystem::CarUserInfo.get_baixing_sub_cities party
    city_hash.each_pair do |areaid, areaname|
      begin
        pp "现在跑..百姓 #{areaname}"
        i = 1
        url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}"
        # sleep 2+rand(5)
        if Time.now.to_i - t > 40
          RestClientProxy.restart_vps_pppoe
          t = Time.now.to_i
        end
        content = RestClient.get url, {
            'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
            'Cookie' => '__trackId=145580384816263; gr_user_id=72d355ac-f1e1-4d96-be12-3ea8cfd67970; BDTUJIAID=ef984cb6f7678800238c64e4353d9720; FTAPI_BLOCK_SLOT=FUCKIE; FTAPI_ST=FUCKIE; FTAPI_PVC=1011094-1-io5eyl3m; __city=shanghai; __s=nbsqplqpt45kb1ch3kp3i42651; Hm_lvt_5a727f1b4acc5725516637e03b07d3d2=1489068517; Hm_lpvt_5a727f1b4acc5725516637e03b07d3d2=1489068517; _gat=1; __sense_session_pv=2; _ga=GA1.2.716856832.1455803851; Hm_lvt_767685c7b1f25e1d49aa5a5f9555dc7d=1489068526; Hm_lpvt_767685c7b1f25e1d49aa5a5f9555dc7d=1489068526'
        }
        if content.blank?
          pp '内容为空'
          next
        end

        content.gsub!('item special', 'eric')
        content = Nokogiri::HTML(content)
        car_infos = content.css('.eric')
        car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
        if car_infos.blank?
          pp 'car info 不存在'
          next
        end


        detail_urls = []
        car_infos.each do |car_info|
          detail_url = car_info.css('a')[0].attributes['href'].value
          next unless url.match /ershouqiche/
          detail_urls << detail_url
        end

        pp "获取到#{detail_urls.length}条记录, 准备推送"
        url_string = detail_urls.join('!!!')

        response = RestClient.post 'http://che.uguoyuan.cn/api/v1/update_user_infos/vps_urls', {urls: url_string}
        response = JSON.parse(response.body)
        pp response["data"].length rescue ''
        next if response["code"] > 0
        detail_urls = response["data"]

        detail_urls.each do |detail_url|
          puts '更新明细'
          new_detail_url = detail_url.gsub('baixing.com/ershouqiche/', 'baixing.com/m/ershouqiche/')
          if Time.now.to_i - t > 40
            RestClientProxy.restart_vps_pppoe
            t = Time.now.to_i
            # sleep 2+rand(5)
          end
          response = RestClient.get(new_detail_url, {
              'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
              'Cookie' => '__trackId=145580384816263; gr_user_id=72d355ac-f1e1-4d96-be12-3ea8cfd67970; BDTUJIAID=ef984cb6f7678800238c64e4353d9720; FTAPI_BLOCK_SLOT=FUCKIE; FTAPI_ST=FUCKIE; FTAPI_PVC=1011094-1-io5eyl3m; __city=shanghai; __s=nbsqplqpt45kb1ch3kp3i42651; Hm_lvt_5a727f1b4acc5725516637e03b07d3d2=1489068517; Hm_lpvt_5a727f1b4acc5725516637e03b07d3d2=1489068517; _gat=1; __sense_session_pv=2; _ga=GA1.2.716856832.1455803851; Hm_lvt_767685c7b1f25e1d49aa5a5f9555dc7d=1489068526; Hm_lpvt_767685c7b1f25e1d49aa5a5f9555dc7d=1489068526'})
          detail_content1 = response

          next if response.match /此信息未通过审核/

          detail_content1.gsub!('content normal-content long-content', 'eric_content')
          detail_content1.gsub!('content normal-content', 'eric_content')
          detail_content1.gsub!('friendly datetime', 'fabushijian')
          detail_content1.gsub!('bx-top-meta-list', 'bxtopmetalist')

          detail_content = Nokogiri::HTML(detail_content1)
          phone = nil
          begin
            phone = detail_content.css(".num")[0].text
          rescue Exception => e
            begin
              phone = detail_content.css(".contact-main-txt")[0].text
            rescue Exception => e
              pp "car_user_info id is   #{detail_url}"
              raise e
            end
          end

          che_xing = detail_content.css(".title h1").text
          fabushijian = begin
            detail_content.css(".fabushijian").text rescue '2010-01-01'
          end

          che_ling = begin
            detail_content.css(".bxtopmetalist li")[1].css('div').text.split('年')[0] rescue '2010'
          end

          licheng = begin
            detail_content.css(".bxtopmetalist li")[2].css('div').text.to_i.to_s rescue '8'
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

          a = {:detail_url => detail_url,
               name: name,
               phone: phone,
               note: note,
               fabushijian: fabushijian,
               che_xing: che_xing,
               che_ling: che_ling,
               milage: licheng,
               city_chinese: areaname,
               site_name: 'baixing',
               is_cheshang: 0
          }



          RestClient.post 'http://che.uguoyuan.cn/api/v1/update_user_infos/vps_create_and_upload', {cui: a}
          # over, 下一个提交
        end
      rescue Exception => e
        pp e
      end

    end

    if party == 1 and is_continue == 'true'
      Baixing.get_car_user_list_for_vps 2
    elsif party == 0 and is_continue == 'true'
      Baixing.get_car_user_list_for_vps 1
    else
      # Baixing.get_car_user_list_for_vps 0
      nil
    end


  end


  # Baixing.get_car_user_list
  def self.get_car_user_list party = 0
    pp "现在时间:#{Time.now.chinese_format}"
    city_number = 0
    # city_hash = ::UserSystem::CarUserInfo::BAIXING_PINYIN_CITY
    city_hash = ::UserSystem::CarUserInfo.get_baixing_sub_cities party
    city_hash.each_pair do |areaid, areaname|

      # if UserSystem::CarUserInfo::CITY3.include? areaname
      #   city_number += 1
      #   if city_number%7 == 0
      #     pp '...... 跑一类城市'
      #     UserSystem::CarUserInfo.run_baixing 0 #常规城市跑7个， 一类重点城市跑一遍
      #   end
      #
      #   if city_number%13 == 0
      #     pp '...... 跑二类城市'
      #     UserSystem::CarUserInfo.run_baixing 1 #常规城市跑13个， 二类重点城市跑一遍
      #   end
      # end
      begin
        pp "现在跑..百姓 #{areaname}"
        1.upto 1 do |i|
          url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}" # url = "http://haerbin.baixing.com/m/ershouqiche/?page=1&per_page=10"

          content = RestClientProxy.get url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}

          if content == '503 Service Unavailable'
            sleep 3
            next
          end

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
      detail_content1.gsub!('bx-top-meta-list', 'bxtopmetalist')

      detail_content = Nokogiri::HTML(detail_content1)

      phone = nil
      begin
        phone = detail_content.css(".num")[0].text
      rescue Exception => e
        # pp detail_content1
        begin
          phone = detail_content.css(".contact-main-txt")[0].text
        rescue Exception => e
          pp "car_user_info id is   #{car_user_info_id}"
          raise e

        end
      end

      che_xing = detail_content.css(".title h1").text
      fabushijian = begin
        detail_content.css(".fabushijian").text rescue '2010-01-01'
      end

      che_ling = begin
        detail_content.css(".bxtopmetalist li")[1].css('div').text.split('年')[0] rescue '2010'
      end
      che_ling = che_ling.split('-')[0]
      licheng = begin
        detail_content.css(".bxtopmetalist li")[2].css('div').text.to_i.to_s rescue '8'
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

        response = RestClientProxy.get(detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'})
        if response.match /此信息未通过审核/
          car_user_info.need_update = false
          car_user_info.save
          next
        end

        detail_content1 = response.body
        detail_content1.gsub!('content normal-content long-content', 'eric_content')
        detail_content = Nokogiri::HTML(detail_content1)
        licheng = '8'
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
