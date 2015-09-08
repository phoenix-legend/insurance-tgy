class MailSend < BaseMailer

  def send_car_user_infos  receiver, copy_receivers, record_number,zhuti, file_paths

    file_paths.each do |file_path|
      attachments["#{Time.now.chinese_format}-#{record_number}条.xls"] = File.read( file_path )
    end

    mail( to: receiver, cc: copy_receivers,  subject:  "#{record_number}总计,#{zhuti}")
    # File.delete file_path
    ::UserSystem::CarUserInfoSendEmail.create_car_user_info_send_email receiver: receiver,
                                                                       cc: copy_receivers,
                                                                       attachment_name: file_paths.join(','),
                                                                       record_number: record_number
  end

end
