Rails.application.routes.draw do

  post '/authenticate', to: 'authentication#authenticate'
  get '/user/:provider/token', to: 'authentication#omniauth'
  get '/instagram-feed', to: 'application#instagram_pictures'

  resource :users
  resource :stores

  scope :users do

    get '/profile', to: 'users#show_public'

    patch '/hairdressers/bind', to: 'users#bind_hair_dresser'
    delete '/hairdressers/bind', to: 'users#unbind_hair_dresser'

    post '/images/:main', to: 'users#add_image'
    delete '/images/:id', to: 'users#remove_image'

    scope '/timetable' do
      get '/', to: 'users#get_timetable'
      get '/day', to: 'users#get_a_time_table'
      post '/time_section', to: 'users#modify_timetable'
      post '/time_section', to: 'stores#modify_timetable'
      delete '/time_section', to: 'users#delete_time_section'
      post '/collision', to: 'users#collision_check'
      post '/break', to: 'users#add_break'
      delete '/break', to: 'users#delete_break'
      post '/absence', to: 'users#add_absence'
      delete '/absence', to: 'users#delete_absence'
    end

    scope '/bookings' do
      get '/', to: 'users#bookings'
      post '/new', to: 'users#add_booking'
      delete '/deactive', to: 'users#remove_booking'
    end

    scope '/bookmark' do
      get '/', to: 'users#get_bookmark'
      post '/:type', to: 'users#add_bookmark'
      delete '/', to: 'users#remove_bookmark'
    end

    get '/available_times', to: 'appointments#available_times'

    resource :services
    resource :appointments
  end

  scope :stores do
    get '/list', to: 'stores#show_list'
    get '/area', to: 'stores#show_filtered'
    get '/:store_id/all_info', to: 'stores#show_all'

    get '/hairdressers', to: 'stores#show_dressers'
    put '/hairdresser/:store_id/:dresser_id', to: 'stores#append_dresser'
    delete '/hairdresser/:store_is/:dresser_id', to: 'stores#unbind_dresser'

    scope '/images' do
      get '/:store_id', to: 'stores#show_images'
      post '/:store_id/:main', to: 'stores#add_image'
      delete '/:store_id/:id', to: 'stores#remove_image'
    end

    scope '/timetable' do
      get '/day', to: 'stores#get_a_time_table'
      post '/time_section', to: 'stores#modify_timetable'
      patch '/time_section', to: 'stores#update_time_section'
      delete '/time_section', to: 'stores#delete_time_section'
      post '/collision', to: 'stores#collision_check'
      post '/break', to: 'stores#add_break'
      delete '/break', to: 'stores#delete_break'
    end

    resource :services
  end
end
