import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-attachment-add", (event) => {
      const file = event.attachment.file
      if (!file) return

      if (file.type.startsWith("video/")) {
        event.preventDefault()
        this.openVideoModal(file)
      }

      if (file.type.startsWith("audio/")) {
        event.preventDefault()
        this.openAudioModal(file)
      }
    })

    document.getElementById("sendVideoBtn")?.addEventListener("click", () => {
      this.send()
    })

    document.getElementById("sendAudioBtn")?.addEventListener("click", () => {
      this.send()
    })
  }

  openVideoModal(file) {
    this.file = file
    const url = URL.createObjectURL(file)

    const preview = document.getElementById("video-modal-preview")
    preview.innerHTML = `
      <video src="${url}" controls style="width:100%; height: auto; border-radius:10px;"></video>
    `

    const modal = new bootstrap.Modal(document.getElementById("videoModal"))

    modal.show()
  }

  openAudioModal(file) {
    this.file = file
    const url = URL.createObjectURL(file)

    const preview = document.getElementById("audio-modal-preview")

    preview.innerHTML = `
    <div style="display:flex; flex-direction:column; gap:10px;">
      <p style="margin:0;"><strong>${file.name}</strong></p>

      <audio controls style="width:100%;">
        <source src="${url}" type="${file.type}">
      </audio>
    </div>
  `

    new bootstrap.Modal(document.getElementById("audioModal")).show()
  }

  send() {
    const form = document.getElementById("message_form")

    if (!form) return

    form.requestSubmit()

    this.clearModal()
  }

  clearModal() {
    document.getElementById("video-modal-preview").innerHTML = ""
    document.getElementById("audio-modal-preview").innerHTML = ""
    const videoModal = bootstrap.Modal.getInstance(document.getElementById("videoModal"))
    videoModal?.hide()

    const audioModal = bootstrap.Modal.getInstance(document.getElementById("audioModal"))
    audioModal?.hide()
  }
}