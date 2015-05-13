class Cms::OrderSystem::ProductsController < Cms::BaseController
  # before_filter :need_login

  def new
    session_content = get_session_content params[:session_content_id]
    pp session_content
    if session_content.blank?
      @name = ''
      @description = ['']
      @cover_image = ''
      @url = ''
      @online = false
    else
      @name = session_content[:name]
      @description = eval(session_content[:description]) rescue ''
      @cover_image = session_content[:cover_image]
      @url = session_content[:url]
      @online = session_content[:online] == '1'
      @sort_by = session_content[:sort_by]
      @app_name = session_content[:app_name]
    end
  end

  def create
    begin
      # BusinessException.raise 'xxx'
      params[:description] = params[:description].to_s unless params[:description].blank?
      params[:cover_image] = upload_file params[:cover_image] unless params[:cover_image].blank?
      ::OrderSystem::Product.create_product params.permit(:name, :description, :cover_image, :url, :online, :sort_by, :app_name)
      redirect_to '/cms/order_system/products'
    rescue Exception=>e
      dispose_exception e
      params.delete(:cover_image)
      redirect_to({action: :new, session_content_id: set_session_content }, alert: get_notice_str)
    end
  end

  def update
    begin
      # BusinessException.raise 'xxx'
      @product = ::OrderSystem::Product.find_by_id(params[:id])
      params[:description] = params[:description].to_s unless params[:description].blank?
      params[:cover_image] = upload_file params[:cover_image] unless params[:cover_image].blank?
      @product.update_product params.permit(:name, :description, :cover_image, :url, :sort_by, :app_name)
      redirect_to '/cms/order_system/products'
    rescue Exception=> e
      dispose_exception e
      params.delete(:cover_image)
      flash[:alert] = get_notice_str
      redirect_to "/cms/order_system/products/#{@product.id.to_s}/edit", session_content_id: set_session_content
    end
  end

  def index
    @products = ::OrderSystem::Product.all
  end

  def edit
    session_content = get_session_content params[:session_content_id]
    if session_content.blank?
      @product = ::OrderSystem::Product.find_by_id(params[:id])
      @name = @product.name
      @description = eval(@product.description) rescue ''
      @cover_image = @product.cover_image
      @url = @product.url
      @online = @product.online
      @sort_by = @product.sort_by
      @app_name = @product.app_name
    else
      @product = ::OrderSystem::Product.find_by_id(session_content[:id])
      @name = session_content[:name]
      @description = session_content[:description]
      @cover_image = session_content[:cover_image]
      @url = session_content[:url]
      @online = session_content[:online] == "1"
      @sort_by = session_content[:sort_by]
      @app_name = session_content[:app_name]
    end
  end

  private
    def upload_file name
      return '' if name.blank?
      uploaded_io = name
      dir = 'images'
      prefix = 'image'
      new_name = ''
      index = 1
      origin_name_with_path = Rails.root.join('public', 'uploads/' + dir, uploaded_io.original_filename)
      File.open(origin_name_with_path, 'wb') do |file|
        file.write(uploaded_io.read)
        new_name = prefix + Time.now.to_s(:number) + index.to_s + File.extname(file)
        new_name_with_path = Rails.root.join('public', 'uploads/' + dir, new_name)
        File.rename(origin_name_with_path, new_name_with_path)
        index += 1
      end
      new_name
    end
end