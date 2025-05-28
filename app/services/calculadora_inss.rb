# app/services/calculadora_inss.rb

require 'yaml'
require 'bigdecimal'

class CalculadoraInss

  attr_reader :salario, :faixas_config

  def initialize(salario)
    s = salario.to_s
    # evita salário = nil
    # se 's' estiver vazio, é transformado em 0
    @salario = s.empty? ? BigDecimal('0') : BigDecimal(s)
    
    # trata o erro, trasnformando em BigDecimal
  rescue ArgumentError 
    @salario = BigDecimal('0')
  ensure
    # Garante que @faixas_config seja sempre inicializado
    @faixas_config = carregar_faixas_do_yaml
  end

  def self.calculate(salario)
    new(salario).calculate
  end

  def calculate

    # Cláusula de guarda - Retorna 0 se o salário for não positivo
    return BigDecimal('0') if @salario <= 0 || @faixas_config.empty?

    # Lógica cálculo progressivo
    inss_total = BigDecimal('0')
    limite_anterior = BigDecimal('0')

    # Teto contribuição
    teto_contribuicao_config = @faixas_config.last
    # Define o teto de contribuição com base na última faixa; usa o salário como fallback se não houver teto configurado.
    teto_contribuicao = teto_contribuicao_config ? teto_contribuicao_config[:limite_max] : @salario

    salario_calculo = [@salario, teto_contribuicao].min

    # Percorre as faixas em 'tabela_inss.yml' verificando onde o salário se encaixa
    @faixas_config.each do |faixa|
      # Interrompe se o salário já foi totalmente processado pelas faixas anteriores
      break if salario_calculo <= limite_anterior

      # Calcula a base de cálculo específica para esta faixa
      base_da_faixa = [salario_calculo, faixa[:limite_max]].min - limite_anterior
      
      # Calcula o INSS para esta porção do salário
      inss_da_faixa = base_da_faixa * faixa[:aliquota]
      inss_total += inss_da_faixa

      # Atualiza o limite_anterior para o teto da faixa atual, para a próxima iteração
      limite_anterior = faixa[:limite_max]
    end

    inss_total.round(2)
  end

  private

  def carregar_faixas_do_yaml
    caminho_arquivo = Rails.root.join('config', 'tabela_inss.yml')

    unless File.exist?(caminho_arquivo)
      Rails.logger.error " YAML NÃO ENCONTRADO EM: #{caminho_arquivo} "
      return [] 
    end

    configuracao = YAML.load_file(caminho_arquivo)
    
    # Mapeia os dados do YAML, convertendo para BigDecimal e garantindo que as chaves esperadas existam
    (configuracao['faixas_atuais'] || []).map do |dados_faixa|
      next unless dados_faixa && dados_faixa['limite_max'] && dados_faixa['aliquota']
      {
        limite_max: BigDecimal(dados_faixa['limite_max'].to_s),
        aliquota: BigDecimal(dados_faixa['aliquota'].to_s)
      }

    end.compact # Remove quaisquer 'nil' se alguma faixa no YAML estiver incompleta

  rescue Psych::SyntaxError => e # Trata erros de sintaxe no arquivo YAML
    Rails.logger.error "ERRO DE SINTAXE --- tabela_inss.yml: #{e.message}"
    return []
  rescue StandardError => e # Trata outros erros possíveis ao carregar/processar o YAML
    Rails.logger.error " ERRO AO CARREGAR TABELA INSS DO YAML: #{e.message} "
    return []
  end
end