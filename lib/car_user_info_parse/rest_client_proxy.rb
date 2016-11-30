module RestClientProxy
  require 'timeout'
  # RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip
    redis = Redis.current

    while true
      if redis[:proxy_ip].length > 700
        sleep 3
        next
      else
        sleep 1
      end
      begin
        # 获取代理信息
        RestClient.proxy = nil
        url = "http://api.ip.data5u.com/dynamic/get.html?order=64a868c8fc23532cdd38ccb125b72873"
        response = RestClient.get url
        proxy_url = "http://#{response.body.gsub("\n", '')}"
        next if redis[:bad_proxy_ip].include? proxy_url
        if redis[:proxy_ip].blank?
          redis[:proxy_ip] = proxy_url
        else
          redis[:proxy_ip] = "#{redis[:proxy_ip]},#{proxy_url}" unless redis[:proxy_ip].include?(proxy_url)
        end

          # if redis[:proxy_ip] == proxy_url
          #   next
          # end
          # #验证代理信息
          # RestClient.proxy = proxy_url
          # response = nil
          # Timeout::timeout(5) {
          #   response = RestClient.get 'http://www.baixing.com', {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
          # }
          # content = response.body
          # content = content.force_encoding('UTF-8')
          # if content.match /百姓|二手/
          #   redis[:proxy_ip] = proxy_url
          #   puts "#{Time.now.chinese_format} #{proxy_url}"
          #   sleep 5
          # redis.expire :proxy_ip, 300 #最多放5分钟
          # end
      rescue Exception => e
        # pp e
      end
      # sleep 2
    end
  end

  # RestClientProxy.refresh_daxiang_proxy_ip
  def self.refresh_daxiang_proxy_ip
    redis = Redis.current

    while true
      if redis[:proxy_ip].length > 700
        sleep 3
        next
      else
        sleep 1
      end
      begin
        RestClient.proxy = nil
        url = "http://tpv.daxiangdaili.com/ip/?tid=558075121539166&num=10&delay=3&category=2&foreign=none"
        response = RestClient.get url
        response = response.body
        ips = response.split("\r\n")
        ips.each do |ip|
          proxy_url = "http://#{ip}"
          next if redis[:bad_proxy_ip].include? proxy_url
          if redis[:proxy_ip].blank?
            redis[:proxy_ip] = proxy_url
          else
            redis[:proxy_ip] = "#{redis[:proxy_ip]},#{proxy_url}" unless redis[:proxy_ip].include?(proxy_url)
          end
        end
      rescue Exception => e
      end
    end
  end

  # RestClientProxy.get_proxy_ip
  def self.get_proxy_ip
    redis = Redis.current
    return nil if redis[:proxy_ip].blank?
    redis[:proxy_ip].split(',').shuffle[0]
  end

  # RestClientProxy.get 'http://www.baixing.com', {}
  def self.get url, header
    response =nil
    proxy_url = RestClientProxy.get_proxy_ip
    begin
      RestClient.proxy = proxy_url
      Timeout::timeout(5) {
        response = RestClient.get url, header
      }
      response = response.body
      response = response.force_encoding('UTF-8')
      RestClient.proxy = nil
      return response
    rescue Exception => e
      redis = Redis.current
      pp "删除"
      redis[:proxy_ip] = redis[:proxy_ip].gsub("#{proxy_url},", '')
      if redis[:bad_proxy_ip].blank?
        redis[:bad_proxy_ip] = proxy_url
      else
        redis[:bad_proxy_ip] = "#{redis[:bad_proxy_ip]},#{proxy_url}" unless redis[:bad_proxy_ip].include? proxy_url
      end
      pp e
      raise e
    end
  end
end