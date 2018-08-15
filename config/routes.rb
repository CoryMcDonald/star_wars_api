Rails.application.routes.draw do
  root to: redirect('films')

  resources :films, only: [:index, :show]
  resources :people, only: [:index, :show]
end
