Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions"
    }

    resources :reports, only: %i[index] do
      collection do
        get :users, to: "reports#users_reports", as: 'users'
      end
    end

    resources :orders, except: %i[edit update] do
      collection do
        get :archive
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
      end
      collection do
        get :requests
        get :archive
        patch :approve_all
        delete :delete_all
      end
    end

    # Defines the root path route ("/")
    root to: 'reports#index'
  end

  telegram_webhook TelegramWebhooksController
end
