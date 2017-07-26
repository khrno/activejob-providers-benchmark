require 'sidekiq/web'
Rails.application.routes.draw do

  get 'welcome/index', as: :welcome
  post 'welcome/send_job_now', as: :send_job_now
  post 'welcome/send_job_later', as: :send_job_later

  root "welcome#index"
  resources :planets
  resources :greetings, only: :index

  mount Sidekiq::Web => '/sidekiq'
end
