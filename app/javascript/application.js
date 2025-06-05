// app/javascript/application.js
import "controllers" // Isso carrega o app/javascript/controllers/index.js
// import "bootstrap"
import "chartkick"

// Se você estiver usando Turbo (geralmente sim com Stimulus)
import { Turbo } from "@hotwired/turbo-rails"
Turbo.start()

// Qualquer outro JavaScript global que você precise pode vir aqui
console.log("JavaScript principal (application.js) carregado."); // Log para confirmar