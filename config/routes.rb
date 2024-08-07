Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions"
    }

    resources :categories
    resources :products
    resources :users

    # Defines the root path route ("/")
    root to: 'products#index'
  end
end
