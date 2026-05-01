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

  disconnect() {
    this.cleanupRecorder()
    this.resetRecordingUI()
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
        if (this.chunks.length > 0) {
          const blob = new Blob(this.chunks, { type: "audio/webm" })
          if (blob.size > 0) {
            this.upload(blob)
          } else {
            alert("Recording is empty. Please allow microphone access and try again.")
          }
        } else {
          alert("Recording failed. No audio data captured.")
        }
        this.cleanupRecorder()
        this.resetRecordingUI()
      }

      this.mediaRecorder.onerror = () => {
        this.cleanupRecorder()
        this.resetRecordingUI()
      }

      this.mediaRecorder.start()
      this.startTimer()
      if (this.hasControlsTarget) {
        this.controlsTarget.classList.remove("d-none")
        this.controlsTarget.style.display = "flex"
      }

      if (this.hasStartRecordingTarget) this.startRecordingTarget.disabled = true
      if (this.hasStopRecordingTarget) this.stopRecordingTarget.disabled = false
      if (this.hasPauseRecordingTarget) this.pauseRecordingTarget.disabled = false
      if (this.micButton) this.micButton.innerHTML = "🔴 recording..."

    } catch(e){
      this.cleanupRecorder()
      this.resetRecordingUI()
      const message = this.microphoneErrorMessage(e)
      alert(message)
      console.error("Microphone error:", e)
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

    if (!this.mediaRecorder) {
      this.cleanupRecorder()
      this.resetRecordingUI()
      return
    }

    if (this.mediaRecorder.state === "inactive") {
      this.cleanupRecorder()
      this.resetRecordingUI()
      return
    }

    this.mediaRecorder.stop()
  }

  upload(blob){
    if (!blob || blob.size === 0) {
      alert("Cannot send empty voice message.")
      return
    }

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
    this.timer = null
  }

  formatTime(seconds){
    const h = String(Math.floor(seconds / 3600)).padStart(2, "0")
    const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, "0")
    const s = String(seconds % 60).padStart(2, "0")

    return `${h}: ${m}: ${s}`
  }

  updateTimer() {
    if (!this.hasTimeElapsedTarget) return
    this.timeElapsedTarget.textContent = `Time: ${this.formatTime(this.secondsElapsed)}`
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
      this.startRecording(e)
    })

    group.appendChild(button)
  }

  cleanupRecorder() {
    if (this.stream) {
      this.stream.getTracks().forEach((track) => track.stop())
      this.stream = null
    }
    this.mediaRecorder = null
    this.chunks = []
    this.stopTimer()
  }

  resetRecordingUI() {
    this.secondsElapsed = 0
    this.updateTimer()

    if (this.hasControlsTarget) {
      this.controlsTarget.classList.add("d-none")
      this.controlsTarget.style.display = "none"
    }

    if (this.hasStartRecordingTarget) this.startRecordingTarget.disabled = false
    if (this.hasStopRecordingTarget) this.stopRecordingTarget.disabled = true
    if (this.hasPauseRecordingTarget) this.pauseRecordingTarget.disabled = true
    if (this.hasResumeRecordingTarget) this.resumeRecordingTarget.disabled = true

    if (this.micButton) this.micButton.innerHTML = "<i class=\"bi bi-mic fs-5\"></i>"
  }

  microphoneErrorMessage(error) {
    const name = error?.name
    if (name === "NotAllowedError") return "Microphone access denied. Allow microphone in browser site settings."
    if (name === "NotFoundError") return "No microphone found. Connect a microphone and try again."
    if (name === "NotReadableError") return "Microphone is busy or unavailable. Close other apps using mic and retry."
    if (name === "OverconstrainedError") return "Selected microphone constraints are not supported on this device."
    if (name === "SecurityError") return "Microphone is blocked by browser security policy."
    return "Unable to start recording. Check microphone permissions and device availability."
  }
}
