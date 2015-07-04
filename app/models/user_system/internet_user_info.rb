class UserSystem::InternetUserInfo < ActiveRecord::Base


  def self.create_info options
    iui = ::UserSystem::InternetUserInfo.where name: options[:name], phone: options[:phone]
    return unless iui.blank?
    info = ::UserSystem::InternetUserInfo.new options
    info.save!
  end


  def self.need_run2
    [['tj','/agenthome-a041/-i31-j310/','天津'],
     ['cd','/agenthome-a0132/-i31-j310/','成都'],
     ['cq','/agenthome-a058/-i31-j310/','重庆'],
     ['wuhan','/agenthome-a0494/-i31-j310/','武汉'],
     ['suzhou','/agenthome-a0277/-i31-j310/','苏州'],
     ['hz','/agenthome-a0151/-i31-j310/','杭州'],
     ['nanjing','/agenthome-a0265/-i31-j310/','南京'],
     ['jn','/agenthome-a0386/-i31-j310/','济南'],
     ['zz','/agenthome-a0362/-i31-j310/','郑州'],
    ].each do |city_info|
      city = city_info[0]
      agent = city_info[1]
      init_host = "http://esf.#{city}.fang.com"
      init_url = "#{init_host}#{agent}"
      UserSystem::InternetUserInfo.fenpianqu_common init_host, init_url, city
    end
  end




  # 深圳二手房经纪人
  def self.sz_jingjiren_ershoufang_fangcom
    init_host = 'http://esf.sz.fang.com'
    init_url = "#{init_host}/agenthome-a089/-i31-j310/"
    city = 'sz'
    UserSystem::InternetUserInfo.fenpianqu_common init_host, init_url, city
  end


  # 广州二手房经纪人
  def self.gz_jingjiren_ershoufang_fangcom
    init_host = 'http://esf.gz.fang.com'
    init_url = "#{init_host}/agenthome-a073/-i31-j310/"
    city = 'gz'
    UserSystem::InternetUserInfo.fenpianqu_common init_host, init_url, city
  end

  # 上海二手房经纪人
  def self.sh_jingjiren_ershoufang_fangcom
    init_host = 'http://esf.sh.fang.com'
    init_url = "#{init_host}/agenthome-a025-b01646/-i31-j310/"
    city = 'sh'
    UserSystem::InternetUserInfo.fenpianqu_common init_host, init_url, city
  end

  # 北京二手房经纪人
  def self.bj_jingjiren_ershoufang_fangcom
    init_host = 'http://esf.fang.com'
    init_url = "#{init_host}/agenthome-a01/-i31-j310/"
    city = 'bj'
    UserSystem::InternetUserInfo.fenpianqu_common init_host, init_url, city
  end



  # 剩下广州和北京
  def self.fenpianqu_common init_host, init_url, city

    content = `curl '#{init_url}' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Cookie: global_wapandm_cookie=nswiidhghms8p127uf3mqb3r730ibj0104n; global_cookie=0bab37cc-1435648460044-66998e9a; __utmt_t0=1; __utmt_t1=1; __utmt_t2=1; __utma=147393320.1313865077.1435648464.1435761767.1435920774.7; __utmb=147393320.6.10.1435920774; __utmc=147393320; __utmz=147393320.1435648464.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); unique_cookie=U_tur6pl0ia82wx5ce0g35abr7j3vibni5jf0*2' -H 'Connection: keep-alive' --compressed`
    ec = Encoding::Converter.new("gb18030","UTF-8")
    content = ec.convert content
    doc = Nokogiri::HTML(content)
    doc.css("#list_38 .qxName a").each_with_index do |qu, i|
      next if i == 0
      qu_url = "#{init_host}#{qu.attributes["href"].value}"
      qu_content = `curl '#{qu_url}' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Cookie: global_wapandm_cookie=nswiidhghms8p127uf3mqb3r730ibj0104n; global_cookie=0bab37cc-1435648460044-66998e9a; __utmt_t0=1; __utmt_t1=1; __utmt_t2=1; __utma=147393320.1313865077.1435648464.1435761767.1435920774.7; __utmb=147393320.6.10.1435920774; __utmc=147393320; __utmz=147393320.1435648464.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); unique_cookie=U_tur6pl0ia82wx5ce0g35abr7j3vibni5jf0*2' -H 'Connection: keep-alive' --compressed`
      qu_content = ec.convert qu_content
      qu_doc = Nokogiri::HTML(qu_content)
      qu_doc.css("#shangQuancontain a").each_with_index { |shangquan, i|
        next if i == 0
        shangquan_url = "#{init_host}/#{shangquan.attributes["href"].value}"
        begin_url =   shangquan_url.gsub('-i31-j310/','')

        # pudong = /agenthome-a025/
        # unless (pudong.match begin_url).blank?
        #   puts '浦东已过'
        #   next
        # end


        UserSystem::InternetUserInfo.jingjiren_ershoufang_fangcom 1, 700, city, begin_url

      }
    end
  end

  def self.jingjiren_ershoufang_fangcom begin_page, end_page, city, begin_url
    category = '二手房'
    a = 0
    b = 0
    old_content = ''
    (begin_page..end_page).each do |i|
      url = "#{begin_url}-i3#{i}-j310/"
      pp "正在抓取#{url}"
      a = a+1
      content = `curl '#{url}' -connect-timeout 10  -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://esf.fang.com/agenthome/-i31-j310/' -H 'Cookie: global_wapandm_cookie=nswiidhghms8p127uf3mqb3r730ibj0104n; global_cookie=0bab37cc-1435648460044-66998e9a; unique_wapandm_cookie=U_nswiidhghms8p127uf3mqb3r730ibj0104n*19; unique_cookie=U_0bab37cc-1435648460044-66998e9a*9; __utma=147393320.1313865077.1435648464.1435673927.1435761767.6; __utmb=147393320.34.10.1435761767; __utmc=147393320; __utmz=147393320.1435648464.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed`
      ec = Encoding::Converter.new("gb18030","UTF-8")
      content = ec.convert content
      doc = Nokogiri::HTML(content)
      dts = doc.css(".agent_pic .house  dt")

      if dts.length > 0
        b = b+1
        pp "当前是第 #{i} 页， 获取到名单继续"
      else
        pp "当前是第 #{i} 页， 没获取任何名单，可能可结束了,再跑 #{10-(a-b)}页"
      end
      if b-a > 10
        pp "当前是第 #{i} 页"
        pp '后面没有页码了，到此结束。'
        break;
      end
      if old_content.to_s == dts.to_s
        pp "当前是第 #{i} 页"
        pp '开始重复前一页面，结束'
        break;
      end
      old_content = dts.to_s
      doc.css(".agent_pic .house  dt").each do |dt|
        name =  dt.css(".housetitle a").text.strip
        dian = dt.css(".black")[0].css("span").text.strip
        phone =  dt.css("p strong").text.strip
        ::UserSystem::InternetUserInfo.create_info name: "#{name}-#{dian}",
                                                   phone: phone,
                                                   city: city,
                                                   category: category,
                                                   list_url: url,
                                                   detail_url: '经纪人页面',
                                                   number_of_this_page: i,
                                                   wangzhan_name: 'fang.com'
      end
    end
  end


  # UserSystem::InternetUserInfo.bj_ershoufang_fangcom
  def self.bj_ershoufang_fangcom
    url = 'http://m.fang.com/esf/?purpose=%D7%A1%D5%AC&city=%B1%B1%BE%A9&keywordtype=qz&gettype=android&correct=true&pagesizeslipt=5&c=esf&a=ajaxGetList&city=bj&r=0.19393627950921655&page='
    UserSystem::InternetUserInfo.common_fangcom  83, 1000000, url, 'bj', '二手房'
  end

  def self.common_fangcom first_page, last_page, url, city, category
    (first_page..last_page).each do |page_number|

      list_url = "#{url}#{page_number}"
      list = `curl '#{list_url}' -connect-timeout 10 -H 'Cookie: global_wapandm_cookie=nswiidhghms8p127uf3mqb3r730ibj0104n; global_cookie=0bab37cc-1435648460044-66998e9a; JSESSIONID=aaaX67rMAS2Qqdrukvd5u; cityHistory=%u5317%u4EAC%2Cbj; unique_cookie=U_0bab37cc-1435648460044-66998e9a*1; __utmt_t0=1; __utmt_t1=1; mencity=bj; firstlocation=0; __utmmobile=0xd62c3f59d73760d8; __utma=147393320.1313865077.1435648464.1435667166.1435669750.4; __utmb=147393320.10.10.1435669750; __utmc=147393320; __utmz=147393320.1435648464.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); mencity=bj; unique_wapandm_cookie=U_nswiidhghms8p127uf3mqb3r730ibj0104n*16' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' -H 'Accept: */*' -H 'Referer: http://m.fang.com/esf/bj/' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed `

      doc = Nokogiri::HTML(list)
      link_nodes = doc.css('li a')
      link_nodes.each do |link_node|
        link = link_node["href"]
        if link.blank?
          puts '链接为空，跳过'
          next
        end

        detail_link = (link.split('?')[0] rescue link)
        exists_detail = ::UserSystem::InternetUserInfo.where detail_url: detail_link
        unless exists_detail.blank?
          pp "#{pp link} 已经查询过，跳过"
          next
        end

        content = `curl -A "Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30" -L #{link}`
        ec = Encoding::Converter.new("gbk","UTF-8")
        doc = Nokogiri::HTML(content)
        doc.css('.xqZygw p')
        name = doc.css('.xqZygw p span')[0].text rescue ''
        phone = doc.css('.xqZygw p span')[2].text rescue ''
        name =  ec.convert(name)


        ::UserSystem::InternetUserInfo.create_info name: name,
                                                   phone: phone,
                                                   city: city,
                                                   category: category,
                                                   list_url: list_url,
                                                   detail_url: (link.split('?')[0] rescue link),
                                                   number_of_this_page: page_number,
                                                   wangzhan_name: 'fang.com'
      end
    end
  end


  # UserSystem::InternetUserInfo 1, 197, http://m.58.com/sh/zufang/, '二手房', 'bj'
  def self.common_58 first_page, last_page, url, category, city
    (first_page..last_page).each do |page_number|
      list_url = "#{url}pn#{page_number}/"
      list = `curl -A "Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30" -L #{list_url} `
      doc = Nokogiri::HTML(list)
      link_nodes = doc.css('body div .list-info li a')
      link_nodes.each do |link_node|
        link = link_node.attributes["href"].value
        pp link
        if link.blank?
          puts '链接为空'
          next
        end
        detail_link = (link.split('?')[0] rescue link)
        exists_detail = ::UserSystem::InternetUserInfo.where detail_url: detail_link
        unless exists_detail.blank?
          pp "#{pp link} 已经查询过，跳过"
          next
        end


        detail_page = `curl -A "Mozilla/5.0 (Linux; U; Android 4.1; en-us; GT-N7100 Build/JRO03C) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30" -L #{link} `

        doc = Nokogiri::HTML(detail_page)
        name = doc.css(".landlord .llname").children.first.text rescue ''
        require 'pp'
        pp name

        phone = doc.css(".landlord .llnumber").children.first.text rescue ''
        pp phone



        ::UserSystem::InternetUserInfo.create_info name: name,
                                                   phone: phone,
                                                   city: city,
                                                   category: category,
                                                   list_url: list_url,
                                                   detail_url: (link.split('?')[0] rescue link),
                                                   number_of_this_page: page_number,
                                                   title: title

      end
    end
  end

  #上海租房
  # ::UserSystem::InternetUserInfo.get_sh_zufang_info
  def self.get_sh_zufang_info
    UserSystem::InternetUserInfo.common_58 1, 295, 'http://m.58.com/sh/zufang/', '租房', 'sh'
  end

  #上海二手车
  # ::UserSystem::InternetUserInfo.get_sh_ershouche_info
  def self.get_sh_ershouche_info
    UserSystem::InternetUserInfo.common_58 1, 140, 'http://m.58.com/sh/ershouche/', '二手车', 'sh'
  end

  #上海二手房
  # ::UserSystem::InternetUserInfo.get_sh_ershoufang_info
  def self.get_sh_ershoufang_info
    UserSystem::InternetUserInfo.common_58 1, 270, 'http://m.58.com/sh/ershoufang/', '二手房', 'sh'
  end


  #北京二手房
  # ::UserSystem::InternetUserInfo.get_bj_ershoufang_info
  #UserSystem::InternetUserInfo.common_58 63, 270, 'http://m.58.com/bj/ershoufang/', '二手房', 'bj'
  def self.get_bj_ershoufang_info
    UserSystem::InternetUserInfo.common_58 1, 270, 'http://m.58.com/bj/ershoufang/', '二手房', 'bj'
  end


  #北京租房
  # ::UserSystem::InternetUserInfo.get_bj_zufang_info
  # UserSystem::InternetUserInfo.common_58 1, 300, 'http://m.58.com/bj/zufang/', '租房', 'bj'
  def self.get_bj_zufang_info
    UserSystem::InternetUserInfo.common_58 1, 300, 'http://m.58.com/bj/zufang/', '租房', 'bj'
  end


  #广州二手房
  # ::UserSystem::InternetUserInfo.get_gz_ershoufang_info
  def self.get_gz_ershoufang_info
    UserSystem::InternetUserInfo.common_58 1, 270, 'http://m.58.com/gz/ershoufang/', '二手房', 'gz'
  end


  #广州租房
  # ::UserSystem::InternetUserInfo.get_gz_zufang_info
  def self.get_gz_zufang_info
    UserSystem::InternetUserInfo.common_58 1, 300, 'http://m.58.com/gz/zufang/', '租房', 'gz'
  end


  #深圳二手房
  # ::UserSystem::InternetUserInfo.get_sz_ershoufang_info

  def self.get_sz_ershoufang_info
    UserSystem::InternetUserInfo.common_58 1, 270, 'http://m.58.com/sz/ershoufang/', '二手房', 'sz'
  end


  #深圳租房
  # ::UserSystem::InternetUserInfo.get_sz_zufang_info
  def self.get_sz_zufang_info
    UserSystem::InternetUserInfo.common_58 1, 300, 'http://m.58.com/sz/zufang/', '租房', 'sz'
  end



end
__END__