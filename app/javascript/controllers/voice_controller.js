import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer";
export default class extends Controller {
  static values = {
    currentUserId: Number,
    callerId: Number,
    otherUserId: Number
  }

  static targets = ['status']

  connect() {
    if (this.hasConnected) return
    this.hasConnected = true

    this.resetState()
    this.initCable()

    this.isCaller = this.currentUserIdValue === this.callerIdValue

    this.inCall = localStorage.getItem("call_active") === "true"

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
    this.localVideo = null
    this.iceQueue = []
    this.remoteReady = false
    this.inCall = false
    this.isMuted = false
    this.timer = null
    this.seconds = 0
    this.channel = null
    this.callInProgress = false
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

  initPeer() {
    if (this.peer) return

    this.peer = new RTCPeerConnection({
      iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
    })

    this.peer.onicecandidate = (e) => {
      if (e.candidate) {
        this.channel?.perform('signal', {
          receiver_id: this.otherUserIdValue,
          candidate: e.candidate,
          caller_id: this.currentUserIdValue
        })
      }
    }

    this.peer.ontrack = (e) => {
      const stream = e.streams[0]

      const hasVideo = stream.getVideoTracks().length > 0

      if (hasVideo) {
        if (!this.remoteVideo) {
          this.remoteVideo = document.createElement("video")
          this.remoteVideo.autoplay = true
          this.remoteVideo.playsInline = true
          this.remoteVideo.style.width = "300px"

          document.body.appendChild(this.remoteVideo)
        }

        this.remoteVideo.srcObject = stream

        // ❗ ВОТ ЗДЕСЬ удаляем audio
        if (this.remoteAudio) {
          this.remoteAudio.remove()
          this.remoteAudio = null
        }

      }

      else {
        if (!this.remoteAudio) {
          this.remoteAudio = document.createElement("audio")
          this.remoteAudio.autoplay = true

          document.body.appendChild(this.remoteAudio)
        }

        this.remoteAudio.srcObject = stream

        if (this.remoteVideo) {
          this.remoteVideo.remove()
          this.remoteVideo = null
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

    this.stream = await navigator.mediaDevices.getUserMedia({
      audio: true,
      video: true
    })

    this.stream.getTracks().forEach(track => {
      this.peer?.addTrack(track, this.stream) })
  }

  async start() {
    if (!this.isCaller) return
    if (!this.peer) {
      this.initPeer()
    }

    await this.initMedia()

    this.setStatus("📞 Calling...")
    this.showModal("outgoingCallModal")

    const offer = await this.peer.createOffer()
    await this.peer.setLocalDescription(offer)

    this.channel.perform("signal", {
      receiver_id: this.otherUserIdValue,
      offer,
      caller_id: this.currentUserIdValue
    })
  }

  async handleSignal(data) {
    if (data.receiver_id && data.receiver_id !== this.currentUserIdValue) return

    if (data.offer && data.caller_id !== this.currentUserIdValue) {
      this.pendingOffer = data.offer
      localStorage.setItem("pending_offer", JSON.stringify(data.offer))

      this.setStatus("📲 Incoming call...")
      this.showModal("incomingCallModal")
    }

    if (data.answer && this.peer) {
      await this.peer.setRemoteDescription(
          new RTCSessionDescription(data.answer)
      )

      this.remoteReady = true

      this.iceQueue.forEach(c =>
          this.peer.addIceCandidate(new RTCIceCandidate(c))
      )
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

    this.initPeer()
    await this.initMedia()

    await this.peer.setRemoteDescription(
        new RTCSessionDescription(this.pendingOffer)
    )

    const answer = await this.peer.createAnswer()

    await this.peer.setLocalDescription(answer)

    this.channel.perform("signal", {
      receiver_id: this.otherUserIdValue,
      answer,
      caller_id: this.currentUserIdValue
    })

    localStorage.removeItem("pending_offer")

    this.showModal("activeCallModal")
  }

  declineCall() {
    this.channel?.perform("signal", {
      receiver_id: this.otherUserIdValue,
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

  forceReset() {
    this.cleanupWebRTC()
    this.resetUIAfterCall()
    this.pendingOffer = null
    this.remoteReady = false
  }

  restoreUIOnly() {
    if (!this.inCall) return

    this.inCall = true
    const returnBtn = document.getElementById("returnToCall")

    if (returnBtn) returnBtn.classList.remove("d-none")
    this.setStatus("🔄 Reconnecting...")
    this.showModal("activeCallModal")
  }
}