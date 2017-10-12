Rails.application.routes.draw do
  devise_for :users


  resources :tasks, only: [ :index, :new, :create, :show ]

  match '/tasks/complete/:id' => 'tasks#complete', as: 'complete_task', via: :put
  match '/tasks/uncomplete/:id' => 'tasks#uncomplete', as: 'uncomplete_task', via: :put

  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
