import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="context-menu"
export default class extends Controller {
  static values = {
    roomId: Number,
    ownerId: Number
  }

  connect() {
    this.menu = this.element.querySelector(".context-menu")

    this.element.addEventListener('contextmenu', (event)  => {
      event.preventDefault();
      this.open(event)
    })

    document.addEventListener("click", (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    })
  }

  open(event){
    document.querySelectorAll(".context-menu").forEach(menu => {
      menu.classList.add("hidden")
    })

    this.menu.classList.remove("hidden")
    this.menu.style.top = `${event.clientY}px`
    this.menu.style.left = `${event.clientX}px`
  }

  close(){
    this.menu.classList.add("hidden")
  }

  delete(){
    const currentUserMeta = document.querySelector('meta[name="current-user-id"]')
    const currentUserId = Number(currentUserMeta?.content)
    if (Number.isFinite(currentUserId) && this.hasOwnerIdValue && currentUserId !== this.ownerIdValue) {
      this.close()
      return
    }

    const messageId = this.element.id.replace("message_", "")

    fetch(`/rooms/${this.roomIdValue}/messages/${messageId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    }).then((response) => {
      if (response.status === 403) {
        this.close()
      }
    })

    this.close()
  }
}
