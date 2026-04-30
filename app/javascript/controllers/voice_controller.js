import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer";

export default class extends Controller {
  static values = {
    currentUserId: Number,
    callerId: Number,
    otherUserId: Number,
    iceServers: String
  }

  static targets = ['status']

  connect() {
    if (this.hasConnected) return
    this.hasConnected = true

    this.resetState()
    this.initCable()

    this.isCaller = this.currentUserIdValue === this.callerIdValue

    this.inCall = localStorage.getItem("call_active") === "true"

    document.addEventListener("hidden.bs.modal", () => {
      document.activeElement?.blur()
    })

    document.addEventListener("hidden.bs.modal", (event) => {
      if (event.target.id === "activeCallModal" && this.inCall) {
        const btn = document.getElementById("returnToCall")
        if (btn) btn.classList.remove("d-none")
      }
    })

    const savedOffer = localStorage.getItem("pending_offer")
    if (savedOffer) {
      this.pendingOffer = JSON.parse(savedOffer)
      this.setStatus("📲 Incoming call (restored)")
    }

    if (this.inCall) {
      this.restoreUIOnly()
    }
  }

  disconnect() {
    this.destroyEverything()
  }

  resetState() {
    this.pendingOffer = null
    this.peer = null
    this.stream = null
    this.remoteAudio = null
    this.remoteVideo = null
    this.remoteStream = null
    this.localVideo = null
    this.iceQueue = []
    this.remoteReady = false
    this.inCall = false
    this.isMuted = false
    this.isVideoOff = false
    this.timer = null
    this.seconds = 0
    this.channel = null
    this.callInProgress = false
    this.activePeerId = null
  }

  destroyEverything() {
    this.cleanupWebRTC()
    this.resetUIAfterCall()

    if (this.channel) {
      this.channel.unsubscribe()
      this.channel = null
    }

    this.resetState()
  }

  cleanupWebRTC() {
    if (this.peer) {
      this.peer.close()
      this.peer = null
    }

    if (this.stream) {
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
    }

    this.remoteStream = null

    if (this.remoteAudio) {
      this.remoteAudio.pause()
      this.remoteAudio.srcObject = null
      this.remoteAudio.remove()
      this.remoteAudio = null
    }

    if (this.remoteVideo) {
      this.remoteVideo.pause()
      this.remoteVideo.srcObject = null
      this.remoteVideo.remove()
      this.remoteVideo = null
    }

    this.stopTimer()
  }

  resetUIAfterCall() {
    this.hideAllModals()
    this.setStatus("Idle")

    document.getElementById("returnToCall")?.classList.add("d-none")

    this.inCall = false

    localStorage.removeItem('call_active')
  }

  setStatus(text) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
    }
  }

  showModal(id) {
    const el = document.getElementById(id)
    if (!el) return
    bootstrap.Modal.getOrCreateInstance(el).show()
  }

  hideModal(id) {
    const el = document.getElementById(id)
    if (!el) return
    bootstrap.Modal.getOrCreateInstance(el).hide()
  }

  hideAllModals() {
    ["incomingCallModal", "outgoingCallModal", "activeCallModal"]
        .forEach(id => this.hideModal(id) )
  }

  initCable() {
    this.channel = consumer.subscriptions.create(
        { channel: 'VoiceChannel' },
        { received: (data) => this.handleSignal(data)}
    )
  }

  buildIceServers() {
    const fallback = [{ urls: "stun:stun.l.google.com:19302" }]

    if (!this.hasIceServersValue || !this.iceServersValue) return fallback

    try {
      const parsed = JSON.parse(this.iceServersValue)
      if (!Array.isArray(parsed) || parsed.length === 0) return fallback
      return parsed
    } catch (error) {
      console.warn("Invalid ICE config, fallback to STUN", error)
      return fallback
    }
  }

  async fetchDynamicIceServers() {
    try {
      const response = await fetch("/turn_credentials", {
        method: "GET",
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })

      if (!response.ok) return null

      const data = await response.json()
      if (!Array.isArray(data.ice_servers) || data.ice_servers.length === 0) return null
      return data.ice_servers
    } catch (error) {
      console.warn("Failed to fetch TURN credentials", error)
      return null
    }
  }

  async resolveIceServers() {
    const dynamicServers = await this.fetchDynamicIceServers()
    if (dynamicServers) return dynamicServers
    return this.buildIceServers()
  }

  async initPeer() {
    if (this.peer) return

    const iceServers = await this.resolveIceServers()

    this.peer = new RTCPeerConnection({
      iceServers
    })

    this.peer.onicecandidate = (e) => {
      if (e.candidate) {
        const receiverId = this.activePeerId || this.otherUserIdValue
        this.channel?.perform('signal', {
          receiver_id: receiverId,
          candidate: e.candidate,
          caller_id: this.currentUserIdValue
        })
      }
    }

    this.peer.ontrack = (e) => {
      const track = e.track

      if (track.kind === "audio") {
        if (!this.remoteAudio) {
          this.remoteAudio = document.createElement("audio")
          this.remoteAudio.autoplay = true
          document.body.appendChild(this.remoteAudio)
        }

        const audioStream = new MediaStream([track])
        this.remoteAudio.srcObject = audioStream
      }

      if (track.kind === "video") {
        const remoteVideo = document.getElementById("remoteVideo")
        const avatarFallback = document.getElementById("avatarFallback")

        if (!remoteVideo) return

        if (!this.remoteStream) {
          this.remoteStream = new MediaStream()
        }

        this.remoteStream.addTrack(track)

        remoteVideo.srcObject = null
        remoteVideo.srcObject = this.remoteStream
        remoteVideo.style.display = "block"

        if (avatarFallback) {
          avatarFallback.style.display = "none"
        }
      }

      this.setStatus("🔊 Connected")
      this.showModal("activeCallModal")
    }

    this.peer.onconnectionstatechange = () => {
      const state = this.peer.connectionState
      if (state === "connected") {
        this.setStatus("🟢 Connected")
        this.inCall = true
        localStorage.setItem('call_active', "true")
        this.startTimer()
      }

      if (["failed", "disconnected", "closed"].includes(state)) {
        this.forceReset()
      }
    }
  }

  async initMedia() {
    if (this.stream) return

    const audioStream = await navigator.mediaDevices.getUserMedia({
      audio: true
    })

    this.stream = new MediaStream(audioStream.getAudioTracks())

    try {
      const videoStream = await navigator.mediaDevices.getUserMedia({
        video: true
      })

      videoStream.getVideoTracks().forEach(track => {
        this.stream.addTrack(track)
      })
    } catch (e) {
      console.warn("No camera, continuing audio-only")
    }

    const localVideo = document.getElementById("localVideo")
    if (localVideo) {
      localVideo.srcObject = this.stream

      const hasVideo = this.stream.getVideoTracks().length > 0
      localVideo.style.display = hasVideo ? "block" : "none"
    }

    this.stream.getTracks().forEach(track => {
      this.peer?.addTrack(track, this.stream)
    })
  }

  async start() {
    if (!this.isCaller) return
    this.activePeerId = this.otherUserIdValue

    if (!this.peer) {
      await this.initPeer()
    }

    await this.initMedia()

    this.setStatus("📞 Calling...")
    this.showModal("outgoingCallModal")

    if (this.peer.signalingState !== "stable") {
      return
    }

    const offer = await this.peer.createOffer()
    await this.peer.setLocalDescription(offer)

    this.channel.perform("signal", {
      receiver_id: this.activePeerId,
      offer,
      caller_id: this.currentUserIdValue
    })
  }

  async handleSignal(data) {
    if (data.receiver_id && data.receiver_id !== this.currentUserIdValue) return

    if (data.offer && data.caller_id !== this.currentUserIdValue) {
      this.activePeerId = data.caller_id
      this.pendingOffer = data.offer
      localStorage.setItem("pending_offer", JSON.stringify(data.offer))

      this.setStatus("📲 Incoming call...")
      this.showModal("incomingCallModal")
    }

    if (data.answer && this.peer) {
      if (this.peer.signalingState === "stable") {
        console.log("answer already applied")
        return
      }

      await this.peer.setRemoteDescription(
          new RTCSessionDescription(data.answer)
      )

      this.remoteReady = true

      this.iceQueue.forEach(candidate => {
        this.peer.addIceCandidate(
            new RTCIceCandidate(candidate)
        )
      })

      this.iceQueue = []
    }

    if (data.candidate) {
      if (this.peer?.remoteDescription) {
        this.peer.addIceCandidate(
            new RTCIceCandidate(data.candidate)
        )
      } else {
        this.iceQueue.push(data.candidate)
      }
    }

    if (data.decline) {
      this.forceReset()
    }
  }

  async acceptCall() {
    if (!this.pendingOffer) return

    await this.initPeer()

    if (this.peer.signalingState !== "stable") {
      console.log("offer already accepted")
      return
    }

    await this.initMedia()

    await this.peer.setRemoteDescription(
        new RTCSessionDescription(this.pendingOffer)
    )

    const answer = await this.peer.createAnswer()

    await this.peer.setLocalDescription(answer)

    this.channel.perform("signal", {
      receiver_id: this.activePeerId || this.otherUserIdValue,
      answer,
      caller_id: this.currentUserIdValue
    })

    this.pendingOffer = null
    localStorage.removeItem("pending_offer")

    this.hideModal("incomingCallModal")
    this.showModal("activeCallModal")
  }

  declineCall() {
    const receiverId = this.activePeerId || this.otherUserIdValue
    this.channel?.perform("signal", {
      receiver_id: receiverId,
      decline: true,
      caller_id: this.currentUserIdValue
    })

    this.forceReset()
  }

  cleanupCall() {
    this.callInProgress = false
    this.remoteReady = false
    this.resetUIAfterCall()
    this.cleanupWebRTC()
    this.pendingOffer = null
  }

  cancelCall() {
    this.declineCall()
  }

  endCall() {
    this.declineCall()
  }

  startTimer() {
    if (this.timer) return

    this.seconds = 0

    this.timer = setInterval(() => {
      this.seconds++

      const el = document.getElementById("callTimer")
      if (el) {
        const m = String(Math.floor(this.seconds / 60)).padStart(2, "0")
        const s = String(this.seconds % 60).padStart(2, "0")
        el.textContent = `${m}:${s}`
      }
      }, 1000)
  }

  stopTimer() {
    clearInterval(this.timer)
    this.timer = null
    this.seconds = 0
    const el = document.getElementById("callTimer")
    if (el) el.textContent = "00:00"
  }

  toggleMute() {
    if (!this.stream) return
    const track = this.stream.getAudioTracks()[0]

    if (!track) return

    this.isMuted = !this.isMuted

    track.enabled = !this.isMuted

    this.updateMuteButton()
  }

  toggleVideo() {
    if (!this.stream) return

    const track = this.stream.getVideoTracks()[0]

    if (!track) return

    this.isVideoOff = !this.isVideoOff
    track.enabled = !this.isVideoOff

    this.updateVideoButton()
  }

  updateMuteButton() {
    const btn = document.querySelector('[data-action="voice#toggleMute"]')
    if (!btn) return

    if (this.isMuted) {
      btn.innerHTML = '<i class="bi bi-mic-mute"></i> Unmute'
      btn.classList.replace("btn-warning", "btn-secondary")
    }
    else { btn.innerHTML = '<i class="bi bi-mic"></i> Mute'
      btn.classList.replace("btn-secondary", "btn-warning")
    }
  }

  updateVideoButton() {
    const btn = document.querySelector('[data-action="voice#toggleVideo"]')
    if (!btn) return

    if (this.isVideoOff) {
      btn.innerHTML = '<i class="bi bi-camera-video-off"></i> Camera Off'
      btn.classList.replace("btn-info", "btn-secondary")
    } else {
      btn.innerHTML = '<i class="bi bi-camera-video"></i> Camera On'
      btn.classList.replace("btn-secondary", "btn-info")
    }
  }

  forceReset() {
    this.cleanupWebRTC()
    this.resetUIAfterCall()
    this.pendingOffer = null

    localStorage.removeItem("pending_offer")

    this.remoteReady = false
    this.activePeerId = null
  }

  restoreUIOnly() {
    if (!this.inCall) return

    this.inCall = true
    const returnBtn = document.getElementById("returnToCall")

    if (returnBtn) returnBtn.classList.remove("d-none")
    this.setStatus("🔄 Reconnecting...")
    this.showModal("activeCallModal")
  }

  returnToCall() {
    this.showModal("activeCallModal")

    const btn = document.getElementById("returnToCall")
    if (btn) btn.classList.add("d-none")
  }
}
