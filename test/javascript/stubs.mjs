import { registerHooks } from "node:module"

registerHooks({
  resolve(specifier, context, next) {
    if (specifier === "@hotwired/stimulus") return { url: "stub:stimulus", shortCircuit: true }
    return next(specifier, context)
  },
  load(url, context, next) {
    if (url === "stub:stimulus") return { format: "module", source: "export class Controller {}", shortCircuit: true }
    return next(url, context)
  }
})
