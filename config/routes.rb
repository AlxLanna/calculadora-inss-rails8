Rails.application.routes.draw do
  # Rotas padrão para o recurso Proponentes (index, show, new, edit)
  resources :proponentes, only: [ :index, :show, :new, :edit ] do
    # Endpoint para calcular o INSS via AJAX (GET ou POST, GET é comum para consulta)
    collection do
      get :calcular_inss
      # Endpoint para receber a submissão do formulário via AJAX e enfileirar o job
      post :enfileirar_proponente
    end
  end


  root "proponentes#index"
end
