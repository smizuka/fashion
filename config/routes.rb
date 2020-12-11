Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  root 'sessions#new'
  get 'sessions/new'
  get 'sessions/update'

  get 'works/main'
  get 'works/main2'
  get 'works/pass'
  post 'works/action'
  post 'works/action2'
  post 'works/trim'
  get 'works/mainBack'
  get 'works/mainBack2'
  post 'works/annoBack'
  get 'works/annotation'

  #adminsにアクセスしたときの動き
  get 'admins/main'
  get 'admins/progress'
  get 'admins/preprocess'

  get 'admins/changeRowState'

  get 'admins/post'
  get 'admins/post2'
  get 'admins/post3'
  get 'admins/avg'
  delete 'admins/destroyFile'
  delete 'admins/destroyUser'
  post 'admins/display'
  post 'admins/hidden'

  #部分テンプレートの記述
  # get 'admins/allocation'


  post 'admins/add_file', to: 'admins#add_file'
  post 'admins/create_allocation', to: 'admins#create_allocation'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # post 'admins/create_allocation'

  resources :users

end
