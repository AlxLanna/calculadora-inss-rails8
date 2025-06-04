// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus debug logs (opcional, mas útil)
application.debug = true // Mantenha true enquanto depura

export { application } // Exporta a instância para ser usada pelo index.js