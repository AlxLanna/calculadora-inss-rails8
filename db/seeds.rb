# db/seeds.rb

puts "Destruindo proponentes existentes..."
Proponente.destroy_all

puts "Criando proponentes com dados fictícios..."

15.times do |i| # Criar 15 proponentes para ter mais dados para a dashboard/paginação
  salario_base = Faker::Number.between(from: 1000.00, to: 8000.00).round(2)
  desconto = CalculadoraInss.calculate(salario_base) # Use seu service para o cálculo

  proponente = Proponente.create!(
    nome: Faker::Name.name,
    documentos: Faker::IDNumber.brazilian_citizen_number, # CPF fictício
    data_nascimento: Faker::Date.birthday(min_age: 18, max_age: 65),
    salario: salario_base,
    desconto_inss: desconto
  )

  # Adiciona entre 1 e 3 endereços para cada proponente
  Faker::Number.between(from: 1, to: 3).times do
    proponente.enderecos.create!(
      logradouro: Faker::Address.street_name,
      numero: Faker::Address.building_number,
      bairro: Faker::Address.community,
      cidade: Faker::Address.city,
      estado: Faker::Address.state_abbr,
      cep: Faker::Address.zip_code
    )
  end

  # Adiciona entre 1 e 3 contatos para cada proponente
  Faker::Number.between(from: 1, to: 3).times do
    tipo_contato = [ 'telefone_residencial', 'celular', 'email' ].sample
    valor_contato = case tipo_contato
    when 'email' then Faker::Internet.email
    when 'celular' then Faker::PhoneNumber.cell_phone_with_country_code
    else Faker::PhoneNumber.phone_number
    end

    proponente.contatos.create!(
      tipo: tipo_contato,
      valor: valor_contato
    )
  end

  puts "Proponente '#{proponente.nome}' (Salário: R$#{'%.2f' % salario_base}, INSS: R$#{'%.2f' % desconto}) criado."
end

puts "Total de #{Proponente.count} proponentes criados."
