class UserSystem::ZtxCarUserInfo < ActiveRecord::Base

  belongs_to :group_car_user_info, :class_name => 'UserSystem::GroupCarUserInfo'

  APPID = Rails.env.production? ? '123456' : '30001'
  CHE_STORE_URL = Rails.env.production? ? "http://123.57.85.186/clue/index.php?c=clue&m=store" : "http://123.57.167.52:8088/clue/index.php?c=clue&m=store"
  CHE_SHOW_URL = Rails.env.production? ? "http://123.57.85.186/clue/index.php?c=clue&m=show" : "http://123.57.167.52:8088/clue/index.php?c=clue&m=show"

  AUTH_TOKEN = Rails.env.production? ? '123456' : 'iekijd39j7d6f'

  REQUEST_STATUS = {
     0=>'查询成功',
    -1=>'指定线索id不存在 或者 参数校验失败',
    -2=>'用户不存在',
    -4=>'app_id无效',
    -5=>'token无效',
    -6=>'时间戳无效',
    -7=>'线索重复',
    -8=>'获取详情失败'
  }

  DATA_STATUS = {
      0 => '信息已收录，但尚未联系车主',
      1 => '已联系车主，该车源信息真实有效',
      2 => '已联系车主，该车源信息无效',
      3 => '车辆验收成功',
      4 => '车辆验收失败',
      5 => '已发布',
      6 => '已下架',
      7 => '已关闭',
      8 => '成功售出'
  }


  # 保存并且提交车信息
  def self.save_and_post_car_user_infos excel, post_date
    self.transaction do
      self.post_car_user_infos self.save_car_user_infos_from_excel(excel, post_date)
    end
  end

  # 从excel取数据存到excel, 返回组id
  def self.save_car_user_infos_from_excel excel, post_date
    self.transaction do

      file_name = excel.original_filename
      info = UserSystem::GroupCarUserInfo.where(name: file_name, post_date: post_date).first
      BusinessException.raise "#{post_date}这天您已经提交过一个名为#{file_name}的excel,为了以后方便查询，请更改文件名。" unless info.blank?

      group_car_user_info = UserSystem::GroupCarUserInfo.new name: file_name,
                                                             post_date: post_date
      group_car_user_info.save!

      Spreadsheet.client_encoding = 'UTF-8'
      dir = 'public/temp'
      Dir.mkdir dir unless Dir.exist? dir
      path = Rails.root.join(dir, file_name)
      File.open(path, 'wb') do |f|
        f.write(excel.read)
      end
      book = Spreadsheet.open path
      sheet = book.worksheet 0
      BusinessException.raise '请确保第一列第一行－列名为 品牌' unless sheet.row(0)[0] == '品牌'
      BusinessException.raise '请确保第一列第一行－列名为 上牌年份' unless sheet.row(0)[1] == '上牌年份'
      BusinessException.raise '请确保第一列第一行－列名为 车型' unless sheet.row(0)[2] == '车型'
      BusinessException.raise '请确保第一列第一行－列名为 姓名' unless sheet.row(0)[3] == '姓名'
      BusinessException.raise '请确保第一列第一行－列名为 电话' unless sheet.row(0)[4] == '电话'
      BusinessException.raise '请确保第一列第一行－列名为 车系' unless sheet.row(0)[5] == '车系'

      sheet.each_with_index do |row, index|
        next if index == 0
        car_user_info = self.new group_car_user_info_id: group_car_user_info.id,
                                 brand: row[0],
                                 licensed_date: "#{row[1]}-1".to_date,
                                 model_info: row[2],
                                 owner_name: row[3],
                                 owner_phone: row[4],
                                 series: row[5]
        car_user_info.save!
      end
      group_car_user_info.id
    end
  end

  # 根据组，提交车信息
  def self.post_car_user_infos group_id
    group = UserSystem::GroupCarUserInfo.find(group_id)
    group.ztx_car_user_infos.each do |c_u|
      c_u.post_car_user_info
    end
  end

  # 提交一个车信息
  def post_car_user_info
    timestamp = Time.now.to_i
    app_id = UserSystem::ZtxCarUserInfo::APPID
    payload = {
        :app_id => app_id,
        :brand => brand,
        :licensed_date => licensed_date.to_s,
        :model => model_info,
        :owner_name => owner_name,
        :owner_phone => owner_phone,
        :series => series,
        :timestamp => timestamp,
        :token => Digest::MD5.hexdigest("#{app_id}#{UserSystem::ZtxCarUserInfo::AUTH_TOKEN}#{timestamp}")
    }
    response = RestClient.post UserSystem::ZtxCarUserInfo::CHE_STORE_URL, payload
    pp response
    response = MultiXml.parse response
    response = response["xml"] unless response["xml"].blank?
    self.update_attribute :post_status, response["status"] unless response["status"].blank?
    self.update_attribute :post_error_msg, response["err_msg"] unless response["err_msg"].blank?
    self.update_attribute :data_id, response["data"] unless response["data"].blank?
  end

  def get_car_user_info
    timestamp = Time.now.to_i
    app_id = UserSystem::ZtxCarUserInfo::APPID
    payload = {
        :app_id => app_id,
        :id => data_id,
        :timestamp => timestamp,
        :token => Digest::MD5.hexdigest("#{app_id}#{UserSystem::ZtxCarUserInfo::AUTH_TOKEN}#{timestamp}")
    }
    response = RestClient.get "#{UserSystem::ZtxCarUserInfo::CHE_STORE_URL}?app_id=#{app_id}&id=#{data_id}&timestamp=#{timestamp}&token=#{Digest::MD5.hexdigest("#{app_id}#{UserSystem::ZtxCarUserInfo::AUTH_TOKEN}#{timestamp}")}"
    response = MultiXml.parse response
    response = response["xml"] unless response["xml"].blank?
    self.update_attribute :get_request_status, response["status"] unless response["status"].blank?
    self.update_attribute :get_error_msg, response["err_msg"] unless response["err_msg"].blank?
    self.update_attribute :data_status, response["data"]["status"] unless response["data"].blank? || response["data"]["status"].blank?
  end

  def self.update_data_status
    self.where("data_status is null").each do |c_u|
      c_u.get_car_user_info
    end
  end
end