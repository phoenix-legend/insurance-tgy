module RestClientProxy
  require 'timeout'
  # RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip_x
    redis = Redis.current

    while true
      begin
        # 获取代理信息
        RestClient.proxy = nil
        url = "http://api.ip.data5u.com/dynamic/get.html?order=64a868c8fc23532cdd38ccb125b72873"
        response = RestClient.get url
        proxy_url = "http://#{response.body.gsub("\n", '')}"
        pp proxy_url
        sleep 0.5
        if redis[:proxy_ip] == proxy_url
          next
        end
        #验证代理信息
        RestClient.proxy = proxy_url
        response = nil
        Timeout::timeout(5) {
          response = RestClient.get 'http://www.baixing.com', {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
        }
        content = response.body
        content = content.force_encoding('UTF-8')
        if content.match /百姓|二手/
          redis[:proxy_ip] = proxy_url
          puts "#{Time.now.chinese_format} #{proxy_url}"
          sleep 30
          redis.expire :proxy_ip, 300 #最多放5分钟
        end
      rescue Exception => e
        # pp e
      end
      # sleep 2
    end
  end

  #RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip
    redis = Redis.current

    num = 0
    while true
      num += 1
      break if num == 3

      # 获取代理信息
      RestClient.proxy = nil
      # url = "http://api.ip.data5u.com/dynamic/get.html?order=64a868c8fc23532cdd38ccb125b72873"
      # url = "http://tpv.daxiangdaili.com/ip/?tid=558075121539166&num=1&delay=3&category=2&foreign=none"
      # url = "http://dev.kuaidaili.com/api/getproxy/?orderid=968048212439589&num=30&area=%E5%A4%A7%E9%99%86&b_pcchrome=1&b_pcie=1&b_pcff=1&protocol=1&method=1&an_tr=1&an_an=1&an_ha=1&sp1=1&sp2=1&quality=1&sort=1&sep=2"
      url = "http://dps.kuaidaili.com/api/getdps/?orderid=938048575858941&num=20&ut=1&sep=2"

      response = RestClient.get url
      ips = response.body.split("\n")
      ips.each do |ip|
        begin
          proxy_url = "http://ericliu1002000:t2bd3107@#{ip}"
          # proxy_url = "http://#{ip}"
          pp proxy_url
          # sleep 1
          if redis[:proxy_ip] == proxy_url
            next
          end

          # redis[:proxy_ip] = proxy_url
          # puts "#{Time.now.chinese_format} #{proxy_url}"
          # 1.upto 20 do |i|
          #   next if redis[:proxy_ip].blank?
          #   sleep 1
          # end


            #验证代理信息
          RestClient.proxy = proxy_url
          response = nil
          Timeout::timeout(10) {
            response = RestClient.get 'http://xian.baixing.com/m/ershouqiche/?page=1', {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
          }
          content = response.body
          content = content.force_encoding('UTF-8')
          if content.match /百姓|二手/ and content.length > 400
            pp content
            redis[:proxy_ip] = proxy_url
            puts "#{Time.now.chinese_format} #{proxy_url}"
            redis.expire :proxy_ip, 300 #最多放5分钟
            1.upto 20 do |x|
              break if redis[:proxy_ip].blank?
              sleep 1
            end
          end
        rescue Exception => e
          pp e
        end
      end


    end
  end


  def self.get_proxy_ip
    redis = Redis.current
    redis[:proxy_ip]
  end

  def self.get url, header={}
    if RestClientProxy.get_local_ip != '10-19-104-142'
      response = RestClient.get url, header
      return response.body
    end
    pp url
    proxy_ip = RestClientProxy.get_proxy_ip
    # begin
    RestClient.proxy = proxy_ip
    pp "代理是：#{proxy_ip}"
    # response = nil
    # Timeout::timeout(10) {
    pp "代理是  #{RestClient.proxy}   ...."

    if proxy_ip.blank?
      sleep 1
      pp '获取ip失败'
      return ''
    end

    response = RestClient.get url, header
    # }
    response = response.body
    response = response.force_encoding('UTF-8')
    RestClient.proxy = nil
    if response.length < 300
      pp  'IP被封'
      pp response
      redis = Redis.current
      redis[:proxy_ip] = nil if proxy_ip == redis[:proxy_ip]
    end
    return response
    # rescue Exception => e
    # pp e
    # redis = Redis.current
    # redis[:proxy_ip] = nil if proxy_ip == redis[:proxy_ip]
    # end

  end

  def self.get_local_ip
    require 'socket'
    # IPSocket.getaddress(Socket.gethostname)
    # TCPSocket.gethostbyname(Socket.gethostname)
    Socket.gethostname
  end
end