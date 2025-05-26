# app/services/inss_calculator_service.rb
class CalculadoraInss

  # Faixas e alíquotas com valores constantes
  # Se necessário escalonar, armazene em um arquivo YAML
  FAIXAS = [  
    { limite_max: BigDecimal('1412.00'), aliquota: BigDecimal('0.075') }, 
    { limite_max: BigDecimal('2666.68'), aliquota: BigDecimal('0.09') },
    { limite_max: BigDecimal('4000.03'), aliquota: BigDecimal('0.12') },
    { limite_max: BigDecimal('7786.02'), aliquota: BigDecimal('0.14') }
  ].freeze

  attr_reader :salario

  def initialize(salario)
    s = salario.to_s
    # evita salário = nil
    # se 's' estiver vazio, é transformado em 0
    @salario = s.empty? ? BigDecimal('0') : BigDecimal(s)
    
    # trata o erro, trasnformando em BigDecimal
  rescue ArgumentError 
    @salario = BigDecimal('0')
  end

  def self.calculate(salario)
    new(salario).calculate
  end

  def calculate
    # Lógica cálculo progressivo
    inss_total = BigDecimal('0')
    limite_anterior = BigDecimal('0')

    # Teto contribuição
    teto_contribuicao = FAIXAS.last[:limite_max]
    salario_calculo = [@salario, teto_contribuicao].min

    # Percorre FAIXAS verificando onde o salário se encaixa
    FAIXAS.each do |faixa|
      # Verifica se o salário sendo calculado ultrapassa o limite anterior da faixa
      if salario_calculo > limite_anterior
        # Se o salário for maior que o limite máximo da faixa, usa o limite máximo da faixa.
        # Senão, usa o próprio salário.
        base_calculo_faixa = [salario_calculo, faixa[:limite_max]].min - limite_anterior

        # Calcula o INSS para faixa encontrada
        inss_faixa = base_calculo_faixa * faixa[:aliquota]
        inss_total += inss_faixa

        # Atualiza o limite anterior
        limite_anterior = faixa[:limite_max]

        # interrompe se excer o limite máximo da faixa
        break if salario_calculo <= faixa[:limite_max]
      else
        # Se o salário não alcança esta faixa, nada a fazer
        break
      end
    end

    # Arredondar para duas casas decimais
    inss_total.round(2)
  end
end