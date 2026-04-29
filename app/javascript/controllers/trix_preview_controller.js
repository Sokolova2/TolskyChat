import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-attachment-add", (event) => {
      const file = event.attachment.file
      if (!file) return

      event.preventDefault()

      this.file = file
      this.currentAttachment = event.attachment

      if (file.type.startsWith("video/")) {
        this.openVideoModal(file)
      } else if (file.type.startsWith("audio/")) {
        this.openAudioModal(file)
      } else {
        this.openFileModal(file)
      }
    })

    document.getElementById("sendVideoBtn")?.addEventListener("click", () => {
      this.send()
    })

    document.getElementById("sendAudioBtn")?.addEventListener("click", () => {
      this.send()
    })

    document.getElementById("sendFileBtn")?.addEventListener("click", () => {
      this.send()
    })

    document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(btn => {
      btn.addEventListener("click", () => {
        this.cancelAttachment()
      })
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

  openFileModal(file) {
    this.file = file
    const url = URL.createObjectURL(file)

    const preview = document.getElementById("file-modal-preview")

    let content = ""

    if (file.type === "application/pdf") {
      content = `
        <iframe src="${url}" style="width:100%; height:400px; border:none; border-radius:10px;"></iframe>
      `
    }

    else if (file.type.startsWith("image/")) {
      content = `
      <img src="${url}" style="max-width:100%; border-radius:10px;" />
    `
    }

    else if (file.type.startsWith("text/")) {
      content = `<p>Text file preview not implemented</p>`
    }

    else {
      content = `
      <div style="font-size:50px;">📄</div>
      <p>Preview not available</p>
    `
    }

    preview.innerHTML = `
      <div style="display:flex; flex-direction:column; gap:10px;">
        <p style="margin:0;"><strong>${file.name}</strong></p>
         ${content}
      </div>
    `

    new bootstrap.Modal(document.getElementById("fileModal")).show()
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
    document.getElementById("file-modal-preview").innerHTML = ""
    const videoModal = bootstrap.Modal.getInstance(document.getElementById("videoModal"))
    videoModal?.hide()

    const audioModal = bootstrap.Modal.getInstance(document.getElementById("audioModal"))
    audioModal?.hide()

    const fileModal = bootstrap.Modal.getInstance(document.getElementById("fileModal"))
    fileModal?.hide()
  }

  cancelAttachment() {
    if (this.currentAttachment) {
      this.currentAttachment.remove()
      this.currentAttachment = null
    }

    this.file = null
  }
}