import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="contact-context-menu"
export default class extends Controller {
  connect() {
    this.menu = this.element.querySelector(".context-menu-contact")
    if (!this.menu) return

    this.longPressTimer = null
    this.longPressDelay = 450

    this.onContextMenu = (event) => {
      event.preventDefault()
      this.open(event)
    }

    this.onTouchStart = (event) => {
      clearTimeout(this.longPressTimer)
      const touch = event.touches && event.touches[0]
      this.lastTouchPoint = touch ? { x: touch.clientX, y: touch.clientY } : null
      this.longPressTimer = setTimeout(() => this.open(), this.longPressDelay)
    }

    this.onTouchEnd = () => {
      clearTimeout(this.longPressTimer)
    }

    this.onClickOutside = (event) => {
      if (!this.element.contains(event.target)) this.close()
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

  open(event = null) {
    if (!this.menu) return

    document.querySelectorAll(".context-menu-contact").forEach((menu) => {
      menu.classList.add("hidden")
    })

    this.menu.classList.remove("hidden")

    const x = event?.clientX ?? this.lastTouchPoint?.x
    const y = event?.clientY ?? this.lastTouchPoint?.y

    if (typeof x === "number" && typeof y === "number") {
      this.menu.style.left = `${Math.round(x)}px`
      this.menu.style.top = `${Math.round(y)}px`
      this.menu.style.right = "auto"
    }
  }

  close() {
    if (!this.menu) return
    this.menu.classList.add("hidden")
  }
}
