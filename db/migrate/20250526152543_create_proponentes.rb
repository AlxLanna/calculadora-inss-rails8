class CreateProponentes < ActiveRecord::Migration[8.0]
  def change
    create_table :proponentes do |t|
      t.string :nome
      t.string :documentos
      t.date :data_nascimento
      t.decimal :salario
      t.decimal :desconto_inss

      t.timestamps
    end
  end
end
