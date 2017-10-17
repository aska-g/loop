Rails.application.routes.draw do
  devise_for :users


  resources :tasks

  match '/tasks/complete/:id' => 'tasks#complete', as: 'complete_task', via: :put
  match '/tasks/uncomplete/:id' => 'tasks#uncomplete', as: 'uncomplete_task', via: :put

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

end
