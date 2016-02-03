PlaygroundApp::Application.routes.draw do

  devise_for :users

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
    delete 'sign_out', to: 'devise/sessions#destroy'
    get 'sign_up', to: 'devise/registrations#new'
  end

  resources :users, except: [:create] do 
    member do
      match 'delete' => 'users#delete', via: :get
    end
  end

  resources :images, only: [:show]

  match 'users/new' => 'users#create', via: :post, as: :create_user
  match 'users/:id/password' => 'users#password', via: :get, as: :change_password
  match 'users/:id/password' => 'users#update_password', via: :put
  match 'users/:id/roles' => 'users#roles', via: :get, as: :edit_roles
  match 'users/:id/roles' => 'users#update_roles', via: :put

  resources :installations do
    member do
      match 'delete' => 'installations#delete', via: :get
    end
    resources :playlists do
      member do
        match 'delete' => 'playlists#delete', via: :get
        match 'scenes' => 'playlists#scenes', via: :get
        match 'scenes' => 'playlists#update_scenes', via: :post
      end
      collection { post :sort }
    end
  end

  match '/installations/:installation_id/playlists/:id/select_scenes' => 'playlists#select_scenes', via: :get, as: :select_scenes

  # This route lets us request a specific filename associated with a scene,
  # e.g. /scenes/3/data/acetophenone.spt with the filename in params[:filename]
  match '/scenes/:id/data/:filename' => 'scenes#data', 
        constraints: { filename: /.*/ }, as: :scene_file_data, via: :get

  # This route is for generating a simple script that just loads the main model and spins it
  # for 45 seconds
  match 'scenes/:id/simple_script' => 'scenes#simple_script', as: :scene_simple_script, via: :get

  # Routes for importing scenes from proteopedia
  #
  match 'scenes/import' => 'scenes#import', as: :import, via: :get
  match 'scenes/import' => 'scenes#create_import', as: :import, via: :post

  resources :scenes do
    member do
      match 'delete' => 'scenes#delete', via: :get
      match 'files' => 'scenes#files', via: :get
      match 'files' => 'scenes#update_files', via: :post
      match 'green' => 'scenes#green', via: :get
      match 'green' => 'scenes#update_green', via: :post
      get :preview
    end
  end

  resources :playlist_items, only: [:destroy]

  match '/home', to: 'home#index'

  root to: 'static_pages#home'
  match '/help', to: 'static_pages#help'
  match '/contact', to: 'static_pages#contact'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
