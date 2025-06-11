# app/jobs/proponente_job.rb

class ProponenteJob < ApplicationJob
  queue_as :default

  def perform(proponente_params)
    Rails.logger.info "ProponenteJob: Iniciando com params: #{proponente_params.inspect}"
    
    proponente_id = proponente_params["id"]
    Rails.logger.info "ProponenteJob: ID do Proponente (antes da verificação): #{proponente_id.inspect}, Tipo: #{proponente_id.class}"

    # FILTRAR ATRIBUTOS ANINHADOS VAZIOS AQUI
    # (Para garantir que reject_if: :all_blank funcione como esperado)
    cleaned_params = proponente_params.dup # Duplica para não modificar o hash original recebido
    
    if cleaned_params["enderecos_attributes"].present?
      cleaned_params["enderecos_attributes"] = cleaned_params["enderecos_attributes"].select do |_, attrs|
        attrs.values.any? { |val| val.present? && val != "0" } # Check if any value is present and not _destroy=0
      end
    end

    if cleaned_params["contatos_attributes"].present?
      cleaned_params["contatos_attributes"] = cleaned_params["contatos_attributes"].select do |_, attrs|
        attrs.values.any? { |val| val.present? && val != "0" } # Check if any value is present and not _destroy=0
      end
    end

    if proponente_id.present?
      Rails.logger.info "ProponenteJob: Modo de atualização para ID: #{proponente_id}"
      proponente = Proponente.find_by(id: proponente_id)

      if proponente
        if proponente.update(cleaned_params) # Use cleaned_params aqui
          Rails.logger.info "Proponente #{proponente.id} atualizado com sucesso em background."
        else
          Rails.logger.error "Falha ao atualizar proponente #{proponente.id} em background: #{proponente.errors.full_messages.to_sentence}"
        end
      else
        Rails.logger.error "Proponente com ID #{proponente_id} não encontrado para atualização em background."
      end
    else
      # É um novo proponente
      Rails.logger.info "ProponenteJob: Modo de criação."
      proponente = Proponente.new(cleaned_params) # Use cleaned_params aqui
      if proponente.save
        Rails.logger.info "Novo proponente #{proponente.id} criado com sucesso em background."
      else
        # Esta é a linha que deve logar o erro, se houver validação falhando no proponente principal.
        Rails.logger.error "Falha ao criar novo proponente em background: #{proponente.errors.full_messages.to_sentence}"
        # Se você ainda não vê erros aqui, significa que as validações aninhadas podem estar falhando silenciosamente,
        # ou que o reject_if no modelo não está funcionando como esperado para o new/update.
        # Precisamos de validações explicitas para endereços e contatos.
      end
    end

  rescue => e
    Rails.logger.error "Erro inesperado no ProponenteJob: #{e.message} com params: #{proponente_params}"
  end
end