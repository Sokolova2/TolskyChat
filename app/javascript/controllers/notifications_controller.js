import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
export default class extends Controller {
  connect() {
    this.startAutoRefresh()
  }

  startAutoRefresh() {
    this.wasOpen = false

    const modal = document.getElementById("messagesModal")

    if(!modal) return

    modal.addEventListener("show.bs.modal", () => {
      this.wasOpen = true
    })

    modal.addEventListener("hidden.bs.modal", () => {
      if(this.wasOpen){
        location.reload()
      }
    })
  }

  disconnect() {
    clearInterval(this.interval)
  }
}
