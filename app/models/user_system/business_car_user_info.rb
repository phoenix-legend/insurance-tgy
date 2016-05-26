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

  UserSystem::BusinessCarUserInfo.pc
  def self.pc lest_number = 3
    city_hash = ::UserSystem::CarUserInfo::WUBA_CITY
    city_hash.each_pair do |areaid, areaname|
      pp "现在跑58.. #{areaname}"
      1.upto 100 do |i|
        url = "http://#{areaid}.58.com/ershouche/1/pn#{i}/"
        content = RestClient.get url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
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
                                                                detail_url:   url.split('?')[0],
                                                                city_chinese: areaname,
                                                                site_name: '58'

          if not result.blank?
            u = url.split('?')[0]

            unless u.blank?
              # c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
              # Wuba.update_one_detail c.id if not c.blank?
            end
          end
          exists_car_number = exists_car_number + 1 if result == 1
        end
        if car_number - exists_car_number < lest_number
          pp '58 本页数据全部存在，跳出'
          break
        end
      end

    end
  end

end
