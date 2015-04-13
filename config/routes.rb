Rest::Application.routes.draw do
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

  namespace :api do
	get 'getbaseimages' => 'imagesapi#show'
	get 'getderivedimages/:id' => 'imagesapi#showderived'
	get 'gethosts' => 'hostapi#showhosts'
	get 'getusers' => 'userapi#showusers'
	get 'createcvm/user/:userid/image/:imageid/cvmname/:cvmname/public/:ispublic/host/:hostid' => 'cvmapi#createcvm'
    get 'operatecvm/user/:userid/cvmid/:cvmid/operation/:operation' => 'cvmapi#operatecvm'
    get 'adduser/username/:username/email/:email/isadmin/:isadmin/password/:password' => 'userapi#addusers'
    get 'commit/cvmid/:cvmid/imagename/:imagename/description/:description/ispublic/:ispublic' => 'imagesapi#commitnew'
    get 'addhosts/hostname/:name/ip/:ip/username/:username/password/:password/cpu/:cpu/ram/:ram/storage/:storage/hostos/:hostos' => 'hostapi#addhost'

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
