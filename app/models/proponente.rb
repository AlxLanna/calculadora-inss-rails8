class Proponente < ApplicationRecord
    # se um proponente for destruido, endereço e contato também são
    has_many :enderecos, dependent: :destroy
    has_many :contatos, dependent: :destroy
end
