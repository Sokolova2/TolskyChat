import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="room-context-menu"
export default class extends Controller {
  static values = {
    roomId: Number
  }

  connect() {
    this.menu = this.element.querySelector(".room-context-menu")
    if (!this.menu) return

    this.longPressTimer = null
    this.longPressDelay = 450

    this.onContextMenu = (event) => {
      event.preventDefault()
      this.open()
    }

    this.onTouchStart = () => {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = setTimeout(() => this.open(), this.longPressDelay)
    }

    this.onTouchEnd = () => {
      clearTimeout(this.longPressTimer)
    }

    this.onClickOutside = (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    }

    this.element.addEventListener("contextmenu", this.onContextMenu)
    this.element.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.element.addEventListener("touchend", this.onTouchEnd, { passive: true })
    this.element.addEventListener("touchcancel", this.onTouchEnd, { passive: true })
    document.addEventListener("click", this.onClickOutside)
  }

  disconnect() {
    clearTimeout(this.longPressTimer)
    if (!this.menu) return

    this.element.removeEventListener("contextmenu", this.onContextMenu)
    this.element.removeEventListener("touchstart", this.onTouchStart)
    this.element.removeEventListener("touchend", this.onTouchEnd)
    this.element.removeEventListener("touchcancel", this.onTouchEnd)
    document.removeEventListener("click", this.onClickOutside)
  }

  open() {
    document.querySelectorAll(".room-context-menu").forEach(menu => {
      menu.classList.add("hidden")
    })

    this.menu.classList.remove("hidden")

    const isMobile = window.matchMedia("(max-width: 991.98px)").matches

    if (isMobile) {
      this.menu.style.top = "96px"
      this.menu.style.right = "16px"
      this.menu.style.left = "auto"
      return
    }

    const modalBody = this.element.closest(".modal-body")
    if (modalBody) {
      const rect = modalBody.getBoundingClientRect()
      this.menu.style.top = `${Math.round(rect.top + 16)}px`
      this.menu.style.left = `${Math.round(rect.right - 176)}px`
      this.menu.style.right = "auto"
      return
    }

    const sidebar = document.querySelector(".rooms-sidebar") || document.querySelector(".conversations-block")
    if (sidebar) {
      const rect = sidebar.getBoundingClientRect()
      this.menu.style.top = `${Math.round(rect.top + 72)}px`
      this.menu.style.left = `${Math.round(rect.right - 176)}px`
      this.menu.style.right = "auto"
      return
    }

    this.menu.style.top = "96px"
    this.menu.style.right = "16px"
    this.menu.style.left = "auto"
  }

  close(){
    this.menu.classList.add("hidden")
  }
}
