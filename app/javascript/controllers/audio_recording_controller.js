import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-recording"
export default class extends Controller {

  static targets = [
    "startRecording",
    "stopRecording",
    "pauseRecording",
    "resumeRecording",
    "audio",
    "timeElapsed",
    "controls"
  ]

  static values = {
    roomId: Number
  }

  connect() {
    this.chunks = []
    this.secondsElapsed = 0
    this.timer = null
    this.mediaRecorder = null
    this.stream = null

    setTimeout(() => {
      this.addMicButton()
    }, 0)
  }

  async startRecording(e){
    e.preventDefault()

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.chunks = []
      this.mediaRecorder = new MediaRecorder(this.stream)

      this.mediaRecorder.ondataavailable = (e) => {
        this.chunks.push(e.data)
      }

      this.mediaRecorder.onstop = () => {
        console.log("STOP FIRED")
        const blob = new Blob(this.chunks, { type: "audio/webm" })
        console.log(blob)
        this.upload(blob)
      }

      this.mediaRecorder.start()
      this.startTimer()

      console.log("BEFORE:", this.controlsTarget.classList)
      this.controlsTarget.classList.remove("d-none")
      console.log("AFTER:", this.controlsTarget.classList)
      this.controlsTarget.style.display = "flex"

      this.startRecordingTarget.disabled = true
      this.stopRecordingTarget.disabled = false
      this.pauseRecordingTarget.disabled = false

    } catch(e){
      alert("Allow access to the microphone")
      console.error(e)
    }
  }

  pauseRecording(event) {
    event.preventDefault()

    if (!this.mediaRecorder) return
    if (this.mediaRecorder.state !== "recording") return

    this.mediaRecorder.pause()
    this.stopTimer()
  }

  resumeRecording(event){
    event.preventDefault()
    if (this.mediaRecorder && this.mediaRecorder.state === "paused"){
      this.mediaRecorder.resume()
      this.startTimer()
    }
  }

  stopRecording(event){
    event.preventDefault()

    if(!this.mediaRecorder) return

    this.mediaRecorder.stop()
    this.stream.getTracks().forEach((track => track.stop()))

    this.stopTimer()

    this.secondsElapsed = 0
    this.updateTimer()

    this.startRecordingTarget.disabled = false
    this.stopRecordingTarget.disabled = true
    this.pauseRecordingTarget.disabled = true
    this.resumeRecordingTarget.disabled = true

    this.controlsTarget.classList.add("d-none")

    this.controlsTarget.style.display = "none"
    if (this.micButton) {
      this.micButton.innerHTML = "🎙️"
    }
  }

  upload(blob){
    const formData = new FormData()
    formData.append("message[audio_file]", blob, "voice.webm")

    const token = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/rooms/${this.roomIdValue}/messages`, {
      method: "POST",
      body: formData,
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token
      },
      credentials: "same-origin"
    })
  }

  startTimer(){
    this.timer = setInterval(() => {
      this.secondsElapsed++
      this.updateTimer()
    }, 1000)
  }

  stopTimer(){
    clearInterval(this.timer)
  }

  formatTime(seconds){
    const h = String(Math.floor(seconds / 3600)).padStart(2, "0")
    const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, "0")
    const s = String(seconds % 60).padStart(2, "0")

    return `${h}: ${m}: ${s}`
  }

  updateTimer() {
    this.timeElapsedTarget.textContent =
        `Time: ${this.formatTime(this.secondsElapsed)}`
  }

  addMicButton() {
    const toolbar = this.element.parentElement.querySelector("trix-toolbar")
    if (!toolbar) return

    const group = toolbar.querySelector(".trix-button-group--text-tools")
    if (!group) return

    if (group.querySelector(".mic-button")) return

    const button = document.createElement("button")
    button.type = "button"
    button.classList.add("trix-button")
    button.innerHTML = "<i class=\"bi bi-mic fs-5\"></i>"

    this.micButton = button

    button.addEventListener("click", (e) => {
      e.preventDefault()
      button.innerHTML = "🔴 recording..."
      this.startRecording(e)
    })

    group.appendChild(button)
  }
}
