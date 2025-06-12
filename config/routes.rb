Rails.application.routes.draw do
  devise_for :users
  # Rotas padrão para o recurso Proponentes (index, show, new, edit)
  resources :proponentes, only: [ :index, :show, :new, :edit, :destroy ] do
    # Endpoint para calcular o INSS via AJAX (GET ou POST, GET é comum para consulta)
    collection do
      get :calcular_inss
      # Endpoint para receber a submissão do formulário via AJAX e enfileirar o job
      match :enfileirar_proponente, via: [ :post, :patch ]
    end
  end

  get "dashboard", to: "proponentes#dashboard"

  root "proponentes#index"
end
