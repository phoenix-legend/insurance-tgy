class UserSystem::CarUserInfo < ActiveRecord::Base
  require 'rest-client'
  require 'pp'

  EMAIL_STATUS = {0 => '待导', 1 => '已导', 2 => '不导入'}

  def self.create_car_user_info options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return 1 if user_infos.length > 0

    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return 0
  end

  def self.send_email
    ::UserSystem::CarUserInfoSendEmail.transaction do
      #晚上不发邮件
      return if Time.now.hour < 9
      return if Time.now.hour > 20
      # 同一个小时不发两次邮件
      return if ::UserSystem::CarUserInfoSendEmail.had_send_email_in_current_hour?

      send_car_user_infos = self.need_send_mail_car_user_infos

      # 若需发送的数据量为0，则不发送邮件
      return if send_car_user_infos.blank?
      # = 0
      # = 0
      # shibai_count = 0

      success_count = send_car_user_infos.count { |info| info.upload_status == 'success' }
      cunzai_count = send_car_user_infos.count { |info| info.upload_status == 'yicunzai' }
      shibai_count = send_car_user_infos.count { |info| info.upload_status == 'shibai' }
      budaoru_count = send_car_user_infos.count { |info| info.upload_status == 'weidaoru' }

      zhuti = "#{success_count}成功#{cunzai_count}存在#{shibai_count}失败#{budaoru_count}不导"

      # 发送邮件


      MailSend.send_car_user_infos(self.generate_xls_of_car_user_info(send_car_user_infos),
                                   'chenkai@baohe001.com;tanguanyu@baohe001.com;yuanyuan@baohe001.com',
                                   '13472446647@163.com',
                                   send_car_user_infos.count,
                                   zhuti
      ).deliver


      send_car_user_infos.each { |u| u.update email_status: 1 }


      # 发完邮件，将对应的车主信息的邮件状态置为已发(1)

      # execute "update car_user_infos set email_status = 1 where id in "
      ''
    end

  end

  # UserSystem::CarUserInfo.get_haoche_sessionkey_and_yanzhengma
  def self.get_haoche_sessionkey_and_yanzhengma
    session_key = "#{Time.now.to_i}#{rand(10000000)}"
    # return session_key, ''
    url = "http://gw2.pahaoche.com/wghttp/randomImageServlet?Rand=4&sessionKey=#{session_key}"
    response = RestClient.get url
    `rm #{Rails.root}/public/downloads/*`
    file = File.new("#{Rails.root}/public/downloads/#{session_key}.jpg", 'wb')
    file.write response.body
    file.flush
    file.close
    file_name = file.path


    code = if Rails.env == "development"
             `tesseract #{file_name} stdout --tessdata-dir /Applications/OCRTOOLS.app/Contents/Resources/tessdata`
           else
             `tesseract #{file_name} stdout`
           end


    code = code.strip
    pp code
    code_match = code.match /\A(\d{4})\Z/
    puts '获取'
    if code_match
      return code_match[1], session_key
    else
      sleep 1
      return UserSystem::CarUserInfo.get_haoche_sessionkey_and_yanzhengma
    end
    code
  end


  # UserSystem::CarUserInfo.upload_to_haoche
  def self.upload_to_haoche
    car_user_infos = UserSystem::CarUserInfo.where "(upload_status = 'weidaoru' or (upload_status = 'shibai' and shibaiyuanyin = 'AuthCode is Wrong--E013')) and id > 70901"

    car_user_infos.each do |car_user_info|
      next if car_user_info.phone.blank?
      is_next = false
      unless car_user_info.note.blank?
        ["诚信", '到店', '精品车', '本公司', '提档', '双保险', '可按揭'].each do |word|
          if car_user_info.note.include? word
            is_next = true
          end
        end
      end

      next if is_next

      code, session_key = UserSystem::CarUserInfo.get_haoche_sessionkey_and_yanzhengma
      url = "http://gw2.pahaoche.com/wghttp/internal/booking"
      response = RestClient.post url, {:sessionKey => session_key,
                                       :authCode => code,
                                       :channel => 'yy-huayang-141219-012',
                                       :from => 'GW',
                                       :tokenKey => '8891E237-C4DB-4B79-A7A2-77DBB50D0779',
                                       :tokenValue => '3b783617-8bf6-4f03-ab11-7c6f46054ad2',
                                       :expectTime => '计划卖车时间:一周内',
                                       :name => car_user_info.name,
                                       :mobile => car_user_info.phone,
                                       :city => car_user_info.city_chinese,
                                       :vehicleType => "#{car_user_info.che_xing}-预期#{car_user_info.price}",
                                       :_ => session_key
                                    }
      pp response.body
      response_json = JSON.parse response.body
      if response_json["result"]
        car_user_info.upload_status = 'success'
        car_user_info.bookid = response_json["bookingId"]
        car_user_info.shibaiyuanyin = ""
      else
        if response_json["message"].match /Mobile\sexist:/
          car_user_info.upload_status = 'yicunzai'
          car_user_info.shibaiyuanyin = ""
        else
          car_user_info.upload_status = 'shibai'
          car_user_info.shibaiyuanyin = "#{response_json["message"]}--#{response_json["message_code"]}"
        end
      end
      car_user_info.save!
    end
  end


  #UserSystem::CarUserInfo.update_che168_detail2
  def self.update_che168_detail2 run_list = true, thread_number = 30
    # while true
      if run_list
        begin
          UserSystem::CarUserInfo.che168_get_car_list
        rescue Exception => e
        end
      end
      pp '.........列表跑完'
      threads = []
      car_user_infos = UserSystem::CarUserInfo.where need_update: true
      car_user_infos.each do |car_user_info|
        next unless car_user_info.name.blank?
        next unless car_user_info.phone.blank?
        next if car_user_info.detail_url.match /m\.hao\.autohome\.com\.cn/
        pp '------------------------------------'
        pp "现在线程池中有#{threads.length}个。"
        if threads.length > thread_number
          sleep 2
        end
        threads.delete_if { |thread| thread.status == false }
        t = Thread.new do
          begin
            puts '新的线程已创建'

            # detail_content = `curl '#{car_user_info.detail_url}'`
            response = RestClient.get(car_user_info.detail_url)

            detail_content = response.body
            detail_content = Nokogiri::HTML(detail_content)
            connect_info = detail_content.css("#LinkInfo")[0]
            name = connect_info.css(".info").text.strip
            phone = connect_info.css("#callPhone")[0].attributes["data-telno"].value
            note = detail_content.css(".cardet-message-2sc .text")[0].text
            time = detail_content.css(".noa .time")[0].text.gsub("发布日期：", '')
            price = detail_content.css(".price")[0].text

            response = RestClient.post "http://localhost:4000/api/v1/update_user_infos/update_car_user_info", {id: car_user_info.id,
                                                                                                               name: name,
                                                                                                               phone: phone,
                                                                                                               note: note,
                                                                                                               price: price,
                                                                                                               fabushijian: time}

          rescue Exception => e
            car_user_info.need_update = false
            car_user_info.save
          end
          ActiveRecord::Base.connection.close
        end
        threads << t
        pp "现在线程池中有#{threads.length}个。"
      end

      1.upto(2000) do
        sleep(1)
        pp '休息.......'
        threads.delete_if { |thread| thread.status == false }
        break if threads.blank?
      end


      begin
        UserSystem::CarUserInfo.upload_to_haoche
      rescue Exception => e

      end


      begin
        UserSystem::CarUserInfo.send_email
        pp Time.now.chinese_format
      rescue Exception => e
      end
    #   sleep 60*4
    # end
  end


  #获取20个城市的代码及名称
  def self.get_city_code_name
    provinces = {"440000" => "广东", "370000" => "山东", "330000" => "浙江", "320000" => "江苏", "130000" => "河北", "410000" => "河南", "110000" => "北京", "210000" => "辽宁", "310000" => "上海", "500000" => "重庆", "350000" => "福建", "450000" => "广西", "520000" => "贵州", "620000" => "甘肃", "460000" => "海南", "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林", "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川", "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南"}
    city_hash = {}
    provinces.each_pair do |key, v|
      city_content = RestClient.get("http://m.che168.com/Handler/GetArea.ashx?pid=#{key}")
      pp 'xxx'
      city_content = JSON.parse city_content.body

      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if ["广州", "深圳", "宁波", "东莞", "唐山", "厦门", "上海", "西安", "重庆", "杭州", "天津", "苏州", "成都", "福州", "长沙", "北京", "南京", "温州", "哈尔滨", "石家庄", "合肥", "郑州", "武汉", "太原", "沈阳", "无锡", "大连", "济南", "佛山", "青岛"].include? areaname
          city_hash[areaid] = areaname
        end
      end
    end
  end


  def self.che168_get_car_list
    car_price_start = 1
    car_price_end = 1000
    number_per_page = 10
    city_hash = {"441900" => "东莞", "440600" => "佛山", "440100" => "广州",
                 "440300" => "深圳", "370100" => "济南", "370200" => "青岛", "330100" => "杭州", "330200" => "宁波",
                 "330300" => "温州", "320100" => "南京", "320500" => "苏州", "320200" => "无锡", "130100" => "石家庄",
                 "130200" => "唐山", "410100" => "郑州", "110100" => "北京", "210200" => "大连", "210100" => "沈阳",
                 "310100" => "上海", "500100" => "重庆", "350100" => "福州", "350200" => "厦门", "420100" => "武汉",
                 "430100" => "长沙", "230100" => "哈尔滨", "610100" => "西安", "510100" => "成都", "140100" => "太原",
                 "120100" => "天津"}

    threads = []
    city_hash.each_pair do |areaid, areaname|
      threads.delete_if { |thread| thread.status == false }
      if threads.length > 30
        pp "现在共有#{threads.length}个线程正在运行"
        sleep 3
      end
      #线程开始
      t = Thread.new do
        begin
          pp "现在跑.. #{areaname}"

          1.upto 1000000000 do |i|
            # content = `curl 'http://m.che168.com/handler/getcarlist.ashx?num=200&pageindex=#{i}&brandid=0&seriesid=0&specid=0&price=#{car_price_start}_#{car_price_end}&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0' -H 'Host: m.che168.com' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:39.0) Gecko/20100101 Firefox/39.0' -H 'Accept: application/json' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3' -H 'deflate' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://m.che168.com/guangzhou/1_10/1-5-0-6-0-0-00/?pvareaid=100421' -H 'Cookie: sessionid=e4434ae5-a74f-430f-bf16-2301fe709574; sessionip=27.203.171.229; area=371099; Hm_lvt_5a373383174a999f435969fc84eef6ec=1437745123; Hm_lpvt_5a373383174a999f435969fc84eef6ec=1437748038; userarea=0; SessionSeries=0; sheight=; __utma=247243734.1237350500.1437745133.1437745133.1437747639.2; __utmc=247243734; __utmz=247243734.1437745133.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _ga=GA1.2.1237350500.1437745133; BroswerCategory=77d%7C26d%7C71d%7C165d%7C15d%7C12d%7C47d%7C38d%7C36d%7C1d%7C86d%7C; BroswerSeries=552%2C434%2C657%2C153%2C; authenticationarea=0; historysearch=china|0|0|1|10,china|0|0|8|10; uarea=440100%7Cguangzhou; sessionvisit=182dfd58-da85-4c78-9e75-0740e76a52c1; _gat=1' -H 'Connection: keep-alive'`
            content = RestClient.get "http://m.che168.com/handler/getcarlist.ashx?num=#{number_per_page}&pageindex=#{i}&brandid=0&seriesid=0&specid=0&price=#{car_price_start}_#{car_price_end}&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0"
            # content = ActiveSupport::Gzip.decompress(content)
            content = content.body
            break if content.blank?
            # pp content
            a = JSON.parse content
            break if a.length == 0
            car_number = a.length
            exists_car_number = 0
            a.each do |info|
              # result = 0
              result = UserSystem::CarUserInfo.create_car_user_info che_xing: info["carname"],
                                                                    che_ling: info["date"],
                                                                    milage: info['milage'],
                                                                    detail_url: "http://m.che168.com#{info["url"]}",
                                                                    city_chinese: areaname,
                                                                    site_name: 'che168'
              exists_car_number = exists_car_number + 1 if result == 1
            end
            if car_number == exists_car_number
              puts '本页数据全部存在，跳出'
              break
            end
          end
          ActiveRecord::Base.connection.close
        rescue Exception => e
          ActiveRecord::Base.connection.close
        end
      end
      threads << t
    end


    1.upto(2000) do
      sleep(1)
      pp '抓省份。。休息.......'
      threads.each do |t|
        pp t.status
      end
      threads.delete_if { |thread| thread.status == false }
      break if threads.blank?
    end
  end


  # 获取需要发送邮件的车主信息
  def self.need_send_mail_car_user_infos
    car_user_infos = self.where(email_status: 0)
    cities = ['广州', '深圳', '宁波', '东莞', '唐山', '厦门', '上海', '西安', '重庆', '杭州', '天津', '苏州', '成都', '福州', '长沙',
              '北京', '南京', '温州', '哈尔滨', '石家庄', '合肥', '郑州', '武汉', '太原', '沈阳', '无锡', '大连',
              '济南', '佛山', '青岛']
    result_car_users = []
    car_user_infos.each do |car_user_info|
      # 只从这20个城市中发
      unless cities.include? car_user_info.city_chinese
        car_user_info.update_attributes email_status: 2
        next
      end
      # 车龄大于等于10年，这个则不发邮件，将改车主信息置为不发邮件状态
      if Time.now.year - (car_user_info.che_ling.to_i rescue 0) >= 10
        car_user_info.update_attributes email_status: 2
        next
      end

      # 车龄大于等于10年，这个则不发邮件，将改车主信息置为不发邮件状态
      if car_user_info.phone.blank?
        car_user_info.update_attributes email_status: 2
        next
      end

      # car_user_info.update_attributes email_status: 1
      result_car_users << car_user_info
    end
    result_car_users
  end

  # 生成xls
  def self.generate_xls_of_car_user_info car_user_infos
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
    sheet1 = book.create_worksheet name: '车主信息数据'
    # sheet1.row(1) << ['姓名', '电话', '车型', '车龄', '城市', '备注', '里程', '发布时间', '保存时间', '数据来源']
    ['姓名', '电话', '车型', '车龄', '价格', '城市', '备注', '里程', '发布时间', '保存时间', '数据来源', '导入状态'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end

    current_row = 1

    car_user_infos.each do |car_user_info|
      upload_zhuangtai = case car_user_info.upload_status
                           when 'success'
                             '成功'
                           when 'yicunzai'
                             '已存在'
                           when 'shibai'
                             "失败--#{car_user_info.shibaiyuanyin}"
                           else
                             '不导入'
                         end

      [car_user_info.name, car_user_info.phone, car_user_info.che_xing,
       ("#{(Time.now.year-car_user_info.che_ling.to_i) rescue ''}年"),
       car_user_info.price,
       car_user_info.city_chinese, car_user_info.note, "#{car_user_info.milage}万公里",
       car_user_info.fabushijian, (car_user_info.created_at.chinese_format rescue ''),
       car_user_info.site_name, upload_zhuangtai].each_with_index do |content, i|
        sheet1.row(current_row)[i] = content
      end
      current_row += 1
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车主信息数据.xls")
    book.write file_path
    file_path
  end

end
__END__

获取省份列表
    profince_content = `curl 'http://m.che168.com/selectarea.aspx?brandpinyin=&seriespinyin=&specid=&price=1_10&carageid=5&milage=0&carsource=1&store=6&level=0&currentareaid=440100&market=00&key=&backurl=#areaG'`
    profince_content = Nokogiri::HTML(profince_content)
    citys = {}
    profince_content.css(".widget .w-main .w-sift-area a").each do |sheng|
      pp sheng.attributes
      pp sheng

        citys[(sheng.attributes["data-pid"].value rescue '')] = sheng.text.strip



    end
    pp citys


"http://m.che168.com/handler/getcarlist.ashx?num=200&pageindex=1&brandid=0&seriesid=0&specid=0&price=1_10&carageid=5&milage=0&carsource=1&store=6&levelid=0&key=&areaid=#{areaid}&browsetype=0&market=00&browserType=0

  广州，深圳，宁波，东莞，唐山，厦门，上海，西安，重庆，杭州，天津，苏州，成都，福州，长沙，北京，南京，温州，哈尔滨，石家庄，合肥，郑州，武汉，太原，沈阳，无锡，大连，济南，佛山，青岛