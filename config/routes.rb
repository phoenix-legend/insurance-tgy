Rails.application.routes.draw do




  namespace :cms do
    namespace :personal do
      resources :organizations do
        member do
          get :set_roles
          post :commit_roles
        end
      end
    end
    resources :employees do
      collection do
        get :set_role
        post :set_role
      end
    end
    resources :roles do
      collection do
        get :set_functions
        post :set_functions
      end
    end
    namespace :employee_validate do
      resource :functions do
        collection do
          get :index
          get :welcome
          get :menu
          get :login
          post :login
          get :logout
          get :list
          post :update2
          get :not_teacher
          get :modify_password
          post :modify_password
        end
      end
    end


    namespace :sys do

      resources :system_configs
    end
end
  namespace :order_system do
    resources :products do
      collection do
        get :new_appointment
        post :create_appointment
        get :appointment_success
        get :compare_price
        post :search_price
        get :display_price
      end
    end
    resources :orders
  end
  namespace :user_system do
    resources :user_infos
  end


  get '/cms', to: 'cms/employee_validate/functions#login'



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  #root to: "cms/employees#index"
end
