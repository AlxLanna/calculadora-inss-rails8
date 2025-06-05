// app/javascript/controllers/proponente_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define os "targets" que o controller vai interagir no HTML
  static targets = [
    "salarioInput",
    "inssDescontoExibicao",
    "inssDescontoHidden",
    "enderecosFields",
    "contatosFields"
  ]

  // Conecta o controller quando o elemento data-controller="proponente-form" é carregado
  connect() {
    console.log("ProponenteFormController conectado!");
    this.debounceTimeout = null; // Para o debounce do cálculo do INSS
    // Templates serão carregados do HTML na primeira vez
    this.templateEndereco = null;
    this.templateContato = null;

    // Atualiza o desconto INSS ao carregar a página se o salário já estiver preenchido
    this.calcularInss();
  }

  // 1. Método para calcular o INSS assincronamente
  calcularInss() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout);
    }

    this.debounceTimeout = setTimeout(() => {
      const salarioBruto = parseFloat(this.salarioInputTarget.value);

      if (isNaN(salarioBruto) || salarioBruto <= 0) {
        this.inssDescontoExibicaoTarget.textContent = "Desconto INSS: R$ 0,00";
        this.inssDescontoHiddenTarget.value = "0.00"; // Usar string para consistência
        return;
      }

      // Faz a requisição para o endpoint do Rails
      fetch(`/proponentes/calcular_inss?salario=${salarioBruto}`)
        .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.json();
        })
        .then(data => {
          const desconto = parseFloat(data.desconto_inss) || 0;
          this.inssDescontoExibicaoTarget.textContent = `Desconto INSS: R$ ${desconto.toFixed(2).replace('.', ',')}`;
          this.inssDescontoHiddenTarget.value = desconto.toFixed(2); // Preenche o campo oculto com 2 casas decimais
        })
        .catch(error => {
          console.error("Erro ao calcular INSS:", error);
          this.inssDescontoExibicaoTarget.textContent = "Desconto INSS: Erro no cálculo";
          this.inssDescontoHiddenTarget.value = "sem valor definido";
        });
    }, 500); // Debounce de 500ms para não disparar muitas requisições
  }

  // 2. Método para adicionar dinamicamente campos de Endereço
  addEndereco(event) {
    event.preventDefault();
    if (!this.templateEndereco) {
      this.templateEndereco = this.getNestedFormTemplate("enderecos");
    }
    this.addNestedFields(this.enderecosFieldsTarget, this.templateEndereco, 'enderecos');
  }

  // 3. Método para adicionar dinamicamente campos de Contato
  addContato(event) {
    event.preventDefault();
    if (!this.templateContato) {
      this.templateContato = this.getNestedFormTemplate("contatos");
    }
    this.addNestedFields(this.contatosFieldsTarget, this.templateContato, 'contatos');
  }

  addNestedFields(targetContainer, template, association) {
    if (!template) {
      console.error(`Template para ${association} não encontrado! Verifique o HTML.`);
      return;
    }

    const newId = new Date().getTime(); // Gera um ID único para os novos campos
    // Substitui o placeholder NEW_RECORD pelo ID único
    const newContent = template.replace(new RegExp(`${association}\\[NEW_RECORD\\]`, 'g'), `${association}[${newId}]`)
                             .replace(/NEW_RECORD/g, newId)
    ;


    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = newContent.trim();
    const newField = tempDiv.firstElementChild; // Pega o primeiro elemento gerado

    if (!newField) {
      console.error(`Falha ao criar novo campo para ${association}. newField é nulo ou indefinido. Conteúdo HTML:`, newContent);
      return;
    }

    // Adiciona classes para o novo campo e um botão de remover
    newField.classList.add('newly-added-field');
    newField.style.opacity = '0'; // Começa invisível para fade-in

    const removeButton = document.createElement('button');
    removeButton.type = 'button';
    removeButton.className = 'btn btn-outline-danger btn-sm mt-2';
    removeButton.textContent = 'Remover este item';
    removeButton.dataset.action = 'click->proponente-form#removeNestedField'; // Adiciona data-action para remover
    newField.appendChild(removeButton);

    targetContainer.appendChild(newField);

    // Animação simples de fade-in
    setTimeout(() => { newField.style.opacity = '1'; }, 10);
  }


  // 4. Método para remover campos aninhados
  removeNestedField(event) {
    event.preventDefault();
    const field = event.target.closest('.nested-fields'); // Encontra o container do campo
    if (field) {
      const destroyField = field.querySelector('input[type="hidden"][name$="[_destroy]"]'); // Campo hidden _destroy
      if (destroyField) {
        destroyField.value = '1'; // Marca o campo _destroy como true
        field.style.display = 'none'; // Esconde o campo
      } else {
        // Se não houver campo _destroy (novo campo não salvo), apenas remove
        field.remove();
      }
    }
  }

  // Método auxiliar para obter o template HTML de um campo aninhado
  getNestedFormTemplate(association) {
    const templateElement = document.getElementById(`${association}_template`);
    if (templateElement) {
      return templateElement.innerHTML;
    } else {
      console.error(`Elemento <template id="${association}_template"> não encontrado no HTML!`);
      return '';
    }
  }


  // 5. Método para submeter o formulário via AJAX para o Job
  submitForm(event) {
    event.preventDefault(); // Impede a submissão padrão do formulário

    const form = event.target.closest('form');
    const formData = new FormData(form);

    // Remova os campos marcados para destruição da formData
    // para evitar que sejam enviados com valor '1' se já foram hidden
    form.querySelectorAll('.nested-fields input[name$="[_destroy]"]').forEach(input => {
      if (input.type === 'hidden' && input.value === '1') {
        const fieldContainer = input.closest('.nested-fields');
        // Remove todos os campos filhos do container que está sendo destruído
        fieldContainer.querySelectorAll('input, select, textarea').forEach(field => {
          formData.delete(field.name);
        });
      }
    });


    // Garante que o método HTTP é POST para o endpoint do job
    // O `form.action` seria a rota do proponente, precisamos ajustar para a rota de enfileirar.
    // A rota de enfileirar é /proponentes/enfileirar_proponente
    const enfileirarUrl = `/proponentes/enfileirar_proponente`;

    // Desabilita o botão de submit para evitar múltiplos cliques
    this.element.querySelector('input[type="submit"]').disabled = true;
    this.element.querySelector('input[type="submit"]').value = "Processando...";


    fetch(enfileirarUrl, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content // Para segurança do Rails
      },
      body: formData
    })
    .then(response => {
      // A API de enfileiramento pode retornar sucesso ou erro, mas não necessariamente JSON do objeto salvo
      if (!response.ok) {
        return response.json().then(errorData => { throw new Error(errorData.error || 'Erro desconhecido'); });
      }
      return response.json(); // Se o backend retornar JSON de sucesso
    })
    .then(data => {
      console.log("Resposta do Job Enfileirado:", data);
      alert("Proponente enviado para processamento em segundo plano!");
      // Redireciona para a listagem ou mostra uma mensagem de sucesso
      window.location.href = "/proponentes";
    })
    .catch(error => {
      console.error("Erro ao enfileirar proponente:", error);
      alert(`Ocorreu um erro ao enviar o proponente: ${error.message}. Tente novamente.`);
      // Reabilita o botão de submit em caso de erro
      this.element.querySelector('input[type="submit"]').disabled = false;
      this.element.querySelector('input[type="submit"]').value = "Salvar Proponente";
    });
  }
}