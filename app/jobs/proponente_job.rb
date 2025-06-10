# app/jobs/proponente_job.rb
class ProponenteJob < ApplicationJob
  queue_as :default

  def perform(proponente_params)
    
    Rails.logger.info "ProponenteJob: Iniciando com params: #{proponente_params.inspect}" # <-- NOVO LOG

    proponente_id = proponente_params["id"]
    Rails.logger.info "ProponenteJob: ID do Proponente (antes da verificação): #{proponente_id.inspect}, Tipo: #{proponente_id.class}"

    if proponente_id.present?
      Rails.logger.info "ProponenteJob: Modo de atualização para ID: #{proponente_id}" # <-- NOVO LOG
      proponente = Proponente.find_by(id: proponente_id)

      if proponente
        Rails.logger.info "ProponenteJob: Encontrado proponente: #{proponente.id}" # <-- NOVO LOG
        # Aqui, você pode inspecionar os atributos aninhados
        Rails.logger.info "ProponenteJob: Endereços a serem processados: #{proponente_params['enderecos_attributes'].inspect}" # <-- NOVO LOG
        Rails.logger.info "ProponenteJob: Contatos a serem processados: #{proponente_params['contatos_attributes'].inspect}" # <-- NOVO LOG

        if proponente.update(proponente_params)
          Rails.logger.info "Proponente #{proponente.id} atualizado com sucesso em background."
        else
          Rails.logger.error "Falha ao atualizar proponente #{proponente.id} em background: #{proponente.errors.full_messages.to_sentence}"
        end
      else
        Rails.logger.error "Proponente com ID #{proponente_id} não encontrado para atualização em background."
      end
    else
      # ... (criação) ...
      Rails.logger.info "ProponenteJob: Modo de criação." # <-- NOVO LOG
      proponente = Proponente.new(proponente_params)
    end

  rescue => e
    Rails.logger.error "Erro inesperado no ProponenteJob: #{e.message} com params: #{proponente_params}"
  end
end