Eatt::Application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'

  get '' => 'admin#index', constraints: { subdomain: 'admin' }, :path_names => {:new => ''}
  namespace :admin, path: '/', constraints: { subdomain: 'admin' } do
    match '/recipe/:action' => 'recipe', via: [:get, :post]
    match '/recipe/:id/:action' => 'recipe', via: [:get, :post]
    match '/oauth/:action' => 'oauth', via: [:get, :post]
  end

  match '/:controller/:action', via: [:get, :post]

  get '/:action' => 'home'

  root to: 'home#index'
end
