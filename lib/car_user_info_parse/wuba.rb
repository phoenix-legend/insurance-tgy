module Wuba


  # url =
  # Wuba.get_phone_by_userinfo "http://qd.58.com/ershouche/29304765491892x.shtml"
  def self.get_phone_by_userinfo url
    # url = "http://qd.58.com/ershouche/29304765491892x.shtml"
    #获取用户id
    sleep 30
    content = RestClient.get url, {
        'User-Agent' => 'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Mobile Safari/537.36',
        "Cookie" => 'f=n; cookieuid=fe381b34-65b8-470c-b39c-1168a8c8c640; id58=05cDFFWQErahRK6kFErWAg==; __ag_cm_=1435571528704; jjqp=1; ag_fid=O5XPZqteqcIjuuvF; bj58_id58s="cFNlMnlwQjNaek11NTIxMw=="; br58=index_old; gr_user_id=2fd1e7a2-acd5-4c9a-8776-0757b6db2bfc; __utma=253535702.876986337.1463542865.1463548490.1471528581.3; 58home=linyixian; sessionid=46dd4432-3aa3-4b85-90c0-8a8f9c452864; ishome=true; als=0; selectcity=yes; car_detail_app_open=8; prompt=personalId; Hm_lvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; Hm_lpvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; commonTopbar_myfeet_tooltip=end; car_list_app_open=7; userip=101.45.219.92; tc_userid=0; job_detail_app_open=3; job_detail_show_time=2; Hm_lvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899518; Hm_lpvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899532; house_finalpage_app_open=4; m58comvp=t08v115.159.229.15; house_list_app_open=5; city=3144; cookieuid1=c5/npli/YPedgnSPBaywAg==; GA_GTID=0d40009c-01b5-a5f7-024a-863e35b8d819; _ga=GA1.2.876986337.1463542865; nearCity=%5B%7B%22cityName%22%3A%22%E5%8C%97%E4%BA%AC%22%2C%22city%22%3A%22bj%22%7D%2C%7B%22cityName%22%3A%22%E4%B8%8A%E6%B5%B7%22%2C%22city%22%3A%22sh%22%7D%2C%7B%22cityName%22%3A%22%E5%AE%89%E9%A1%BA%22%2C%22city%22%3A%22anshun%22%7D%5D; webps=A; curr_platform=pc; firstLogin=true; ipcity=sh%7C%u4E0A%u6D77%7C0; bdshare_firstime=1488944272624; f=n; bangbigtip2=1; commontopbar_city=122%7C%u9752%u5C9B%7Cqd; __track_id=20170308115320762839203278110577014; myfeet_tooltip=end; bj58_new_uv=16; JSESSIONID=B4D90C778C6E5268D157E94A952163C0; Hm_lvt_ef9ab733a6772ffc77e498ec3aee46bd=1488944272,1488948327; Hm_lpvt_ef9ab733a6772ffc77e498ec3aee46bd=1488948327; 58tj_uuid=330b45e3-a726-4c76-99fa-9845b0354944; new_uv=31; final_history=26155300337100%2C29225934567471%2C29304765491892%2C28673705311532'
    }
    content = content.body
    if content.match /瓜子二手车直卖网259项全车检测/
      pp '瓜子'
      return nil
    end
    pp '111'
    # pp content

    matchs = content.match /"userid":(\d{14,18})/
    matchs ||= content.match /'userid':'(\d{14,18})'/
    if content.match /请输入验证码/
      pp '获取用户id被封'
      sleep 30
    end
    return if matchs.nil?
    uid = matchs[1]
    pp '222'
    #根据用户id获取iframe链接,用于获取历史消息
    # url = "http://my.58.com/30715922179334"
    # uid = 43961037693201
    pp "uid is #{uid}"
    sleep 30
    userinfo_content = RestClient.get "http://my.58.com/#{uid}", {
        'User-Agent' => 'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Mobile Safari/537.36',
        # "Cookie" => 'f=n; cookieuid=fe381b34-65b8-470c-b39c-1168a8c8c640; id58=05cDFFWQErahRK6kFErWAg==; __ag_cm_=1435571528704; jjqp=1; ag_fid=O5XPZqteqcIjuuvF; bj58_id58s="cFNlMnlwQjNaek11NTIxMw=="; br58=index_old; gr_user_id=2fd1e7a2-acd5-4c9a-8776-0757b6db2bfc; __utma=253535702.876986337.1463542865.1463548490.1471528581.3; 58home=linyixian; sessionid=46dd4432-3aa3-4b85-90c0-8a8f9c452864; ishome=true; als=0; selectcity=yes; car_detail_app_open=8; prompt=personalId; Hm_lvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; Hm_lpvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; commonTopbar_myfeet_tooltip=end; car_list_app_open=7; userip=101.45.219.92; tc_userid=0; job_detail_app_open=3; job_detail_show_time=2; Hm_lvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899518; Hm_lpvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899532; house_finalpage_app_open=4; m58comvp=t08v115.159.229.15; house_list_app_open=5; city=3144; cookieuid1=c5/npli/YPedgnSPBaywAg==; GA_GTID=0d40009c-01b5-a5f7-024a-863e35b8d819; _ga=GA1.2.876986337.1463542865; nearCity=%5B%7B%22cityName%22%3A%22%E5%8C%97%E4%BA%AC%22%2C%22city%22%3A%22bj%22%7D%2C%7B%22cityName%22%3A%22%E4%B8%8A%E6%B5%B7%22%2C%22city%22%3A%22sh%22%7D%2C%7B%22cityName%22%3A%22%E5%AE%89%E9%A1%BA%22%2C%22city%22%3A%22anshun%22%7D%5D; webps=A; curr_platform=pc; firstLogin=true; ipcity=sh%7C%u4E0A%u6D77%7C0; bdshare_firstime=1488944272624; f=n; bangbigtip2=1; commontopbar_city=122%7C%u9752%u5C9B%7Cqd; __track_id=20170308115320762839203278110577014; myfeet_tooltip=end; bj58_new_uv=16; JSESSIONID=B4D90C778C6E5268D157E94A952163C0; Hm_lvt_ef9ab733a6772ffc77e498ec3aee46bd=1488944272,1488948327; Hm_lpvt_ef9ab733a6772ffc77e498ec3aee46bd=1488948327; 58tj_uuid=330b45e3-a726-4c76-99fa-9845b0354944; new_uv=31; final_history=26155300337100%2C29225934567471%2C29304765491892%2C28673705311532'
    }
    # userinfo_content = RestClient.get url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
    userinfo_content = userinfo_content.body
    if userinfo_content.match /请输入验证码/
      pp '获取用户frame被封'
      sleep 1
    end
    pp '3333333'
    userinfo_content1 = Nokogiri::HTML(userinfo_content)
    frame_url = begin
      "http:#{userinfo_content1.css('iframe')[0].attributes["src"].value}"
    rescue Exception => e
      pp '获取iframe出错'
      pp userinfo_content
      nil
    end
    pp frame_url

    #从frame里获取历史消息
    # frame_url = "http://my.58.com/home/0/0E5817AF9735058925DC71C3293F6A50"
    return if frame_url.blank?
    sleep 1
    sleep 30
    frame_content = RestClient.get frame_url, {
        'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
        "Cookie" => 'f=n; cookieuid=fe381b34-65b8-470c-b39c-1168a8c8c640; id58=05cDFFWQErahRK6kFErWAg==; __ag_cm_=1435571528704; jjqp=1; ag_fid=O5XPZqteqcIjuuvF; bj58_id58s="cFNlMnlwQjNaek11NTIxMw=="; br58=index_old; gr_user_id=2fd1e7a2-acd5-4c9a-8776-0757b6db2bfc; __utma=253535702.876986337.1463542865.1463548490.1471528581.3; 58home=linyixian; sessionid=46dd4432-3aa3-4b85-90c0-8a8f9c452864; ishome=true; als=0; selectcity=yes; car_detail_app_open=8; prompt=personalId; Hm_lvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; Hm_lpvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; commonTopbar_myfeet_tooltip=end; car_list_app_open=7; userip=101.45.219.92; tc_userid=0; job_detail_app_open=3; job_detail_show_time=2; Hm_lvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899518; Hm_lpvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899532; house_finalpage_app_open=4; m58comvp=t08v115.159.229.15; house_list_app_open=5; city=3144; cookieuid1=c5/npli/YPedgnSPBaywAg==; GA_GTID=0d40009c-01b5-a5f7-024a-863e35b8d819; _ga=GA1.2.876986337.1463542865; nearCity=%5B%7B%22cityName%22%3A%22%E5%8C%97%E4%BA%AC%22%2C%22city%22%3A%22bj%22%7D%2C%7B%22cityName%22%3A%22%E4%B8%8A%E6%B5%B7%22%2C%22city%22%3A%22sh%22%7D%2C%7B%22cityName%22%3A%22%E5%AE%89%E9%A1%BA%22%2C%22city%22%3A%22anshun%22%7D%5D; webps=A; curr_platform=pc; firstLogin=true; ipcity=sh%7C%u4E0A%u6D77%7C0; bdshare_firstime=1488944272624; f=n; bangbigtip2=1; commontopbar_city=122%7C%u9752%u5C9B%7Cqd; __track_id=20170308115320762839203278110577014; myfeet_tooltip=end; bj58_new_uv=16; JSESSIONID=B4D90C778C6E5268D157E94A952163C0; Hm_lvt_ef9ab733a6772ffc77e498ec3aee46bd=1488944272,1488948327; Hm_lpvt_ef9ab733a6772ffc77e498ec3aee46bd=1488948327; 58tj_uuid=330b45e3-a726-4c76-99fa-9845b0354944; new_uv=31; final_history=26155300337100%2C29225934567471%2C29304765491892%2C28673705311532'
    }

    frame_content = frame_content.body
    if frame_content.match /请输入验证码/
      pp '获取用户历史消息被封'
      sleep 1
    end
    frame_content = Nokogiri::HTML(frame_content)
    frame_content.css(".sc-post-con ul li").each do |li|
      products_url = li.css('a')[0].attributes['href'].value rescue nil
      leibie_url = li.css('a')[1].attributes['href'].value rescue nil

      #products_url 即为历史消息的链接,在这里做最后一步,到里面拿手机号
      pp "products url is #{products_url}"
      next if products_url.blank?
      next if products_url.match /ershouche/
      sleep 1
      sleep 30
      products_content = RestClient.get products_url, {
          'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'#,
          # "Cookie" => 'f=n; cookieuid=fe381b34-65b8-470c-b39c-1168a8c8c640; id58=05cDFFWQErahRK6kFErWAg==; __ag_cm_=1435571528704; jjqp=1; ag_fid=O5XPZqteqcIjuuvF; bj58_id58s="cFNlMnlwQjNaek11NTIxMw=="; br58=index_old; gr_user_id=2fd1e7a2-acd5-4c9a-8776-0757b6db2bfc; __utma=253535702.876986337.1463542865.1463548490.1471528581.3; 58home=linyixian; sessionid=46dd4432-3aa3-4b85-90c0-8a8f9c452864; ishome=true; als=0; selectcity=yes; car_detail_app_open=8; prompt=personalId; Hm_lvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; Hm_lpvt_4d4cdf6bc3c5cb0d6306c928369fe42f=1488899436; commonTopbar_myfeet_tooltip=end; car_list_app_open=7; userip=101.45.219.92; tc_userid=0; job_detail_app_open=3; job_detail_show_time=2; Hm_lvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899518; Hm_lpvt_5a7a7bfd6e7dfd9438b9023d5a6a4a96=1488899532; house_finalpage_app_open=4; m58comvp=t08v115.159.229.15; house_list_app_open=5; city=3144; cookieuid1=c5/npli/YPedgnSPBaywAg==; GA_GTID=0d40009c-01b5-a5f7-024a-863e35b8d819; _ga=GA1.2.876986337.1463542865; nearCity=%5B%7B%22cityName%22%3A%22%E5%8C%97%E4%BA%AC%22%2C%22city%22%3A%22bj%22%7D%2C%7B%22cityName%22%3A%22%E4%B8%8A%E6%B5%B7%22%2C%22city%22%3A%22sh%22%7D%2C%7B%22cityName%22%3A%22%E5%AE%89%E9%A1%BA%22%2C%22city%22%3A%22anshun%22%7D%5D; webps=A; curr_platform=pc; firstLogin=true; ipcity=sh%7C%u4E0A%u6D77%7C0; bdshare_firstime=1488944272624; f=n; bangbigtip2=1; commontopbar_city=122%7C%u9752%u5C9B%7Cqd; __track_id=20170308115320762839203278110577014; myfeet_tooltip=end; bj58_new_uv=16; JSESSIONID=B4D90C778C6E5268D157E94A952163C0; Hm_lvt_ef9ab733a6772ffc77e498ec3aee46bd=1488944272,1488948327; Hm_lpvt_ef9ab733a6772ffc77e498ec3aee46bd=1488948327; 58tj_uuid=330b45e3-a726-4c76-99fa-9845b0354944; new_uv=31; final_history=26155300337100%2C29225934567471%2C29304765491892%2C28673705311532'
      }
      products_content = products_content.body
      if products_content.match /请输入验证码/
        pp '最后一步被封'
        sleep 1
      end
      # pp "**"*100
      # pp "   "*100
      # pp products_content

      phone_match = products_content.match /tel:(\d{11})/
      pp phone_match
      phoneno_match = products_content.match /phoneNo="(\d{11})"/
      pp phoneno_match
      sms_match = products_content.match /sms:(\d{11})/
      pp sms_match


      phone = phone_match[1] rescue nil
      phoneno = phoneno_match[1] rescue nil
      phone_sms = sms_match[1] rescue nil

      really_phone = phone || phoneno || phone_sms
      return really_phone if not really_phone.blank?
    end

    nil


  end

  def self.testx
    k = 0
    cuis = UserSystem::CarUserInfo.where("site_name = '58'").limit(3500).order(id: :desc)
    cuis.each do |cui|
      next if cui.name.blank?
      next if cui.name.match /商家|瓜子/
      phone = Wuba.get_phone_by_userinfo cui.detail_url
      pp "#{cui.detail_url}   #{phone}"
      k+=1 if not phone.blank?
    end
    pp k
  end

  # Wuba.get_car_user_list
  # 获取58部分城市的车辆列表
  def self.get_car_user_list lest_number = 20, sub_city_party = 0
    city_hash = ::UserSystem::CarUserInfo.get_58_sub_cities sub_city_party
    (1..100).each do |i|
      city_hash.each_pair do |areaid, areaname|
        if Thread.list.length > 1
          pp "现在共有#{Thread.list.length}个线程正在运行"
          while true
            if Thread.list.length < 2
              break
            else
              sleep 0.3
            end
          end
        end
        Thread.start do
          get_car_list_from_one_city areaname, areaid
        end
      end
    end
  end


  def self.get_car_list_from_one_city areaname, areaid
    begin
      pp "#{areaname}   跑58..    #{Time.now.chinese_format}"
      url = "http://#{areaid}.58.com/ershouche/0/pn1/"
      # pp url
      sleep 30
      content = RestClient.get url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
      content = content.body
      # pp content
      content.gsub!('infoList list-info', 'list_infos_eric')
      return if content.blank?
      content = Nokogiri::HTML(content)
      trs = content.css('.list_infos_eric .item')
      trs.each do |tr|
        chexing = ''
        next if tr.to_s.match /google|7天可退|259项全车检测/

        next if (
        begin
          tr.attributes["style"] rescue ''
        end).to_s == 'display:none;'


        begin
          chexing = tr.css('.info-title strong')[0].text
        rescue
          pp tr.to_s
          pp 'Exception  车型获取失败'
          next
        end

        price = 2
        begin
          price = tr.css('.info-desc-tag-price')[0].text.strip
          price.gsub!('万', '')
        rescue
          # car_number = car_number -1
          pp tr.to_s
          pp 'Exception  价格获取失败'
          next
        end

        cheling_licheng = tr.css('.info-desc-detail').text
        cheling = cheling_licheng.split('年')[0]
        milage = cheling_licheng.split('年')[1]
        milage.gsub(/\s|万|公里/, '') unless milage.blank?
        url = tr.css('a')[0].attributes["href"].value
        # url = tr.css('td .t')[0].attributes["href"].value
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
                                                              detail_url: url.split('?')[0],
                                                              city_chinese: areaname,
                                                              site_name: '58'
        if result == 0
          u = url.split('?')[0]
          unless u.blank?
            c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
            Wuba.update_one_detail_kouling c.id if not c.blank?
          end
        end
      end
      ActiveRecord::Base.connection.close
    rescue Exception => e
      pp e
      pp $@
      ActiveRecord::Base.connection.close
    end
  end


  #获取用户列表， 直接获取外部的链接
  def self.get_car_user_list_v2 content, areaid
    begin
      areaname = UserSystem::CarUserInfo::WUBA_CITY[areaid]
      return if content.blank?
      content = Nokogiri::HTML(content)
      trs = content.css('.tbimg tr')

      trs.each do |tr|
        chexing = ''
        next if tr.to_s.match /google|7天可退/
        begin
          chexing = tr.css('td .t')[0].text
        rescue
          pp tr.to_s
          pp 'Exception  车型获取失败'
          next
        end

        price = 2
        begin
          price = tr.css('.tc .pri')[0].text
        rescue
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
            url = Wuba.get_normal_url_by_short_url_and_city url, areaid
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

        result = UserSystem::CarUserInfo.create_car_user_info che_xing: "~#{chexing}",
                                                              price: price,
                                                              che_ling: cheling,
                                                              milage: milage,
                                                              detail_url: url.split('?')[0],
                                                              city_chinese: areaname,
                                                              site_name: '58'

        if result == 0
          u = url.split('?')[0]

          unless u.blank?
            c = UserSystem::CarUserInfo.where("detail_url = ?", u).order(id: :desc).first
            Wuba.update_one_detail c.id if not c.blank?
          end
        end

      end


        # ActiveRecord::Base.connection.close
    rescue Exception => e
      pp e
      pp $@
      # ActiveRecord::Base.connection.close

    end


  end





  # Wuba.tttt 1175137
  def self.tttt car_user_info_id
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id
    sleep 30
    response = RestClient.get car_user_info.detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
    detail_content = response.body
    detail_content.gsub!('person-name', 'personname')
    detail_content.gsub!('abstract-info-txt clear', 'fbsj')
    detail_content.gsub!('detailinfo-box desClose', 'notenote')
    detail_content.gsub!('person-phoneNumber', 'persophone')
    detail_content = Nokogiri::HTML(detail_content)
    name = detail_content.css('.personname').text
    name.gsub!(/\(|\)|个人/, '')

    phone = detail_content.css('persophone').text
    phone_is_shangjia = if (phone.match /\*/).nil? then
                          false
                        else
                          true
                        end

    time = detail_content.css('.fbsj').text
    time.gsub!('发布：', '')
    time.gsub!('放心租车牌', '')
    time.strip!


    note = begin
      detail_content.css('.notenote').text rescue ''
    end
    note.gsub!('联系我时，请说是在58同城上看到的，谢谢！', '')

    pp "姓名是：#{name}"
    pp "备注是：#{note}"
  end


  # 没啥用， 主要是查看api内容
  def xxxxxxx
    car_user_info_id = 1526796
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id


    info = car_user_info.detail_url.match /http:\/\/([a-zA-Z]+)\.58.com\/ershouche\/(\d+)x\.shtml/
    city_name = info[1].to_s
    id_name = info[2].to_s

    api_url = "http://app.58.com/api/detail/ershouche/#{id_name}?appId=2&format=json&localname=#{city_name}&platform=ios&sidDict=%7B%22PGTID%22%3A%22%22%2C%22GTID%22%3A%22130722508192553938177207060%22%7D&version=7.0.0"
    pp api_url
    # api_url = 'http://app.58.com/api/detail/ershouche/25901110150859?appId=3&format=json&localname=sy&platform=ios&sidDict=%7B%22PGTID%22%3A%22%22%2C%22GTID%22%3A%22130722508192553938177207060%22%7D&version=7.1.1'
    sleep 30
    response = RestClient.get api_url
    response = response.body
    response = JSON.parse response

    infos = response["result"]["info"]
    note = infos.select { |info| info.keys[0] == 'desc_area' }[0]["desc_area"]["text"]
    name = infos.select { |info| info.keys[0] == 'linkman_area' }[0]["linkman_area"]["base_info"]["title"]
    name.gsub!('(个人)', '')
    time = infos.select { |info| info.keys[0] == 'title_area' }[0]["title_area"]["ext"][0]
    phone = infos.select { |info| info.keys[0] == 'fenqigou_area' }[0]


  end

  # Wuba.update_one_detail 1175137
  # 使用接口的方式抓数据
  def self.update_one_detail car_user_info_id

    # if true
    #   Wuba.update_one_detail_kouling car_user_info_id
    #   return
    # end

    # car_user_info_id = 1526796
    car_user_info = UserSystem::CarUserInfo.find car_user_info_id

    return unless car_user_info.name.blank?
    return unless car_user_info.phone.blank?
    return if car_user_info.detail_url.match /zhineng/


    begin
      puts '更新明细'
      pp car_user_info.detail_url

      info = car_user_info.detail_url.match /http:\/\/([a-zA-Z]+)\.58.com\/ershouche\/(\d+)x\.shtml/
      city_name = info[1].to_s
      id_name = info[2].to_s
      api_url = "http://app.58.com/api/detail/ershouche/#{id_name}?appId=3&format=json&localname=#{city_name}&platform=ios&sidDict=%7B%22PGTID%22%3A%22%22%2C%22GTID%22%3A%22130722508192553938177207060%22%7D&version=7.1.1"
      pp api_url
      # api_url = 'http://app.58.com/api/detail/ershouche/25901110150859?appId=3&format=json&localname=sy&platform=ios&sidDict=%7B%22PGTID%22%3A%22%22%2C%22GTID%22%3A%22130722508192553938177207060%22%7D&version=7.1.1'
      sleep 30
      response = RestClient.get api_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
      response = response.body
      response = JSON.parse response

      return if response['status'] != 0

      infos = response["result"]["info"]
      note = infos.select { |info| info.keys[0] == 'desc_area' }[0]["desc_area"]["text"]
      name = infos.select { |info| info.keys[0] == 'linkman_area' }[0]["linkman_area"]["base_info"]["title"]
      name.gsub!('(个人)', '')
      name.gsub!('为保护用户隐私该电话3分钟后失效，请快速拨打哦~', '')
      time = infos.select { |info| info.keys[0] == 'title_area' }[0]["title_area"]["ext"][0]

      phone = infos.select { |info| info.keys[0] == 'fenqigou_area' }[0]
      if phone.blank?
        Wuba.update_one_detail_kouling car_user_info_id
        return
      end

      phone = infos.select { |info| info.keys[0] == 'fenqigou_area' }[0]["fenqigou_area"]["detail_link"]["action"]["content"]["url"].match /phone=(\d{11})/
      if phone.blank?
        Wuba.update_one_detail_kouling car_user_info_id
        return
      end

      if phone[1].blank?
        Wuba.update_one_detail_kouling car_user_info_id
        return
      end

      phone = phone[1].to_s

      if phone.blank?
        Wuba.update_one_detail_kouling car_user_info_id
        return
      end


      #姓名，手机号，备注，发布时间

      name = '先生女士' if name.blank?
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
                                            note: "__#{note}",
                                            fabushijian: time


    rescue Exception => e
      pp e
      pp $@
      car_user_info.need_update = false
      car_user_info.save
    end
  end

  # Wuba.update_one_detail 5039025
  # 使用口令的方式抓数据
  def self.update_one_detail_kouling car_user_info_id
    # car_user_info_id = 1055829
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
      puts '更新明细'
      pp car_user_info.detail_url
      sleep 30
      response = RestClient.get car_user_info.detail_url, {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}

      detail_content = response.body
      # detail_content.gsub!('intro-per intro-center','personname')
      # detail_content.gsub!('intro-per','personname')
      detail_content.gsub!('person-nameCont', 'personname')
      detail_content.gsub!('abstract-info-txt clear', 'fbsj')
      detail_content.gsub!('detailinfo-box desClose', 'notenote')
      detail_content.gsub!('person-phoneNumber', 'persophone')


      detail_content = Nokogiri::HTML(detail_content)

      name = detail_content.css('.personname').text
      name.gsub!(/\(|\)|个人/, '')

      phone = detail_content.css('persophone').text
      phone_is_shangjia = if (phone.match /\*/).nil? then
                            false
                          else
                            true
                          end

      time = detail_content.css('.fbsj').text
      time.gsub!('发布：', '')
      time.gsub!('放心租车牌', '')
      time.gsub!(/\s/, '')
      time.gsub!('车牌保障服务', '')
      time.gsub!("\\r", '')
      time.gsub!("\\n", '')
      time.strip!


      note = begin
        detail_content.css('.notenote p').text rescue ''
      end
      note.gsub!('联系我时，请说是在58同城上看到的，谢谢！', '')


      phone_is_shangjia = true if name.match /瓜子/


      # time = detail_content.css('.mtit_con_left .time').text
      # name = detail_content.css('.lineheight_2').children[3].text
      # note = begin
      #   detail_content.css('.part_detail').children[2].text.gsub(/\t|\r|\n/, '') rescue '暂无'
      # end
      name = '先生女士' if name.blank?
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
      sleep 30
      id_response = RestClient.get "http://app.58.com/api/windex/scandetail/car/#{id}/", {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
      id_response = id_response.body
      id_response = Nokogiri::HTML(id_response)
      # phone = id_response.css('.nums').text
      # phone = phone.gsub('-', '')


      kouling = id_response.css('.info-short_url').text
      kouling = kouling.match(/https(.)*$/)[0]
      # 2017-03-08  临时获取电话号码,通过当前用户发布的其它信息
      phone = Wuba.get_phone_by_userinfo car_user_info.detail_url
      UserSystem::CarUserInfo.update_detail id: car_user_info.id,
                                            name: name,
                                            phone: phone,
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
      return nil if entry_id.blank?
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