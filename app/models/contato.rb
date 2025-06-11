# app/models/contato.rb
class Contato < ApplicationRecord
  belongs_to :proponente

  validates :tipo, presence: true
  validates :valor, presence: true
end