Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users, controllers: {
      sessions: "users/sessions"
    }

    resources :mailings, only: %i[index] do
      collection do
        patch :update_settings, to: "mailings#update_settings", as: 'update_settings'
        get :settings, to: "mailings#settings", as: 'settings'
      end
    end

    resources :reports, only: %i[index] do
      collection do
        get :users, to: "reports#users_reports", as: 'users'
      end
    end

    resources :orders, except: %i[edit update] do
      collection do
        get :archive
        post 'create_for_product/:product_id', to: 'orders#create_for_product', as: :create_for_product
        delete 'delete_last', to: 'orders#delete_last', as: :delete_last
        get 'users', to: 'orders#users', as: :users
      end
    end
    resources :categories, except: %i[show edit update]
    resources :products do
      collection do
        get :archive
      end
      member do
        patch :restore
        delete :really_destroy
      end
    end

    resources :users, except: %i[new create] do
      member do
        patch :restore
        delete :really_destroy
        patch :approve

        get 'payment', to: 'user_payments#payment', as: 'payment'
        post 'payment/deposit_money', to: 'user_payments#deposit_money', as: 'deposit_money'
        post 'payment/pay_all_orders', to: 'user_payments#pay_all_orders', as: 'pay_all_orders'
        post 'payment/pay_order/:id', to: 'user_payments#pay_order', as: 'pay_order'
      end
      collection do
        get :requests
        get :archive
        patch :approve_all
        delete :delete_all
      end
    end

    resources :store, only: [:index], controller: 'telegram/store'

    # Маршруты для аутентификации через Telegram
    resource :telegram_session, only: [:new, :create], controller: 'telegram/sessions'

    telegram_webhook Telegram::TelegramWebhooksController

    # Defines the root path route ("/")
    root to: 'telegram/sessions#new'
  end
end
