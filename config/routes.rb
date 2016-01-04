Rails.application.routes.draw do
  root 'welcome#index'

  # fixed routes being plural (rails bug)
  get 'games/:id', to: 'game#show'
  post 'games/', to: 'game#create'

  get 'game/leave', to: "game#leave_game"
  get 'game/start', to: "game#start_game"
  get 'game/draw', to: "game#draw_card"

  get 'game/index'
  get 'game/join'

  get 'cards/:id', to: "game#normal_card"

  get 'cards/red/:id', to: "game#wild_red"
  get 'cards/blue/:id', to: "game#wild_blue"
  get 'cards/yellow/:id', to: "game#wild_yellow"
  get 'cards/green/:id', to: "game#wild_green"

  get 'pusher/chat'
  resources :articles
  resources :games
  resources :cards
  devise_for :users
  get 'welcome/index'

  # fixed devise signout breaking
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  get 'game/refresh' => 'game#refresh'
  get 'games/game/refresh' => 'game#refresh'
  get 'game/game/refresh' => 'game#refresh'

  # fox so chat can load in game
  #get 'chat_messages/index'
  get 'chat_messages/_index'
  resources :chat_messages, only: [:create]

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
end
