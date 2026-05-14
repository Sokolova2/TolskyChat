import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="room-options"
export default class extends Controller {
  static targets = [
      "nameText",
      "nameForm",
      "nameInput",
      "privacyText",
      "privacyForm",
      "privacySelect",
      "roleText",
      "roleForm",
      "roleSelect"
  ]

  showPrivacyForm() {
    this.privacyTextTarget.classList.add("d-none")
    this.privacyFormTarget.classList.remove("d-none")
    this.privacySelectTarget.focus()
  }

  showNameForm() {
    this.nameTextTarget.classList.add("d-none")
    this.nameFormTarget.classList.remove("d-none")
    this.nameInputTarget.focus()
    this.nameInputTarget.select()
  }

  showRoleForm(event){
    const index = this.roleTextTargets.indexOf(event.currentTarget)
    if (index < 0) return
    if (!this.roleFormTargets[index] || !this.roleSelectTargets[index]) return

    this.roleTextTargets[index].classList.add("d-none")
    this.roleFormTargets[index].classList.remove("d-none")
    this.roleSelectTargets[index].focus()
  }

  hideNameForm() {
    this.nameFormTarget.classList.add("d-none")
    this.nameTextTarget.classList.remove("d-none")
  }

  hidePrivacyForm() {
    this.privacyFormTarget.classList.add("d-none")
    this.privacyTextTarget.classList.remove("d-none")
  }

  hideRoleForm(event){
    const index = this.roleSelectTargets.indexOf(event.currentTarget)
    if (index < 0) return

    this.roleFormTargets[index].classList.add("d-none")
    this.roleTextTargets[index].classList.remove("d-none")
  }

  submitPrivacy() {
    this.privacySelectTarget.form.requestSubmit()
  }

  submitRole(event) {
    event.currentTarget.form.requestSubmit()
  }

  onNameKeydown(event) {
    if (event.key === "Escape") {
      this.hideNameForm()
    }
  }

  onPrivacyKeydown(event) {
    if (event.key === "Escape") {
      this.hidePrivacyForm()
    }
  }

  onRoleKeydown(event) {
    if (event.key === "Escape") {
      this.hideRoleForm(event)
    }
  }
}
