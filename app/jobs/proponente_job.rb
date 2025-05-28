# app/jobs/proponente_job.rb

class ProponenteJob < ApplicationJob
  queue_as :default

  def perform(proponente_params)
    # proponente_params um hash comum do Ruby, de acordo com o método enfileirar_proponente
    # em proponentes_controller.rb
    # 'id' indica se é uma criação ou atualização.
    proponente_id = proponente_params["id"]

    if proponente_id.present?
      # É uma atualização
      proponente = Proponente.find_by(id: proponente_id)
      if proponente
        # Remover 'id' do hash para evitar erros de mass assignment ao atualizar
        proponente_params.delete("id")

        if proponente.update(proponente_params)
          Rails.logger.info "Proponente #{proponente.id} atualizado com sucesso em background."
        else # log no terminal
          Rails.logger.error "Falha ao atualizar proponente #{proponente.id} em background: #{proponente.errors.full_messages.to_sentence}" 

          # Em um ambiente de produção, aqui seria o local para:
          # - Notificar um administrador (ex: via email ou sistema de alertas)
          # - Registrar o erro em um sistema de monitoramento de erros (ex: Sentry, Rollbar)
          # - Ou, para falhas transitórias, enfileirar um job de retentativa (com um limite para evitar loops infinitos).
        
        end
      else
        Rails.logger.error "Proponente com ID #{proponente_id} não encontrado para atualização em background."
      end
    else
      # É um novo proponente
      proponente = Proponente.new(proponente_params)
      if proponente.save
        Rails.logger.info "Novo proponente #{proponente.id} criado com sucesso em background."
      else
        Rails.logger.error "Falha ao criar novo proponente em background: #{proponente.errors.full_messages.to_sentence}"
        # Lógica para lidar com falhas de validação na criação
      end
    end

  rescue => e
    Rails.logger.error "Erro inesperado no ProponenteJob: #{e.message} com params: #{proponente_params}"
    # Lógica para lidar com exceções gerais
  end
end
