import { Controller } from "@hotwired/stimulus"

// data-controller="modal"
export default class extends Controller {
  connect() {
    this.modal = new window.bootstrap.Modal(this.element)

    this.onFrameLoad = (event) => {
      if (event.target.id !== "modal") return

      if (event.target.innerHTML.trim() === "") return

      this.modal.show()
    }

    document.addEventListener("turbo:frame-load", this.onFrameLoad)

    this.onHidden = () => {
      const frame = document.getElementById("modal")
      if (frame) frame.innerHTML = ""
    }

    this.element.addEventListener("hidden.bs.modal", this.onHidden)
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.onFrameLoad)
    this.element.removeEventListener("hidden.bs.modal", this.onHidden)
    this.modal?.dispose()
  }
}
