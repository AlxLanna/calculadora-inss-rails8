class ProponentesController < ApplicationController
  # TODO remover essa linha
  protect_from_forgery except: [ :enfileirar_proponente ]

  def index
  end

  def show
    @proponente = Proponente.find(params[:id])
  end

  def new
    @proponente = Proponente.new
    # Pré-construir um endereço e um contato para o formulário
    @proponente.enderecos.build
    @proponente.contatos.build
  end

  # =========================================================================
  # AS AÇÕES 'CREATE' E 'UPDATE' SÃO TRATADAS PELO BACKGROUND JOB
  # E ENFILEIRADAS PELO MÉTODO 'ENFILEIRAR_PROPONENTE'.
  # =========================================================================

  def edit
    @proponente = Proponente.find(params[:id])
    # Garante que sempre haja pelo menos um campo vazio
    # para adicionar novo endereço ou contato ao editar
    @proponente.enderecos.build if @proponente.enderecos.empty?
    @proponente.contatos.build if @proponente.contatos.empty?
  end

  def destroy
  end

  # =========================================================================
  # REQUISIÇÕES ASSÍNCRONAS E BACKGROUND JOB
  # =========================================================================

  # Endpoint para calcular o INSS e retornar via JSON.
  def calcular_inss
    salario_bruto = params[:salario] 
    # Chama o service object para calcular o desconto
    desconto = CalculadoraInss.calculate(salario_bruto)
    render json: { desconto_inss: desconto }
  end

  # Endpoint para receber os dados do formulário via AJAX e enfileirar o job.
  # Destino da submissão do formulário pelo Stimulus.
  def enfileirar_proponente
    # proponente_params.to_unsafe_h converte os parâmetros filtrados para um hash.
    # Usamos to_unsafe_h aqui para passar os parâmetros para o job.
    # O job será responsável por usar esses parâmetros para criar ou atualizar o Proponente.
    ProponenteJob.perform_later(proponente_params.to_unsafe_h)

    # Retorna uma resposta JSON rápida para o frontend, indicando que o job foi enfileirado.
    render json: { status: "ok", message: "Proponente enfileirado para processamento." }
  rescue => e
    # Em caso de erro ao enfileirar (raro, mas possível), retorna um erro para o frontend.
    render json: { status: "error", message: e.message }, status: :unprocessable_entity
  end

  # =========================================================================

  private

  def proponente_params
    params.require(:proponente).permit(
      :nome,
      :documentos,
      :data_nascimento,
      :salario,
      :desconto_inss, # Este valor será retornado e gravado
      enderecos_attributes: [
        :id,
        :logradouro,
        :numero,
        :bairro,
        :cidade,
        :estado,
        :cep,
        :_destroy
      ],
      contatos_attributes: [
        :id,
        :tipo,
        :valor,
        :_destroy
      ]
    )
  end
end
