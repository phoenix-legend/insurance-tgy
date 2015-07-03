class UserSystem::InternetUserInfo < ActiveRecord::Base


  def self.create_info options
    iui = ::UserSystem::InternetUserInfo.where name: options[:name], phone: options[:phone]
    return unless iui.blank?
    info = ::UserSystem::InternetUserInfo.new options
    info.save!
  end




  def self.sz_shanghai_ershoufang_fangcom
    UserSystem::InternetUserInfo.jingjiren_ershoufang_fangcom 1, 100, 'sz', 'http://esf.sz.fang.com/agenthome/'
  end



  def self.gz_shanghai_ershoufang_fangcom
    UserSystem::InternetUserInfo.jingjiren_ershoufang_fangcom 1, 100, 'gz', 'http://esf.gz.fang.com/agenthome/'
  end


  def self.sh_shanghai_ershoufang_fangcom
    UserSystem::InternetUserInfo.jingjiren_ershoufang_fangcom 1, 200, 'sh', 'http://esf.sh.fang.com/agenthome/'
  end


  def self.bj_jingjiren_ershoufang_fangcom
    UserSystem::InternetUserInfo.jingjiren_ershoufang_fangcom 1, 200, 'bj', 'http://esf.fang.com/agenthome/'
  end

  def self.jingjiren_ershoufang_fangcom begin_page, end_page, city, begin_url
    category = '二手房'
    (begin_page..end_page).each do |i|
      url = "#{begin_url}-i3#{i}-j310/"
      pp "正在抓取#{url}"
      content = `curl '#{url}' -connect-timeout 10  -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://esf.fang.com/agenthome/-i31-j310/' -H 'Cookie: global_wapandm_cookie=nswiidhghms8p127uf3mqb3r730ibj0104n; global_cookie=0bab37cc-1435648460044-66998e9a; unique_wapandm_cookie=U_nswiidhghms8p127uf3mqb3r730ibj0104n*19; unique_cookie=U_0bab37cc-1435648460044-66998e9a*9; __utma=147393320.1313865077.1435648464.1435673927.1435761767.6; __utmb=147393320.34.10.1435761767; __utmc=147393320; __utmz=147393320.1435648464.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed`
      ec = Encoding::Converter.new("gb18030","UTF-8")
      content = ec.convert content
      doc = Nokogiri::HTML(content)
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