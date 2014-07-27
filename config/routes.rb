Eatt::Application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'
  root to: 'home#index'

  get '/admin' => 'admin#index'
  namespace :admin do
    match '/recipe/:action' => 'recipe', via: [:get, :post]
  end
end
