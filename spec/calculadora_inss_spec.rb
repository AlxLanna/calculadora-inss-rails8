# spec/services/calculadora_inss_spec.rb
require 'rails_helper'

RSpec.describe CalculadoraInss, type: :service do
  # Faixas salariais para referência nos testes
  # Estas devem ser as mesmas do seu config/tabela_inss.yml
  let(:faixas_inss) {
    [
      { 'limite_max' => 1412.00, 'aliquota' => 0.075 },
      { 'limite_max' => 2666.68, 'aliquota' => 0.09 },
      { 'limite_max' => 4000.03, 'aliquota' => 0.12 },
      { 'limite_max' => 7786.02, 'aliquota' => 0.14 }
    ]
  }

  # Mocka o carregamento do YAML para garantir que os testes usem as faixas esperadas
  before do
    allow(YAML).to receive(:load_file).and_return({ 'faixas_atuais' => faixas_inss })
  end

  describe '#calculate' do
    context 'para salários dentro das faixas definidas' do
      it 'calcula corretamente para salário na primeira faixa' do
        salario = 1000.00
        expect(CalculadoraInss.calculate(salario)).to eq(75.00) # 1000 * 0.075
      end

      it 'calcula corretamente para salário no limite da primeira faixa' do
        salario = 1412.00
        expect(CalculadoraInss.calculate(salario)).to eq(105.90) # 1412.00 * 0.075
      end

      it 'calcula corretamente para salário na segunda faixa' do
        salario = 2000.00
        # 1412.00 * 0.075 (faixa 1) = 105.90
        # (2000 - 1412.00) * 0.09 (faixa 2) = 588 * 0.09 = 52.92
        # Total = 105.90 + 52.92 = 158.82
        expect(CalculadoraInss.calculate(salario)).to eq(158.82)
      end

      it 'calcula corretamente para salário na terceira faixa' do
        salario = 3000.00
        # 1412.00 * 0.075 = 105.90
        # (2666.68 - 1412.00) * 0.09 = 1254.68 * 0.09 = 112.92
        # (3000.00 - 2666.68) * 0.12 = 333.32 * 0.12 = 39.9984
        # Total = 105.90 + 112.92 + 39.9984 = 258.8184 => 258.82
        expect(CalculadoraInss.calculate(salario)).to eq(258.82)
      end

      it 'calcula corretamente para salário no teto da última faixa' do
        salario = 7786.02
        # 1412.00 * 0.075 = 105.90
        # (2666.68 - 1412.00) * 0.09 = 112.92
        # (4000.03 - 2666.68) * 0.12 = 1333.35 * 0.12 = 160.002
        # (7786.02 - 4000.03) * 0.14 = 3785.99 * 0.14 = 530.0386
        # Total = 105.90 + 112.92 + 160.00 + 530.04 = 908.86 (aproximadamente, ajustar conforme precisão)
        expect(CalculadoraInss.calculate(salario)).to eq(908.86) # Ajustar para o valor exato da sua CalculadoraInss.
      end
    end

    context 'para salários fora das faixas definidas' do
      it 'retorna 0 para salário negativo' do
        salario = -100.00
        expect(CalculadoraInss.calculate(salario)).to eq(0.00)
      end

      it 'retorna 0 para salário zero' do
        salario = 0.00
        expect(CalculadoraInss.calculate(salario)).to eq(0.00)
      end

      it 'retorna 0 para salário nulo' do
        salario = nil
        expect(CalculadoraInss.calculate(salario)).to eq(0.00)
      end

      it 'calcula corretamente para salário acima do teto da contribuição' do
        salario = 10000.00
        # O cálculo deve parar no teto de 7786.02
        # Use o valor exato calculado para 7786.02 (908.86)
        expect(CalculadoraInss.calculate(salario)).to eq(908.86)
      end
    end
  end
end
