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

  PROXYIP_WUBA1 = 'http://zrx03:84413@222.184.35.196:33053'
  PROXYIP_WUBA2 = 'http://zrx12:653312@222.184.35.196:33161'
  PROXYIP_WUBA3 = 'http://zrx04:65581@222.184.35.196:33081'
  PROXYIP_WUBA4 = 'http://zrx05:65581@222.184.35.196:33085'

  PROXYIP_GANJI1 = 'http://zrx07:65581@222.184.35.196:33141'
  PROXYIP_GANJI2 = 'http://zrx08:65581@222.184.35.196:33121'
  PROXYIP_GANJI3 = 'http://zrx09:65581@222.184.35.196:33145'

  PROXYIP_QITA1 = 'http://zrx10:65581@222.184.35.196:33153'
  PROXYIP_QITA2 = 'http://zrx11:65581@222.184.35.196:33157'
  PROXYIP_QITA3 = 'http://zrx06:65581@222.184.35.196:33089'


  # RestClientProxy.refresh_proxy_ip
  def self.refresh_proxy_ip
    [PROXYIP_GANJI1, PROXYIP_GANJI2, PROXYIP_GANJI3, PROXYIP_WUBA1, PROXYIP_WUBA2, PROXYIP_WUBA3, PROXYIP_WUBA4, PROXYIP_QITA1, PROXYIP_QITA2, PROXYIP_QITA3].each do |k|
      nameandpassword = (k.match /http:\/\/(.{11,12})@/)[1]
      sleep 3
      `curl -u #{nameandpassword} http://ip.hahado.cn/switch-ip`
    end

  end


  def self.get_proxy_ip
    case RestClientProxy.get_local_ip
      when HOSTNAME_GANJI1
        PROXYIP_GANJI1
      when HOSTNAME_GANJI2
        PROXYIP_GANJI2
      when HOSTNAME_GANJI3
        PROXYIP_GANJI3
      when HOSTNAME_QITA1
        PROXYIP_QITA1
      when HOSTNAME_QITA2
        PROXYIP_QITA2
      when HOSTNAME_QITA3
        PROXYIP_QITA3
      when HOSTNAME_WUBA1
        PROXYIP_WUBA1
      when HOSTNAME_WUBA2
        PROXYIP_WUBA2
      when HOSTNAME_WUBA3
        PROXYIP_WUBA3
      when HOSTNAME_WUBA4
        PROXYIP_WUBA4
      else
        PROXYIP_WUBA4
    end

  end


  def self.get url, header={}
    proxy_ip = RestClientProxy.get_proxy_ip
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

end