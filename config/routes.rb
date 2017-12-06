Rails.application.routes.draw do

  post '/authenticate', to: 'authentication#authenticate'
  get '/user/:provider/token', to: 'authentication#omniauth'

  resource :users
  resource :stores

  scope :users do
    patch '/hairdressers/bind', to: 'users#bind_hair_dresser'
    delete '/hairdressers/bind', to: 'users#unbind_hair_dresser'

    post '/images/:main', to: 'users#add_image'
    delete '/images/:id', to: 'users#remove_image'

    resource :services
    resource :appointments
  end

  scope :stores do
    get '/:scope', to: 'stores#show_filtered'
    get '/:store_id/all_info', to: 'stores#show_all'

    get '/hairdressers', to: 'stores#show_dressers'
    put '/hairdresser/:store_id/:dresser_id', to: 'stores#append_dresser'
    delete '/hairdresser/:store_is/:dresser_id', to: 'stores#unbind_dresser'

    scope '/images' do
      get '/:store_id', to: 'stores#show_images'
      post '/:store_id/:main', to: 'stores#add_image'
      delete '/:store_id/:id', to: 'stores#remove_image'
    end
    resource :services
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
