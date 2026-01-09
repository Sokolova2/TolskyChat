import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reaction-form"
export default class extends Controller {
  connect() {
    const editor = this.element.querySelector("trix-editor")
    const form = document.getElementById("message_form")

    if (!editor || !form) return

    editor.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey){
        e.preventDefault()
        form.requestSubmit()
      }
    })
  }
}
