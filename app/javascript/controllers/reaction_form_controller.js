import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reaction-form"
export default class extends Controller {
  connect() {
    const editor = this.element.querySelector("trix-editor")
    this.form = document.getElementById("message_form")

    if (!editor || !this.form) return

    this.onSubmit = this.handleSubmit.bind(this)
    this.form.addEventListener("submit", this.onSubmit)

    editor.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey){
        e.preventDefault()
        this.form.requestSubmit()
      }
    })
  }

  disconnect() {
    if (this.form && this.onSubmit) {
      this.form.removeEventListener("submit", this.onSubmit)
    }
  }

  async handleSubmit(event) {
    event.preventDefault()

    if (!this.form) return

    const formData = new FormData(this.form)
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    await fetch(this.form.action, {
      method: "POST",
      body: formData,
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token
      },
      credentials: "same-origin"
    })
  }
}
