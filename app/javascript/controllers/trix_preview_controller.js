import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-attachment-add", (event) => {
      const attachment = event.attachment

      if (attachment.file && attachment.file.type.startsWith("video/")) {
        event.preventDefault()

        this.openModal(attachment.file)
      }
    })

    document.getElementById("sendVideoBtn")?.addEventListener("click", () => {
      this.send()
    })
  }

  openModal(file) {
    this.file = file
    const url = URL.createObjectURL(file)

    const preview = document.getElementById("video-modal-preview")
    preview.innerHTML = `
      <video src="${url}" controls style="width:100%; height: auto; border-radius:10px;"></video>
    `

    const modal = new bootstrap.Modal(document.getElementById("videoModal"))

    modal.show()
  }

  send() {
    const form = document.getElementById("message_form")

    if (!form) return

    form.requestSubmit()

    this.clearModal()
  }

  clearModal() {
    const preview = document.getElementById("video-modal-preview")
    if (preview) preview.innerHTML = ""

    const modalEl = document.getElementById("videoModal")
    const modal = bootstrap.Modal.getInstance(modalEl)
    modal?.hide()
  }
}