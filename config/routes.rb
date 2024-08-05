Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users

    # Defines the root path route ("/")
    root to: 'devise/sessions#new'
  end
end
