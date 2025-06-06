class ProponentesController < ApplicationController
  # TODO remover essa linha
  protect_from_forgery except: [ :enfileirar_proponente ]

  def index
    # Paginação
    @proponentes = Proponente.page(params[:page]).per(5)
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

  def dashboard
    # Carrega as faixas salariais do YAML
    faixas_config_raw = YAML.load_file(Rails.root.join("config", "tabela_inss.yml"))["faixas_atuais"]

    # Mapeia as faixas
    faixas_salariais = {}
    faixas_config_raw.each_with_index do |faixa, index|
      limite_max = faixa["limite_max"].to_f
      label = case index
      when 0 then "Até R$ #{'%.2f' % limite_max}"
      when faixas_config_raw.length - 1 then "De R$ #{'%.2f' % (faixas_config_raw[index-1]['limite_max'].to_f + 0.01)} a R$ #{'%.2f' % limite_max}"
      else "De R$ #{'%.2f' % (faixas_config_raw[index-1]['limite_max'].to_f + 0.01)} a R$ #{'%.2f' % limite_max}"
      end
      faixas_salariais[label] = limite_max
    end

    # Inicializa o hash para contar proponentes por faixa
    @proponentes_por_faixa = Hash.new { |hash, key| hash[key] = 0 }

    # Percorre todos os proponentes para contá-los em suas faixas
    Proponente.find_each do |proponente|
      faixa_encontrada = false
      limite_inferior_anterior = 0.0 # Usado para calcular o limite inferior da faixa atual

      faixas_config_raw.each do |faixa_data|
        limite_superior_faixa = faixa_data["limite_max"].to_f

        # Determina o label da faixa
        label = case faixas_config_raw.index(faixa_data)
        when 0 then "Até R$ #{'%.2f' % limite_superior_faixa}"
        when faixas_config_raw.length - 1 then "De R$ #{'%.2f' % (limite_inferior_anterior + 0.01)} a R$ #{'%.2f' % limite_superior_faixa}"
        else "De R$ #{'%.2f' % (limite_inferior_anterior + 0.01)} a R$ #{'%.2f' % limite_superior_faixa}"
        end

        if proponente.salario <= limite_superior_faixa && proponente.salario > limite_inferior_anterior
          @proponentes_por_faixa[label] += 1
          faixa_encontrada = true
          break
        end
        limite_inferior_anterior = limite_superior_faixa # Atualiza para a próxima iteração
      end

      # Se o salário for maior que o teto da última faixa configurada
      unless faixa_encontrada
        @proponentes_por_faixa["Acima de R$ #{'%.2f' % faixas_config_raw.last['limite_max'].to_f}"] += 1
      end
    end

    # Garante que a ordem das faixas definidas no YAML seja mantida
    @proponentes_por_faixa_ordenada = {}
    faixas_salariais.keys.each do |label| # Usa os labels formatados do hash faixas_salariais
      @proponentes_por_faixa_ordenada[label] = @proponentes_por_faixa[label] || 0
    end

    # Adiciona a faixa "Acima do Teto" se houver proponentes nela
    acima_do_teto_label = "Acima de R$ #{'%.2f' % faixas_config_raw.last['limite_max'].to_f}"
    @proponentes_por_faixa_ordenada[acima_do_teto_label] = @proponentes_por_faixa[acima_do_teto_label] if @proponentes_por_faixa[acima_do_teto_label] > 0
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
