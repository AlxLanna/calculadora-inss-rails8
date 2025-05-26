class Proponente < ApplicationRecord
    # se um proponente for destruido, o endereço também é
    has_many :enderecos, dependent: :destroy
end
