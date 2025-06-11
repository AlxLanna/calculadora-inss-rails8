class Proponente < ApplicationRecord
    # Se um proponente for destruido, endereço e contato também são
    has_many :enderecos, dependent: :destroy
    has_many :contatos, dependent: :destroy

    # Permite que o formulário de Proponente crie/atualize Enderecos associados,
    # impede a criação de um endereço se todos os seus campos estiverem vazios e
    # permite que endereços sejam removidos através do formulário.
    accepts_nested_attributes_for :enderecos, reject_if: :all_blank, allow_destroy: true

    # Permite que o formulário de Proponente crie/atualize Contatos associados.
    accepts_nested_attributes_for :contatos, reject_if: :all_blank, allow_destroy: true

    # Campos obrigatórios
    validates :nome, presence: true
    validates :documentos, presence: true
    validates :data_nascimento, presence: true
    validates :salario, presence: true, numericality: { greater_than: 0 }

    validates_associated :enderecos, message: "deve ter ao menos um endereço válido"
    validates_associated :contatos, message: "deve ter ao menos um contato válido"
end
