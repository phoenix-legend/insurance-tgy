class UserSystem::GroupCarUserInfo < ActiveRecord::Base
  has_many :ztx_car_user_infos, :class_name => 'UserSystem::ZtxCarUserInfo'

  def download
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new

    sheet = book.create_worksheet name: '车信息'
    sheet.row(0).push '品牌', '上牌年份', '车型', '姓名', '电话', '车系', '数据id', '提交状态', '提交信息', '查询状态', '数据状态'

    index = 1
    ztx_car_user_infos.each do |c_u|
      sheet.row(index).push c_u.brand, c_u.licensed_date, c_u.model_info, c_u.owner_name, c_u.owner_phone, c_u.series,
                            c_u.data_id,
                            c_u.post_status,
                            c_u.post_error_msg,
                            UserSystem::ZtxCarUserInfo::REQUEST_STATUS[c_u.get_request_status],
                            UserSystem::ZtxCarUserInfo::DATA_STATUS[c_u.data_status]
      index += 1
    end

    dir = Rails.root.join('public', 'tmp')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir,"#{name}.xls")
    book.write file_path
    file_path
  end
end