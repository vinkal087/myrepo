Rest::Application.routes.draw do
  get "dashboard/images"
  get "dashboard/cvms"
  get "dashboard/users"
  get "dashboard/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

 #resources :welcome do
 #resources :comments, :only => [:create]
  # You can have the root of your site routed with "root"
  
  root 'dashboard#index'


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  namespace :api do
	get 'getbaseimages' => 'imagesapi#show'
	get 'getderivedimages/:id' => 'imagesapi#showderived'
	get 'gethosts' => 'hostapi#showhosts'
	get 'getusers' => 'userapi#showusers'
	get 'getcvms/:user_id' => 'cvmapi#showcvmall'
  get 'getallimages' =>'imagesapi#showall'
    get 'getrunningcvms' => 'cvmapi#showrunningcvm'
    get 'cvmdetails/:cvmid' => 'cvmapi#cvmdetails'
    #get 'createcvm/user/:userid/image/:imageid/cvmname/:cvmname/public/:ispublic/host/:hostid/cpu/:cpu/memory/:ram' => 'cvmapi#createcvm'
    post 'createcvm' => 'cvmapi#createcvm'
    get 'operatecvm/:cvmid/:operation' => 'cvmapi#operatecvm'
    post 'adduser' => 'userapi#addusers'
    get 'commit/cvmid/:cvmid/imagename/:imagename/description/:description/ispublic/:ispublic' => 'imagesapi#commitnew'
    post 'addhost/' => 'hostapi#addhost'
    post 'authenticate' => 'userapi#authenticate'
    get 'hostdetails/:id' => 'hostapi#hostdetails'

  end
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
end
