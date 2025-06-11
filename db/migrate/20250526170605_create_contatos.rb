class CreateContatos < ActiveRecord::Migration[8.0]
  def change
    create_table :contatos do |t|
      t.string :tipo
      t.string :valor
      t.references :proponente, null: false, foreign_key: true

      t.timestamps
    end
  end
end
