class OrderSystem::Product < ActiveRecord::Base
  has_many :orders, :class_name => '::OrderSystem::Order'

  validates_presence_of :name, message: "产品名称不可以为空。"
  validates_presence_of :cover_image, message: "产品图片不可以为空。"


  def self.create_product options
    options = get_arguments_options options, [:name, :description, :url, :cover_image, :detail_image, :online, :sort_by, :app_name]
    self.transaction do
      product = self.new options
      product.save!
      product.reload
      product
    end
  end

  def update_product options
    options = self.class.get_arguments_options options, [:name, :description, :url, :cover_image, :detail_image, :online, :sort_by, :app_name]
    ::OrderSystem::Product.transaction do
      self.name = options[:name]
      self.description = options[:description]
      self.url = options[:url]
      self.cover_image = options[:cover_image] unless options[:cover_image].blank?
      self.detail_image = options[:detail_image] unless options[:detail_image].blank?
      self.online = options[:online] == '1'
      self.sort_by = options[:sort_by]
      self.app_name = options[:app_name]
      self.save!
      self.reload
      self
    end

  end
end