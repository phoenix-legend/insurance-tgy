class OrderSystem::TemplatesProducts < ActiveRecord::Base
  belongs_to :template, :class_name => '::OrderSystem::Template'
  belongs_to :product, :class_name => '::OrderSystem::Product'


  # has_many :orders, :class_name => '::OrderSystem::Order'
  #
  # validates_presence_of :name, message: "产品名称不可以为空。"
  # validates_presence_of :cover_image, message: "产品图片不可以为空。"


  # def self.create_product options
  #   options = get_arguments_options options, [:return_page, :adds_words, :price, :sale_number, :iphone_app_url, :android_app_url, :name, :description, :url, :cover_image, :detail_image, :online, :sort_by, :app_name]
  #   self.transaction do
  #     product = self.new options
  #     product.save!
  #     product.reload
  #     product
  #   end
  # end
  #
  # def update_product options
  #   options = self.class.get_arguments_options options, [:return_page, :adds_words, :price, :sale_number, :iphone_app_url, :android_app_url, :name, :description, :url, :cover_image, :detail_image, :online, :sort_by, :app_name]
  #   options[:online] = options[:online] == '1'
  #   options.delete(:cover_image) if options[:cover_image].blank?
  #   options.delete(:detail_image) if options[:detail_image].blank?
  #   ::OrderSystem::Product.transaction do
  #     self.update_attributes! options
  #     self
  #   end
  #
  # end
end