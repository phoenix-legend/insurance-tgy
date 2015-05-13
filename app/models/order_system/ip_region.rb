class OrderSystem::IpRegion < ActiveRecord::Base

  # {:address=>"CN|上海|上海|None|CHINANET|0|0", :province=>"上海市", :city=>"上海市"}
  def self.get_city_name ip
    ip_region = ::OrderSystem::IpRegion.find_by_ip(ip)
    return ip_region.city_name unless ip_region.blank?
    hash = EricTools.get_city_name_from_ip ak: 'HS8ViRxQT0xMu8d3uARISMif',:ip => ip
    return hash[:city] unless hash.blank?
    "上海"
  end

end