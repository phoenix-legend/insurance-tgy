class MailSend < BaseMailer

  def send_car_user_infos file_path, receiver, copy_receivers, record_number
    pp "file_path.."
    pp file_path
    attachments[file_path] = File.read( file_path )
    mail( to: receiver, cc: copy_receivers,  subject:  "车主信息数据#{record_number}条")
    # File.delete file_path
    ::UserSystem::CarUserInfoSendEmail.create_car_user_info_send_email receiver: receiver,
                                                                       cc: copy_receivers,
                                                                       attachment_name: file_path,
                                                                       record_number: record_number
  end

  # def send_validation_code email, user_name, post_time, random
  #   @user_name = user_name
  #   @post_time = post_time
  #   @random = random
  #   mail( to: email, subject: '密码找回')
  # end
  #
  # def send_action_audit_to_jianghui
  #   mail( to: 'hui.jiang@ikidstv.com', cc: 'ericliu@ikidstv.com', subject: '苹果他们开始审核了，你是我的小苹果！')
  # end
  #
  # def send_recent_sale_info email, cc
  #   @potential_customer_yesterday_count = ::SaleSystem::PotentialCustomer.where("register_time between ? and ? ", (Time.now.to_date - 1.day).to_time.to_s, Time.now.to_date.to_time.to_s).count
  #   @potential_customer_total_count = ::SaleSystem::PotentialCustomer.count
  #   @seller_tracking_infos_yesterday_count = ::SaleSystem::SellerTrackingInfo.where("track_time between ? and ? ", (Time.now.to_date - 1.day).to_time.to_s, Time.now.to_date.to_time.to_s).count
  #   @seller_tracking_infos_total_count = ::SaleSystem::SellerTrackingInfo.count
  #   file = ::SaleSystem::PotentialCustomer.export_recent_sale_info
  #   attachments["#{Time.now.chinese_format}销售数据统计.xls"] = File.read( file )
  #   mail(to: email, cc: cc, subject: "#{Time.now.chinese_format}销售数据统计.xls")
  #   File.delete file
  # end
end
