module RestClientProxy
  require 'timeout'

  HOSTNAME_WUBA1 = '10-19-121-166'
  HOSTNAME_WUBA2 = '10-19-71-71'
  HOSTNAME_WUBA3 = '10-19-27-43'
  HOSTNAME_WUBA4 = '10-19-123-251'

  HOSTNAME_GANJI1 = '10-19-104-142'
  HOSTNAME_GANJI2 = '10-19-107-180'
  HOSTNAME_GANJI3 = '10-19-21-5'

  HOSTNAME_QITA1 = '10-19-199-63'
  HOSTNAME_QITA2 = '10-19-61-26'
  HOSTNAME_QITA3 = '10-19-119-191'

  # PROXYIP_WUBA1 = 'http://zrx21:24115@222.184.35.196:32831'
  # PROXYIP_WUBA2 = 'http://zrx12:653312@222.184.35.196:33161'
  # PROXYIP_WUBA3 = 'http://zrx04:65581@222.184.35.196:33081'
  # PROXYIP_WUBA4 = 'http://zrx05:65581@222.184.35.196:33085'
  #
  # PROXYIP_GANJI1 = 'http://zrx07:65581@222.184.35.196:33141'
  # PROXYIP_GANJI2 = 'http://zrx08:65581@222.184.35.196:33121'
  # PROXYIP_GANJI3 = 'http://zrx09:65581@222.184.35.196:33145'
  #
  # PROXYIP_QITA1 = 'http://zrx10:65581@222.184.35.196:33153'
  # PROXYIP_QITA2 = 'http://zrx11:65581@222.184.35.196:33157'
  # PROXYIP_QITA3 = 'http://zrx06:65581@222.184.35.196:33089'




  PROXYIP_WUBA1 = "http://duoipmrkrhdfb:liu10@ip2.hahado.cn:39295"
  PROXYIP_WUBA2 = "http://yddxfnyclt:liu9@ip2.hahado.cn:39287"
  PROXYIP_WUBA3 = "http://18ipxwbdukhx:liu5@ip2.hahado.cn:39275"
  PROXYIP_WUBA4 = "http://ydceddynqa:liu8@ip2.hahado.cn:39263"

  PROXYIP_GANJI1 = "http://ydobbgdsur:liu7@ip2.hahado.cn:39259"
  PROXYIP_GANJI2 = "http://ydtlispqui:liu6@ip2.hahado.cn:39255"
  PROXYIP_GANJI3 = "http://duoipznjnfcge:liu4@ip2.hahado.cn:39247"

  PROXYIP_QITA1 = "http://ydgenawixj:liu3@ip2.hahado.cn:39243"
  PROXYIP_QITA2 = "http://ydpacbhxeu:liu1@ip2.hahado.cn:39239"
  PROXYIP_QITA3 = "http://ydssnjuyzh:liu1@ip2.hahado.cn:39235"

  # 90个UA
  USER_AGENTS = ["Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1", "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0", "Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0", "Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/29.0", "Mozilla/5.0 (X11; OpenBSD amd64; rv:28.0) Gecko/20100101 Firefox/28.0", "Mozilla/5.0 (X11; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0", "Mozilla/5.0 (Windows NT 6.1; rv:27.3) Gecko/20130101 Firefox/27.3", "Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:27.0) Gecko/20121011 Firefox/27.0", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1 QIHU 360SE", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17 QIHU 360EE", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36 QIHU 360SE", "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; 360SE)", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/1.0.154.53 Safari/525.19", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/1.0.154.36 Safari/525.19", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/7.0.540.0 Safari/534.10", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.4 (KHTML, like Gecko) Chrome/6.0.481.0 Safari/534.4", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.86 Safari/533.4", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.2 (KHTML, like Gecko) Chrome/4.0.223.3 Safari/532.2", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/4.0.201.1 Safari/532.0", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Chrome/3.0.195.27 Safari/532.0", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/530.5 (KHTML, like Gecko) Chrome/2.0.173.1 Safari/530.5", "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.558.0 Safari/534.10", "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/540.0 (KHTML,like Gecko) Chrome/9.1.0.0 Safari/540.0", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.14 (KHTML, like Gecko) Chrome/9.0.600.0 Safari/534.14", "Mozilla/5.0 (X11; U; Windows NT 6; en-US) AppleWebKit/534.12 (KHTML, like Gecko) Chrome/9.0.587.0 Safari/534.12", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.0 Safari/534.13", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.11 Safari/534.16", "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.20 (KHTML, like Gecko) Chrome/11.0.672.2 Safari/534.20", "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.792.0 Safari/535.1", "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.872.0 Safari/535.2", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.36 Safari/535.7", "Mozilla/5.0 (Windows NT 6.0; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.66 Safari/535.11", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.45 Safari/535.19", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/535.24 (KHTML, like Gecko) Chrome/19.0.1055.1 Safari/535.24", "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.6 (KHTML, like Gecko) Chrome/20.0.1090.0 Safari/536.6", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/22.0.1207.1 Safari/537.1", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.15 (KHTML, like Gecko) Chrome/24.0.1295.0 Safari/537.15", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36", "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1467.0 Safari/537.36", "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1623.0 Safari/537.36", "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.103 Safari/537.36", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.38 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", "Opera/5.11 (Windows 98; U) [en]", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98) Opera 5.12 [en]", "Opera/6.0 (Windows 2000; U) [fr]", "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT 4.0) Opera 6.01 [en]", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) Opera 7.10 [en]", "Opera/9.02 (Windows XP; U; ru)", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en) Opera 9.24", "Opera/9.51 (Macintosh; Intel Mac OS X; U; en)", "Opera/9.70 (Linux i686 ; U; en) Presto/2.2.1", "Opera/9.80 (Windows NT 5.1; U; cs) Presto/2.2.15 Version/10.00", "Opera/9.80 (Windows NT 6.1; U; sv) Presto/2.7.62 Version/11.01", "Opera/9.80 (Windows NT 6.1; U; en-GB) Presto/2.7.62 Version/11.00", "Opera/9.80 (Windows NT 6.1; U; zh-tw) Presto/2.7.62 Version/11.01", "Opera/9.80 (Windows NT 6.0; U; en) Presto/2.8.99 Version/11.10", "Opera/9.80 (X11; Linux i686; U; ru) Presto/2.8.131 Version/11.11", "Opera/9.80 (Windows NT 5.1) Presto/2.12.388 Version/12.14", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.12 Safari/537.36 OPR/14.0.1116.4", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.29 Safari/537.36 OPR/15.0.1147.24 (Edition Next)", "Opera/9.80 (Linux armv6l ; U; CE-HTML/1.0 NETTV/3.0.1;; en) Presto/2.6.33 Version/10.60", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36 OPR/20.0.1387.91", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Oupeng/10.2.1.86910 Safari/534.30", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36 OPR/26.0.1656.60", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36 OPR/31.0.1857.0", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36 OPR/32.0.1948.25", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; fi-fi) AppleWebKit/420+ (KHTML, like Gecko) Safari/419.3", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; de-de) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.7", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/312.8 (KHTML, like Gecko) Safari/312.6", "Mozilla/5.0 (Windows; U; Windows NT 5.1; cs-CZ) AppleWebKit/523.15 (KHTML, like Gecko) Version/3.0 Safari/523.15", "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16", "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_5_6; it-it) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16", "Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-HK) AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5", "Mozilla/5.0 (Windows; U; Windows NT 6.1; sv-SE) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4", "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/6.1.3 Safari/537.75.14", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.3.10 (KHTML, like Gecko) Version/8.0.3 Safari/600.3.10", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.39 (KHTML, like Gecko) Version/9.0 Safari/601.1.39", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13) AppleWebKit/603.1.13 (KHTML, like Gecko) Version/10.1 Safari/603.1.13"]


  # RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip
    [PROXYIP_GANJI1, PROXYIP_GANJI2, PROXYIP_GANJI3, PROXYIP_WUBA1, PROXYIP_WUBA2, PROXYIP_WUBA3, PROXYIP_WUBA4, PROXYIP_QITA1, PROXYIP_QITA2, PROXYIP_QITA3].each do |k|
      nameandpassword = (k.match /http:\/\/(.{11,12})@/)[1]
      sleep 3
      `curl -u #{nameandpassword} http://ip.hahado.cn/switch-ip`
    end

  end


  def self.get_proxy_ip

    ips = [PROXYIP_GANJI1, PROXYIP_GANJI2, PROXYIP_GANJI3, PROXYIP_QITA1, PROXYIP_QITA2, PROXYIP_QITA3, PROXYIP_WUBA1, PROXYIP_WUBA2, PROXYIP_WUBA3, PROXYIP_WUBA4]
    ips[rand(10)]

    # case RestClientProxy.get_local_ip
    #   when HOSTNAME_GANJI1
    #     PROXYIP_GANJI1
    #   when HOSTNAME_GANJI2
    #     PROXYIP_GANJI2
    #   when HOSTNAME_GANJI3
    #     PROXYIP_GANJI3
    #   when HOSTNAME_QITA1
    #     PROXYIP_QITA1
    #   when HOSTNAME_QITA2
    #     PROXYIP_QITA2
    #   when HOSTNAME_QITA3
    #     PROXYIP_QITA3
    #   when HOSTNAME_WUBA1
    #     PROXYIP_WUBA1
    #   when HOSTNAME_WUBA2
    #     PROXYIP_WUBA2
    #   when HOSTNAME_WUBA3
    #     PROXYIP_WUBA3
    #   when HOSTNAME_WUBA4
    #     PROXYIP_WUBA4
    #   else
    #     PROXYIP_WUBA4
    # end

  end


  def self.get url, header={}
    #只针对58-1使用代理

    proxy_ip = if RestClientProxy.get_local_ip == HOSTNAME_WUBA1
                 RestClientProxy.get_proxy_ip
               else
                 nil
               end


    if url.match /baixing|ganji/  and !proxy_ip.blank?
      sleep 2+rand(3)
    end

    RestClient.proxy = proxy_ip
    pp RestClient.proxy
    response = begin
      RestClient.get url, header
    rescue Exception => e
      e.to_s
      pp '..'*10
      pp e.to_s
    end


    response = response.body unless response.class == String
    response = response.force_encoding('UTF-8')
    RestClient.proxy = nil
    if response.length < 300
      pp 'IP被封'
      pp response
      sleep 3
    end
    return response
  end


  def self.post url, param= {}, header={}
    #只针对58-1使用代理

    proxy_ip = if RestClientProxy.get_local_ip == HOSTNAME_WUBA1
                 RestClientProxy.get_proxy_ip
               else
                 nil
               end

    if url.match /baixing|ganji/   and !proxy_ip.blank?
      sleep 2+rand(3)
    end
    # proxy_ip = RestClientProxy.get_proxy_ip
    RestClient.proxy = proxy_ip
    pp RestClient.proxy
    response = begin
      RestClient.post url, param, header
    rescue Exception => e
      e.to_s
      pp '..'*10
      pp e.to_s
    end


    response = response.body unless response.class == String
    response = response.force_encoding('UTF-8')
    RestClient.proxy = nil
    if response.length < 300
      pp 'IP被封'
      pp response
      sleep 3
    end
    return response
  end

  def self.get_local_ip
    require 'socket'
    Socket.gethostname
  end

  def self.restart_vps_pppoe

    pp '换ip'
    pp Time.now.chinese_format
    `pppoe-stop`
    `pppoe-start`


  end


  def self.rand_ua
    n = rand(86)
    RestClientProxy::USER_AGENTS[n]
  end

end