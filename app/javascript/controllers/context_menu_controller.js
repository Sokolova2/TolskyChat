import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="context-menu"
export default class extends Controller {
  static values = {
    roomId: Number,
    ownerId: Number,
    text: String
  }

  connect() {
    this.menu = this.element.querySelector(".message-context-menu") ||
        document.querySelector(".message-context-menu")

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
    document.querySelectorAll(".message-context-menu").forEach(menu => {
      menu.classList.add("hidden")
    })

    this.menu.classList.remove("hidden")
    this.menu.style.top = `${event.clientY}px`
    this.menu.style.left = `${event.clientX}px`
  }

  close(){
    this.menu.classList.add("hidden")
  }

  async copy(){
    await navigator.clipboard.writeText(this.textValue)
    this.close()
  }

  async paste(){
    const text = await navigator.clipboard.readText()

    const editor = document.querySelector("trix-editor")

    if (editor) {
      editor.editor.insertString(text)
    }

    this.close()
  }
}
