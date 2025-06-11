// app/javascript/controllers/index.js
import { application } from "controllers/application" 

// Importa e registra todos os controllers da pasta atual (e subpastas)
// que são nomeados com o sufixo _controller.js
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)