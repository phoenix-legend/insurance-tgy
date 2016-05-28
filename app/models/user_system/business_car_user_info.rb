class UserSystem::BusinessCarUserInfo < ActiveRecord::Base
  require 'rest-client'
  require 'pp'


  def self.create_car_user_info options
    user_infos = UserSystem::BusinessCarUserInfo.where detail_url: options[:detail_url]
    return nil if user_infos.length > 0

    car_user_info = UserSystem::BusinessCarUserInfo.new options
    car_user_info.save!
    car_user_info.id
  end

  # UserSystem::BusinessCarUserInfo.pc_ganji
  def self.pc_ganji
    city_hash = ::UserSystem::CarUserInfo::GANJI_CITY
    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 8
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 2
      end
      t = Thread.new do
        begin
          pp "现在跑赶集.. #{areaname}"
          1.upto 50 do |i|
            url = "http://wap.ganji.com/#{areaid}/ershouche/?back=search&agent=2&deal_type=1&page=#{i}"
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


              new_url = detail_url.split('?')[0]
              if not new_url.match /^http/
                new_url = "http://wap.ganji.com/#{areaid}/ershouche/#{new_url}?type=58"
              end
              cui_id = UserSystem::BusinessCarUserInfo.create_car_user_info che_xing: chexing,
                                                                            che_ling: cheling,
                                                                            milage: licheng,
                                                                            detail_url: new_url,
                                                                            city_chinese: areaname,
                                                                            price: price,
                                                                            site_name: 'ganji'



              unless cui_id.blank?
                update_ganji_one_detail cui_id
              end


              exists_car_number = exists_car_number + 1 if cui_id.blank?
            end
            # 这里的数字代表还有几个是新的。 如果还有8辆以上是新车，继续翻页。 8以下，不翻。
            if car_number - exists_car_number < 3
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

  #UserSystem::BusinessCarUserInfo.pc
  def self.pc_wuba lest_number = 3
    city_hash = ::UserSystem::CarUserInfo::WUBA_CITY.merge('wz' => '温州')
    # city_hash = {'wz' => '温州'}
    city_hash.each_pair do |areaid, areaname|
      pp "现在跑..58.. #{areaname}"
      1.upto 20 do |i|

        url = "http://#{areaid}.58.com/ershouche/1/pn#{i}/"
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

          result = UserSystem::BusinessCarUserInfo.create_car_user_info che_xing: chexing,
                                                                        price: price,
                                                                        che_ling: cheling,
                                                                        milage: milage,
                                                                        detail_url: url.split('?')[0],
                                                                        city_chinese: areaname,
                                                                        site_name: '58'

          if not result.blank?
            update_business_wuba result
          end
          exists_car_number = exists_car_number + 1 unless result.blank?
        end
        if car_number - exists_car_number < lest_number
          pp '58 本页数据全部存在，跳出'
          break
        end
      end

    end
  end


  # UserSystem::BusinessCarUserInfo.update_business_wuba 1
  def self.update_business_wuba car_user_info_id
    car_user_info = UserSystem::BusinessCarUserInfo.find car_user_info_id
    return unless car_user_info.phone.blank?
    response = RestClient.get car_user_info.detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}

    detail_content = response.body
    detail_content.gsub!('intro-per', 'personname')
    detail_content.gsub!('abstract-info-txt clear', 'fbsj')
    detail_content.gsub!('detailinfo-box desClose', 'notenote')
    detail_content.gsub!('meta-phone', 'phoneppp')


    detail_content = Nokogiri::HTML(detail_content)

    name = detail_content.css('.personname').text
    name.gsub!(/\(|\)|个人|商家/, '')


    time = detail_content.css('.fbsj').text
    time.gsub!('发布：', '')
    time.strip!

    phone = time = detail_content.css('.phoneppp').text


    note = begin
      detail_content.css('.notenote').text rescue ''
    end
    note.gsub!('联系我时，请说是在58同城上看到的，谢谢！', '')

    car_user_info.name = name
    car_user_info.fabushijian = time
    car_user_info.phone = phone
    car_user_info.note = note
    car_user_info.save!
    car_user_info.update_brand

  end

  def self.update_ganji_one_detail car_user_info_id
    car_user_info = UserSystem::BusinessCarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/


    begin
      pp "开始跑明细 #{car_user_info.id}"

      response = RestClient.get(car_user_info.detail_url)
      detail_content = response.body
      detail_content = Nokogiri::HTML(detail_content)
      note, phone, name = '', '', ''
      ps = detail_content.css('.detail-describe p')
      if ps.blank?
        response = RestClient.get(car_user_info.detail_url)
        detail_content = response.body
        detail_content = Nokogiri::HTML(detail_content)
        note, phone, name = '', '', ''
        ps = detail_content.css('.detail-describe p')
        if ps.blank?
          pp "ps 为空，网页异常"
          # car_user_info.destroy!
          return
        end
      end
      ps.each do |p|
        text = begin
          p.text rescue ''
        end
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

      note = note.gsub('详细信息：', '')
      name = name.gsub('联系人：', '')
      phone = phone.gsub('电话：', '')
      fabushijian = detail_content.css('.mod-detail .detail-meta span')[0].text
      fabushijian = fabushijian.gsub("发布:", '')
      fabushijian = fabushijian.gsub("\n", '')
      fabushijian = fabushijian.gsub("\r", '')
      fabushijian = fabushijian.gsub("  ", '')
      fabushijian = "2016-#{fabushijian}"

      pp "开始跑明细 #{car_user_info.id}  准备更新"

      car_user_info.name = name
      car_user_info.fabushijian = fabushijian
      car_user_info.phone = phone
      car_user_info.note = note
      car_user_info.save!
      car_user_info.update_brand

    rescue Exception => e
      pp '-------------------------------------'
      pp e
      pp $@

      car_user_info.save
    end


  end

  def update_brand
    return unless self.brand.blank?

    UserSystem::CarType.all.each do |t|
      if self.che_xing.match Regexp.new(t.name)
        self.brand = t.car_brand.name
        self.cx = t.name
        self.save!
        break
      end
    end

    return unless self.brand.blank?

    UserSystem::CarBrand.all.each do |brand|
      if self.che_xing.match Regexp.new(brand.name)
        self.brand = brand.name
        self.save!
        break
      end
    end

  end

end
