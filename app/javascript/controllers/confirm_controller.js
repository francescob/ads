import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }

  confirm(event) {
    if (!window.confirm(this.messageValue || "Sei sicuro?")) {
      event.preventDefault()
    }
  }
}