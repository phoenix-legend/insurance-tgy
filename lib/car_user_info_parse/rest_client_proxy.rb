module RestClientProxy
  require 'timeout'
  # RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip
    while true
      begin
        puts '...'
        # 获取代理信息
        RestClient.proxy = nil
        url = "http://api.ip.data5u.com/dynamic/get.html?order=64a868c8fc23532cdd38ccb125b72873"
        response = RestClient.get url
        proxy_url = "http://#{response.body.gsub("\n", '')}"
        #验证代理信息
        RestClient.proxy = proxy_url
        response = nil
        Timeout::timeout(5) {
          response = RestClient.get 'http://www.baixing.com', {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'}
        }
        content = response.body
        content = content.force_encoding('UTF-8')
        if content.match /二手/
          redis = Redis.current
          redis[:proxy_ip] = proxy_url
          puts "#{Time.now.chinese_format} #{proxy_url}"

          redis.expire :proxy_ip, 300 #最多放5分钟
        end
      rescue Exception => e
      end
      # sleep 2
    end
  end

  def self.get_proxy_ip
    redis = Redis.current
    redis[:proxy_ip]
  end

  def self.get url, header
    RestClient.proxy = RestClientProxy.get_proxy_ip
    response =nil
    Timeout::timeout(5) {
      response = RestClient.get url, header
    }
    response = response.body
    response = response.force_encoding('UTF-8')
    RestClient.proxy = nil
    response
  end
end