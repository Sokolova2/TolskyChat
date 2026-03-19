import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trix-custom"
export default class extends Controller {
  connect() {
      const editor = this.element.querySelector("trix-editor")
      const input = document.getElementById("file_input")

      if (!editor || !input) return

      editor.addEventListener("trix-file-accept", (e) => {
          e.preventDefault()
      })

      this.element.addEventListener("click", (e) => {
          const button = e.target.closest(
              'button[data-trix-action="attachFiles"]'
          )

          if (!button) return

          e.preventDefault()
          e.stopPropagation()

          input.click()
      })
  }
}

