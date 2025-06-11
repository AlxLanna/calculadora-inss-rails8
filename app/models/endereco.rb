# app/models/endereco.rb
class Endereco < ApplicationRecord
  belongs_to :proponente

  validates :logradouro, presence: true
  validates :numero, presence: true
  validates :bairro, presence: true
  validates :cidade, presence: true
  validates :estado, presence: true
  validates :cep, presence: true
end