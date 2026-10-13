Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :cat_imports, path: "imports", only: %i[index show create destroy] do
    post :retry, on: :member
    resources :breeds, only: %i[index]
    resources :breed_imports, only: %i[create], shallow: true do
      post :retry, on: :member
    end
    resources :breed_assignments, only: %i[index create], shallow: true do
      post :retry, on: :member
    end
    resources :reports, only: %i[new create show destroy], shallow: true do
      post :retry, on: :member
    end
    resources :charts, only: %i[new create show destroy], shallow: true do
      post :retry, on: :member
      get :image, on: :member
    end
  end

  resources :questions, only: [] do
    post :answer, on: :member
  end

  root "cat_imports#index"
end
