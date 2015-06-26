class OrderSystem::Template < ActiveRecord::Base
  has_many :templates_products, :class_name => '::OrderSystem::TemplatesProducts', foreign_key: 'template_id'
  has_many :products, :class_name => '::OrderSystem::Product', through: :templates_products

  validates_presence_of :show_name, message: 'show_name不能为空。'
  validates_presence_of :real_name, message: 'real_name不能为空。'

  def self.create_template options
    product_options = options[:products]
    options = get_arguments_options options, [:show_name, :real_name, :is_valid], is_valid: true
    template = self.new options
    template.save!
    template.reload

  end

  def update_template
    product_options = options[:products]
    options = get_arguments_options options, [:show_name, :real_name, :is_valid], is_valid: true
  end

end