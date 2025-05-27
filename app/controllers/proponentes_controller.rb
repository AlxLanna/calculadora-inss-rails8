class ProponentesController < ApplicationController
  def index
  end

  def show
    @proponente = Proponente.find(params[:id])
  end

  def new
    @proponente = Proponente.new
    # Pré-construir um endereço e um contato para o formulário
    @proponente.enderecos.build
    @proponente.contatos.build
  end

  def create
    @proponente = Proponente.new(proponente_params)

    if @proponente.save
      redirect_to @proponente, notice: "Proponente criado com sucesso!"
    else
      # Se a validação falhar, os objetos aninhados com erros serão mantidos
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @proponente = Proponente.find(params[:id])
    # Garante que sempre haja pelo menos um campo vazio
    # para adicionar novo endereço ou contato ao editar
    @proponente.enderecos.build if @proponente.enderecos.empty?
    @proponente.contatos.build if @proponente.contatos.empty?
  end

  def update
    @proponente = Proponente.find(params[:id])

    if @proponente.update(proponente_params)
      redirect_to @proponente, notice: "Proponente atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def proponente_params
    params.require(:proponente).permit(
      :nome,
      :documentos,
      :data_nascimento,
      :salario,
      :desconto_inss, # Este valor será retornado e gravado
      enderecos_attributes: [
        :id,
        :logradouro,
        :numero,
        :bairro,
        :cidade,
        :estado,
        :cep,
        :_destroy
      ],
      contatos_attributes: [
        :id,
        :tipo,
        :valor,
        :_destroy
      ]
    )
  end
end
