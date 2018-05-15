module Che168

  def self.test
    Che168.get_car_user_list 0
    Che168.get_car_user_list 1
    Che168.get_car_user_list 2
  end

  require 'timeout'


  # Che168.get_car_user_list 0
  def self.get_car_user_list party = 0
    # sleep 10
    # return 0
    city_hash = ::UserSystem::CarUserInfo.get_che168_sub_cities party
    city_hash.each_pair do |areaid, areaname|
      begin
        timeout(40) do
          if rand(100) < 5
            `curl  'https://m.che168.com/personal/23387110.html' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
  -H 'Cache-Control: max-age=0' \
  -H 'Cookie: sessionid=25e4b37e-7b66-480d-b17a-5e0fab529500; __utma=247243734.84789044.1442387486.1463541274.1463541274.1; appadfirst=1; uarea=410100%7Czhengzhou; UsedCarBrowseHistory=0%3A23387005%2C0%3A23234620%2C0%3A23079771%2C0%3A22677660%2C0%3A20939328%2C0%3A23235438%2C0%3A23235774%2C0%3A20405753; sessionip=183.193.41.173; area=310199; sessionvisit=7e560f1c-aaaa-4552-87d1-ced660d222e6; sessionvisitInfo=25e4b37e-7b66-480d-b17a-5e0fab529500||100864; Hm_lvt_0f2ac73eb429af8bb7f48d01f2a25a25=1504974280,1505573318; Hm_lpvt_0f2ac73eb429af8bb7f48d01f2a25a25=1505573318; _ga=GA1.3.84789044.1442387486; _gid=GA1.3.1972352028.1505573318; _gat=1; sessionuid=25e4b37e-7b66-480d-b17a-5e0fab529500' \
  -H 'Connection: keep-alive' --compressed`
          end



        sleep 0.5
        brand = UserSystem::CarBrand.first  rand(100) < 30

        list_url = "https://m.che168.com/#{areaid}/a0_0ms1dgscncgpiltocsp1ex/?pvareaid=103759"
        response = `curl #{list_url} -c "~/tmp_cookie"  -b "~/tmp_cookie"`


        response = Nokogiri::HTML(response)
        details = response.css(".list-base li a")
          pp details.length
        details.each do |detail|
          url = begin
            detail.attributes["href"].value rescue ''
          end
          pp url
          next if url.blank?
          che_xing = begin
            detail.css("h3 span").text rescue ''
          end
          # pp che_xing
          che_infos = detail.css("p b")
          che_ling = che_infos[1].text
          licheng = che_infos[0].text
          price = detail.css("ins").text
          detail_url = "http:#{url.split(".html")[0]}.html?type=1"
          real_url = "https:#{url}"
          # detail_response = `curl #{real_url} -b "/data/tmp_cookie"`
          pp "现在跑168.. #{areaname}"
          result = UserSystem::CarUserInfo.create_car_user_info2 che_xing: che_xing,
                                                                 che_ling: che_ling,
                                                                 milage: licheng,
                                                                 detail_url: detail_url,
                                                                 wuba_kouling: real_url,
                                                                 city_chinese: areaname,
                                                                 site_name: 'che168'
          if not result.blank?

            Che168.update_one_detail result

          end
        end
        end
      rescue
      end

    end
  end


# Che168.get_car_user_list
# def self.get_car_user_list party = 0
#   car_price_start = 1
#   car_price_end = 1000
#   number_per_page = 10
#   # city_hash = ::UserSystem::CarUserInfo::ALL_CITY
#   city_hash = ::UserSystem::CarUserInfo.get_che168_sub_cities party
#
#   (1..200).each do |i|
#     city_hash.each_pair do |areaid, areaname|
#
#       if Thread.list.length > 8
#         while true
#           if Thread.list.length < 10
#             break
#           else
#             sleep 0.5
#           end
#         end
#       end
#       Thread.start do
#         begin
#           pp "现在跑168.. #{areaname}"
#           1.upto 1 do |i|
#             content = RestClient.get "http://m.che168.com/handler/getcarlist.ashx?num=#{number_per_page}&pageindex=#{i}&brandid=0&seriesid=0&specid=0&price=#{car_price_start}_#{car_price_end}&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0"
#             content = content.body
#             break if content.blank?
#             a = JSON.parse content
#             break if a.length == 0
#             car_number = a.length
#             exists_car_number = 0
#             a.each do |info|
#               url = "http://m.che168.com#{info["url"]}"
#               url = begin
#                 url.split('#')[0] rescue ''
#               end
#               next if url.match /m\.hao\.autohome\.com\.cn/
#               result = UserSystem::CarUserInfo.create_car_user_info che_xing: info["carname"],
#                                                                     che_ling: info["date"],
#                                                                     milage: info['milage'],
#                                                                     detail_url: url,
#                                                                     city_chinese: areaname,
#                                                                     site_name: 'che168'
#
#               if result == 0
#                 u = url
#
#                 unless u.blank?
#                   c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
#                   Che168.update_one_detail c.id if not c.blank?
#                 end
#               end
#
#               exists_car_number = exists_car_number + 1 if result == 1
#             end
#             if car_number - exists_car_number < 3
#               puts 'che 168 本页数据全部存在，跳出'
#               break
#             end
#           end
#           ActiveRecord::Base.connection.close
#         rescue Exception => e
#           pp e
#         end
#         ActiveRecord::Base.connection.close
#       end
#
#     end
#   end
#
# end
#
# def self.get_car_user_list_v2 content, areaid
#   areaname = UserSystem::CarUserInfo::ALL_CITY[areaid]
#
#   begin
#     pp "现在跑168.. #{areaname}"
#     return if content.blank?
#     a = JSON.parse content
#     return if a.length == 0
#     a.each do |info|
#       url = "http://m.che168.com#{info["url"]}"
#       url = begin
#         url.split('#')[0] rescue ''
#       end
#       next if url.match /m\.hao\.autohome\.com\.cn/
#       result = UserSystem::CarUserInfo.create_car_user_info che_xing: "~#{info["carname"]}",
#                                                             che_ling: info["date"],
#                                                             milage: info['milage'],
#                                                             detail_url: url,
#                                                             city_chinese: areaname,
#                                                             site_name: 'che168'
#
#       if result == 0
#         u = url
#
#         unless u.blank?
#           c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
#           Che168.update_one_detail c.id if not c.blank?
#         end
#       end
#     end
#   rescue Exception => e
#     pp e
#   end
# end

# def self.update_detail
#   threads = []
#   # car_user_infos = UserSystem::CarUserInfo.where need_update: true, site_name: 'che168'
#   car_user_infos = UserSystem::CarUserInfo.where ["need_update = ? and site_name = ? and id > ?", true, 'che168', UserSystem::CarUserInfo::CURRENT_ID]
#   car_user_infos.each do |car_user_info|
#     next unless car_user_info.name.blank?
#     next unless car_user_info.phone.blank?
#     next if car_user_info.detail_url.match /m\.hao\.autohome\.com\.cn/
#     if threads.length > 15
#       sleep 2
#     end
#     threads.delete_if { |thread| thread.status == false }
#     t = Thread.new do
#       begin
#         puts '开始跑明细'
#
#         # detail_content = `curl '#{car_user_info.detail_url}'`
#         # pp car_user_info.detail_url
#         # k = "http://m.che168.com/personal/23235774.html?type=1"
#         response = RestClient.get(car_user_info.detail_url)
#         pp
#         detail_content = response.body
#         phone = detail_content.match /tel:(\d{11})/
#         phone = phone[1]
#         detail_content = Nokogiri::HTML(detail_content)
#         # connect_info = detail_content.css("#callPhone")[0]
#         name = "车主"#connect_info.css("span").text.strip
#         # phone = products_content.match /tel:(\d{11})/#connect_info.attributes["data-telno"].value.strip
#         note = begin
#           detail_content.css("#js-message")[0].text.strip rescue ''
#         end
#         # time = detail_content.css(".carousel-images h2")[0].text.gsub("发布", '').strip[0..9]
#
#         price = begin  detail_content.css(".info-price")[0].text.gsub("¥", '').strip end
#
#         UserSystem::CarUserInfo.update_detail id: car_user_info.id,
#                                               name: name,
#                                               phone: phone,
#                                               note: note,
#                                               price: price
#                                               # fabushijian: time
#
#       rescue Exception => e
#         pp e
#         pp $@
#         car_user_info.need_update = false
#         car_user_info.save
#         ActiveRecord::Base.connection.close
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


# Che168.update_one_detail 14069841
  def self.update_one_detail car_user_info_id
    # pp "%%%"*15

    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /m\.hao\.autohome\.com\.cn/

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
      kouling_url = car_user_info.wuba_kouling
      # new_url = "#{kouling_url.split(".html")[0]}.html#{CGI::escape kouling_url.split(".html")[1]}"
      # response = `curl #{car_user_info.wuba_kouling} -b "~/tmp_cookie"`


      response = `curl  '#{car_user_info.detail_url.gsub("?type=1", '').gsub('http:','https:')}' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
  -H 'Cache-Control: max-age=0' \
  -H 'Cookie: sessionid=25e4b37e-7b66-480d-b17a-5e0fab529500; __utma=247243734.84789044.1442387486.1463541274.1463541274.1; appadfirst=1; uarea=410100%7Czhengzhou; UsedCarBrowseHistory=0%3A23387005%2C0%3A23234620%2C0%3A23079771%2C0%3A22677660%2C0%3A20939328%2C0%3A23235438%2C0%3A23235774%2C0%3A20405753; sessionip=183.193.41.173; area=310199; sessionvisit=7e560f1c-aaaa-4552-87d1-ced660d222e6; sessionvisitInfo=25e4b37e-7b66-480d-b17a-5e0fab529500||100864; Hm_lvt_0f2ac73eb429af8bb7f48d01f2a25a25=1504974280,1505573318; Hm_lpvt_0f2ac73eb429af8bb7f48d01f2a25a25=1505573318; _ga=GA1.3.84789044.1442387486; _gid=GA1.3.1972352028.1505573318; _gat=1; sessionuid=25e4b37e-7b66-480d-b17a-5e0fab529500' \
  -H 'Connection: keep-alive' --compressed`

      pp response

      # response = `curl http://m.che168.com/personal/23278228.html#pvareaid=100864#pos=24#isRecom=0#rtype=0#page=1#filter=0a0a0_0a0_0a0_0#module=3 -b "/data/tmp_cookie"`

      # pp response

      phone = (response.match /tel:(\d{11})/)[1]
      # detail_content = Nokogiri::HTML(response)

      name = "车主"


      # pp "+++"*20
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone


    rescue Exception => e
      pp e
      pp $@
      car_user_info.need_update = false
      car_user_info.save
    end
  end


end