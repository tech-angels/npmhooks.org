NPMHooks::Application.routes.draw do
  root :to => 'homepage#index'

  get 'auth/github/callback' => 'sessions#create', :success => true
  get 'auth/failure' => 'sessions#create', :success => false
  get 'auth/github' => proc{ [404, {}, []] }

  get 'signout', to: 'sessions#destroy', as: 'signout'

  namespace :api do
    namespace :v1 do
      resources :web_hooks, :only => [:create, :index] do
        collection do
          delete :remove
          post :fire
        end
      end
    end
  end
end
