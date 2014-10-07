Eatt::Application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'
  root to: 'home#index'

  get '/admin' => 'admin#index'
  namespace :admin do
    match '/recipe/:action' => 'recipe', via: [:get, :post]
    match '/recipe/:id/:action' => 'recipe', via: [:get, :post]
    match '/oauth/:action' => 'oauth', via: [:get, :post]
  end

  match '/:controller/:action', via: [:get, :post]
end
