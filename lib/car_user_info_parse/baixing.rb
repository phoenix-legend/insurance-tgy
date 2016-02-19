module Baixing

  # Baixing.get_car_user_list
  def self.get_car_user_list
    city_hash = ::UserSystem::CarUserInfo::BAIXING_PINYIN_CITY

    city_hash.each_pair do |areaid, areaname|

      begin
        pp "现在跑..百姓 #{areaname}"
        1.upto 3 do |i|
          sleep 5
          url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}"

          content = RestClient.get url
          content = content.body
          break if content.blank?
          content = Nokogiri::HTML(content)
          car_infos = content.css('.item')
          car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
          break if car_infos.blank?
          car_number = car_infos.length
          exists_car_number = 0
          car_infos.each do |car_info|
            detail_url = car_info.css('a')[0].attributes['href'].value
            price = car_info.css('.price').text
            chexing = car_info.css('a').children[0].text
            is_cheshang = 0
            result = UserSystem::CarUserInfo.create_car_user_info che_xing: chexing,
                                                                  che_ling: "2010",
                                                                  milage: 8.8,
                                                                  detail_url: detail_url,
                                                                  city_chinese: areaname,
                                                                  price: price,
                                                                  site_name: 'baixing',
                                                                  is_cheshang: is_cheshang

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

  # Baixing.update_detail
  def self.update_detail

    car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'baixing'
    car_user_infos.each do |car_user_info|
      sleep 3
      next unless car_user_info.name.blank?
      next unless car_user_info.phone.blank?

      begin
        puts '开始跑明细'
        # car_user_info = UserSystem::CarUserInfo.find 178505
        pp car_user_info.detail_url
        response = RestClient.get(car_user_info.detail_url)
        pp
        detail_content1 = response.body
        detail_content = Nokogiri::HTML(detail_content1)
        note, phone, name, fabushijian = '', '', '先生女士', ''
        ps = detail_content.css('.main ul li')
        next if ps.blank?
        ps.each do |p|
          text = begin
            p.text rescue ''
          end
          case text
            when /联系人姓名：/
              name = text.split('：')[1]
            when /品牌/
              brand = text.split('：')[1]
            when /发布时间/
              fabushijian = begin
                p.children[1].attributes["datetime"].value.split('T')[0] rescue ''
              end
          end
        end
        brand = ps[1].css('a').text


        note = detail_content.css('.description').text
        phone = begin
          (detail_content1.match(/\["([0-9]{11})",/))[1] rescue ''
        end

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


      # pp "现在线程池中有#{threads.length}个。"
    end


  end


end
#######################
# module Baixing
#
#   # Baixing.get_car_user_list
#   def self.get_car_user_list
#     city_hash = ::UserSystem::CarUserInfo::BAIXING_PINYIN_CITY
#     threads = []
#     city_hash.each_pair do |areaid, areaname|
#       threads.delete_if { |thread| thread.status == false }
#       if threads.length > 30
#         pp "现在共有#{threads.length}个线程正在运行"
#         sleep 3
#       end
#       t = Thread.new do
#         begin
#           pp "现在跑.. #{areaname}"
#           1.upto 3 do |i|
#
#             url = "http://#{areaid}.baixing.com/m/ershouqiche/?page=#{i}"
#
#             content = RestClient.get url
#             content = content.body
#             break if content.blank?
#             content = Nokogiri::HTML(content)
#             car_infos = content.css('.item')
#             car_infos = car_infos.select { |c| c.css('.jiaji').length==0 }
#             break if car_infos.blank?
#             car_number = car_infos.length
#             exists_car_number = 0
#             car_infos.each do |car_info|
#               detail_url = car_info.css('a')[0].attributes['href'].value
#               price = car_info.css('.price').text
#               chexing = car_info.css('a').children[0].text
#               is_cheshang = 0
#               result = UserSystem::CarUserInfo.create_car_user_info che_xing: chexing,
#                                                                     che_ling: "2010",
#                                                                     milage: 8.8,
#                                                                     detail_url: detail_url,
#                                                                     city_chinese: areaname,
#                                                                     price: price,
#                                                                     site_name: 'baixing',
#                                                                     is_cheshang: is_cheshang
#
#               exists_car_number = exists_car_number + 1 if result == 1
#             end
#             if car_number - exists_car_number < 8
#               puts '赶集 本页数据全部存在，跳出'
#               break
#             end
#           end
#           ActiveRecord::Base.connection.close
#         rescue Exception => e
#           pp e
#           ActiveRecord::Base.connection.close
#         end
#       end
#       threads << t
#     end
#
#     1.upto(2000) do
#       sleep(1)
#       # pp '休息.......'
#       threads.delete_if { |thread| thread.status == false }
#       break if threads.blank?
#     end
#   end
#
#   # Baixing.update_detail
#   def self.update_detail
#     threads = []
#     car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'baixing'
#     car_user_infos.each do |car_user_info|
#       next unless car_user_info.name.blank?
#       next unless car_user_info.phone.blank?
#
#
#
#       if threads.length > 30
#         sleep 2
#       end
#       threads.delete_if { |thread| thread.status == false }
#       t = Thread.new do
#         begin
#           puts '开始跑明细'
#           # car_user_info = UserSystem::CarUserInfo.find 178505
#           pp car_user_info.detail_url
#           response = RestClient.get(car_user_info.detail_url)
#           pp
#           detail_content1 = response.body
#           detail_content = Nokogiri::HTML(detail_content1)
#           note, phone, name,fabushijian = '', '', '先生女士', ''
#           ps = detail_content.css('.main ul li')
#           next if ps.blank?
#           ps.each do |p|
#             text = begin
#               p.text rescue ''
#             end
#             case text
#               when /联系人姓名：/
#                 name = text.split('：')[1]
#               when /品牌/
#                 brand = text.split('：')[1]
#               when /发布时间/
#                 fabushijian = begin p.children[1].attributes["datetime"].value.split('T')[0] rescue '' end
#             end
#           end
#           brand = ps[1].css('a').text
#
#
#
#
#           note = detail_content.css('.description').text
#           phone = begin (detail_content1.match(/\["([0-9]{11})",/))[1] rescue '' end
#
#           UserSystem::CarUserInfo.update_detail id: car_user_info.id,
#                                                 name: name,
#                                                 phone: phone,
#                                                 note: note,
#                                                 fabushijian: fabushijian,
#                                                 brand: brand
#
#         rescue Exception => e
#           pp e
#           pp $@
#           car_user_info.need_update = false
#           car_user_info.save
#         end
#         ActiveRecord::Base.connection.close
#       end
#       threads << t
#       # pp "现在线程池中有#{threads.length}个。"
#     end
#
#     1.upto(2000) do
#       sleep(1)
#       # pp '休息.......'
#       threads.delete_if { |thread| thread.status == false }
#       break if threads.blank?
#     end
#
#   end
#
#
# end