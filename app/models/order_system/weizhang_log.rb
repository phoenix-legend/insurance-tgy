class OrderSystem::WeizhangLog < ActiveRecord::Base
  # validates_presence_of :vin_no, message: '请正确填写车架号'
  # validates_presence_of :engine_no, message: '请正确填写发动机号'
  # validates_format_of :vin_no, :with => EricTools::RegularConstants::VinNo, message: '请正确填写车架号', allow_blank: true
  # validates_format_of :engine_no, :with => EricTools::RegularConstants::EngineNo, message:'请正确填写发动机号' ,allow_blank: true


  def self.add_baixing_json_body str
    log = OrderSystem::WeizhangLog.new contents: str
    log.save!
  end

  def self.get_baixing_json_body
    log = OrderSystem::WeizhangLog.last
    return if log.blank?
    body = log.contents
    log.destroy!
    return body
  end

end