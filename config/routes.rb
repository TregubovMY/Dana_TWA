Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions"
    }

    resources :orders
    resources :categories
    resources :products

    resources :users, except: %i[new create] do
      member do
        patch :restore
        delete :really_destroy
        patch :approve
      end
      collection do
        get :requests
        get :archive
        patch :approve_all
        delete :delete_all
      end
    end

    # Defines the root path route ("/")
    root to: 'products#index'
  end

  telegram_webhook TelegramWebhooksController
end
