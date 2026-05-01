import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer";

export default class extends Controller {
  static values = {
    currentUserId: Number,
    currentUserLogin: String,
    currentUserAvatarUrl: String,
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

    const savedOfferPayload = localStorage.getItem("pending_offer_payload")
    if (savedOfferPayload) {
      const payload = JSON.parse(savedOfferPayload)
      this.pendingOffer = payload.offer
      this.activePeerId = payload.caller_id || null
      this.ensureCallStartedAt(payload.call_started_at || this.loadCallStartedAt())
      this.updateIncomingCallerUI(payload.caller_login, payload.caller_avatar_url)
      this.updateActiveCallPeerUI(payload.caller_login, payload.caller_avatar_url)
      this.setStatus("📲 Incoming call (restored)")
    }

    if (this.inCall) {
      this.restoreUIOnly()
      this.tryRejoinCall()
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
    this.isVideoOff = true
    this.currentFacingMode = "user"
    this.videoSender = null
    this.isNegotiating = false
    this.timer = null
    this.seconds = 0
    this.channel = null
    this.callInProgress = false
    this.activePeerId = null
    this.cableConnected = false
    this.rejoinInProgress = false
    this.callStartedAtMs = null
    this.disconnectTimeout = null
    this.remoteVideoEnabled = true
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
    clearTimeout(this.disconnectTimeout)
    this.disconnectTimeout = null

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

  updateRemoteVideoUI(enabled) {
    const remoteVideo = document.getElementById("remoteVideo")
    const avatarFallback = document.getElementById("avatarFallback")
    if (!remoteVideo || !avatarFallback) return

    this.remoteVideoEnabled = enabled
    remoteVideo.style.display = enabled ? "block" : "none"
    avatarFallback.style.display = enabled ? "none" : "block"
  }

  syncLocalVideoVisibility() {
    const localVideo = document.getElementById("localVideo")
    if (!localVideo || !this.stream) return

    localVideo.srcObject = this.stream
    const videoTrack = this.stream.getVideoTracks()[0]
    const show = Boolean(videoTrack && videoTrack.enabled)
    localVideo.style.display = show ? "block" : "none"
  }

  resetUIAfterCall() {
    this.hideAllModals()
    this.setStatus("Idle")

    document.getElementById("returnToCall")?.classList.add("d-none")

    this.inCall = false

    localStorage.removeItem('call_active')
    localStorage.removeItem('active_peer_id')
    localStorage.removeItem('call_started_at')
    this.updateVideoButton()
  }

  setStatus(text) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
    }
  }

  updateIncomingCallerUI(name, avatarUrl) {
    const nameEl = document.getElementById("incomingCallerName")
    if (nameEl && name) nameEl.textContent = name

    const avatarEl = document.getElementById("incomingCallerAvatar")
    if (avatarEl && avatarUrl) avatarEl.src = avatarUrl
  }

  updateActiveCallPeerUI(name, avatarUrl) {
    const nameEl = document.getElementById("activeCallPeerName")
    if (nameEl && name) nameEl.textContent = name

    const avatarEl = document.getElementById("avatarFallback")
    if (avatarEl && avatarUrl) avatarEl.src = avatarUrl
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
        {
          connected: () => {
            this.cableConnected = true
          },
          disconnected: () => {
            this.cableConnected = false
          },
          received: (data) => this.handleSignal(data)
        }
    )
  }

  ensureCallStartedAt(startedAtMs = null) {
    if (startedAtMs) {
      this.callStartedAtMs = startedAtMs
    } else if (!this.callStartedAtMs) {
      this.callStartedAtMs = Date.now()
    }

    if (this.callStartedAtMs) {
      localStorage.setItem("call_started_at", String(this.callStartedAtMs))
    }
  }

  loadCallStartedAt() {
    const raw = localStorage.getItem("call_started_at")
    if (!raw) return null
    const ts = Number(raw)
    if (!Number.isFinite(ts) || ts <= 0) return null
    return ts
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

    this.peer.onnegotiationneeded = async () => {
      if (this.isNegotiating) return
      if (!this.peer || this.peer.signalingState !== "stable") return

      try {
        this.isNegotiating = true
        const offer = await this.peer.createOffer()
        await this.peer.setLocalDescription(offer)
        this.channel?.perform("signal", {
          receiver_id: this.activePeerId || this.otherUserIdValue,
          offer,
          caller_id: this.currentUserIdValue,
          caller_login: this.currentUserLoginValue,
          caller_avatar_url: this.currentUserAvatarUrlValue,
          call_started_at: this.callStartedAtMs
        })
      } catch (error) {
        console.warn("Negotiation failed", error)
      } finally {
        this.isNegotiating = false
      }
    }

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

        if (!remoteVideo) return

        if (!this.remoteStream) {
          this.remoteStream = new MediaStream()
        }

        this.remoteStream.addTrack(track)

        remoteVideo.srcObject = null
        remoteVideo.srcObject = this.remoteStream
        this.updateRemoteVideoUI(true)

        track.onended = () => this.updateRemoteVideoUI(false)
        track.onmute = () => this.updateRemoteVideoUI(false)
        track.onunmute = () => this.updateRemoteVideoUI(true)
      }

      this.setStatus("🔊 Connected")
      this.showModal("activeCallModal")
    }

    this.peer.onconnectionstatechange = () => {
      const state = this.peer.connectionState
      if (state === "connected") {
        clearTimeout(this.disconnectTimeout)
        this.disconnectTimeout = null
        this.setStatus("🟢 Connected")
        this.inCall = true
        localStorage.setItem('call_active', "true")
        this.ensureCallStartedAt(this.callStartedAtMs || this.loadCallStartedAt() || Date.now())
        this.startTimer()
      }

      if (state === "disconnected") {
        this.setStatus("🔄 Reconnecting...")
        clearTimeout(this.disconnectTimeout)
        this.disconnectTimeout = setTimeout(() => {
          this.forceReset()
        }, 15000)
        return
      }

      if (["failed", "closed"].includes(state)) {
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
    this.syncLocalVideoVisibility()

    this.stream.getTracks().forEach(track => {
      this.peer?.addTrack(track, this.stream)
    })
  }

  async start() {
    if (!this.isCaller) return
    this.activePeerId = this.otherUserIdValue
    localStorage.setItem("active_peer_id", String(this.activePeerId))
    this.ensureCallStartedAt(Date.now())

    if (!this.peer) {
      await this.initPeer()
    }

    await this.initMedia()
    this.updateVideoButton()

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
      caller_id: this.currentUserIdValue,
      caller_login: this.currentUserLoginValue,
      caller_avatar_url: this.currentUserAvatarUrlValue,
      call_started_at: this.callStartedAtMs || Date.now()
    })
  }

  async handleSignal(data) {
    if (data.receiver_id && data.receiver_id !== this.currentUserIdValue) return

    if (data.offer && data.caller_id !== this.currentUserIdValue) {
      if (this.peer) {
        await this.peer.setRemoteDescription(
          new RTCSessionDescription(data.offer)
        )
        const renegotiationAnswer = await this.peer.createAnswer()
        await this.peer.setLocalDescription(renegotiationAnswer)
        this.channel.perform("signal", {
          receiver_id: data.caller_id,
          answer: renegotiationAnswer,
          caller_id: this.currentUserIdValue,
          call_started_at: data.call_started_at || this.callStartedAtMs
        })
        return
      }

      if (this.inCall || localStorage.getItem("call_active") === "true") {
        this.activePeerId = data.caller_id
        localStorage.setItem("active_peer_id", String(this.activePeerId))
        await this.initPeer()
        await this.initMedia()
        await this.peer.setRemoteDescription(
          new RTCSessionDescription(data.offer)
        )
        const autoAnswer = await this.peer.createAnswer()
        await this.peer.setLocalDescription(autoAnswer)
        this.channel.perform("signal", {
          receiver_id: this.activePeerId,
          answer: autoAnswer,
          caller_id: this.currentUserIdValue,
          call_started_at: data.call_started_at || this.callStartedAtMs
        })
        return
      }

      this.activePeerId = data.caller_id
      localStorage.setItem("active_peer_id", String(this.activePeerId))
      this.updateIncomingCallerUI(data.caller_login, data.caller_avatar_url)
      this.updateActiveCallPeerUI(data.caller_login, data.caller_avatar_url)
      this.pendingOffer = data.offer
      this.ensureCallStartedAt(data.call_started_at || Date.now())
      localStorage.setItem("pending_offer_payload", JSON.stringify({
        offer: data.offer,
        caller_id: data.caller_id,
        caller_login: data.caller_login,
        caller_avatar_url: data.caller_avatar_url,
        call_started_at: data.call_started_at || this.callStartedAtMs
      }))

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

    if (Object.prototype.hasOwnProperty.call(data, "video_enabled")) {
      this.updateRemoteVideoUI(Boolean(data.video_enabled))
    }
  }

  async acceptCall() {
    if (!this.pendingOffer) return

    await this.initPeer()
    localStorage.setItem("active_peer_id", String(this.activePeerId || this.otherUserIdValue))
    this.ensureCallStartedAt(this.callStartedAtMs || this.loadCallStartedAt() || Date.now())

    if (this.peer.signalingState !== "stable") {
      console.log("offer already accepted")
      return
    }

    await this.initMedia()
    this.updateVideoButton()

    await this.peer.setRemoteDescription(
        new RTCSessionDescription(this.pendingOffer)
    )

    const answer = await this.peer.createAnswer()

    await this.peer.setLocalDescription(answer)

    this.channel.perform("signal", {
      receiver_id: this.activePeerId || this.otherUserIdValue,
      answer,
      caller_id: this.currentUserIdValue,
      call_started_at: this.callStartedAtMs
    })

    this.pendingOffer = null
    localStorage.removeItem("pending_offer_payload")

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
    const startedAt = this.loadCallStartedAt() || this.callStartedAtMs || Date.now()
    this.callStartedAtMs = startedAt
    localStorage.setItem("call_started_at", String(startedAt))
    this.seconds = Math.max(0, Math.floor((Date.now() - startedAt) / 1000))

    this.timer = setInterval(() => {
      this.seconds = Math.max(0, Math.floor((Date.now() - startedAt) / 1000))

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

    if (this.isVideoOff) {
      this.enableVideo(track)
      return
    }

    if (!track) return
    track.enabled = false
    this.isVideoOff = true
    this.channel?.perform("signal", {
      receiver_id: this.activePeerId || this.otherUserIdValue,
      caller_id: this.currentUserIdValue,
      video_enabled: false
    })
    this.syncLocalVideoVisibility()
    this.updateVideoButton()
  }

  async enableVideo(existingTrack) {
    if (existingTrack) {
      existingTrack.enabled = true
      this.isVideoOff = false
      this.channel?.perform("signal", {
        receiver_id: this.activePeerId || this.otherUserIdValue,
        caller_id: this.currentUserIdValue,
        video_enabled: true
      })
      this.syncLocalVideoVisibility()
      this.updateVideoButton()
      return
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: this.currentFacingMode }
      })
      const newTrack = stream.getVideoTracks()[0]
      if (!newTrack) return

      this.stream.addTrack(newTrack)

      if (this.videoSender) {
        await this.videoSender.replaceTrack(newTrack)
      } else {
        this.videoSender = this.peer?.addTrack(newTrack, this.stream) || null
      }

      this.isVideoOff = false
      this.channel?.perform("signal", {
        receiver_id: this.activePeerId || this.otherUserIdValue,
        caller_id: this.currentUserIdValue,
        video_enabled: true
      })
      this.syncLocalVideoVisibility()
      this.updateVideoButton()
    } catch (error) {
      console.warn("Camera access failed", error)
    }
  }

  async flipCamera() {
    if (!this.stream || this.isVideoOff) return

    const currentTrack = this.stream.getVideoTracks()[0]
    if (!currentTrack) return

    const nextMode = this.currentFacingMode === "user" ? "environment" : "user"

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { exact: nextMode } }
      })
      const newTrack = stream.getVideoTracks()[0]
      if (!newTrack) return

      this.stream.removeTrack(currentTrack)
      currentTrack.stop()
      this.stream.addTrack(newTrack)

      if (!this.videoSender) {
        this.videoSender = this.peer?.getSenders()?.find(sender => sender.track?.kind === "video") || null
      }
      if (this.videoSender) {
        await this.videoSender.replaceTrack(newTrack)
      }

      this.currentFacingMode = nextMode
      this.syncLocalVideoVisibility()
    } catch (error) {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: nextMode }
        })
        const newTrack = stream.getVideoTracks()[0]
        if (!newTrack) return

        this.stream.removeTrack(currentTrack)
        currentTrack.stop()
        this.stream.addTrack(newTrack)

        if (!this.videoSender) {
          this.videoSender = this.peer?.getSenders()?.find(sender => sender.track?.kind === "video") || null
        }
        if (this.videoSender) {
          await this.videoSender.replaceTrack(newTrack)
        }

        this.currentFacingMode = nextMode
        this.syncLocalVideoVisibility()
      } catch (fallbackError) {
        console.warn("Flip camera failed", fallbackError)
      }
    }
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
      btn.innerHTML = '<i class="bi bi-camera-video"></i> Camera On'
      btn.classList.replace("btn-info", "btn-secondary")
    } else {
      btn.innerHTML = '<i class="bi bi-camera-video-off"></i> Camera Off'
      btn.classList.replace("btn-secondary", "btn-info")
    }
  }

  forceReset() {
    this.cleanupWebRTC()
    this.resetUIAfterCall()
    this.pendingOffer = null

    localStorage.removeItem("pending_offer_payload")

    this.remoteReady = false
    this.activePeerId = null
    this.callStartedAtMs = null
  }

  restoreUIOnly() {
    if (!this.inCall) return

    this.inCall = true
    const returnBtn = document.getElementById("returnToCall")

    if (returnBtn) returnBtn.classList.remove("d-none")
    this.setStatus("🔄 Reconnecting...")
    this.showModal("activeCallModal")
  }

  async tryRejoinCall() {
    if (this.rejoinInProgress) return
    this.rejoinInProgress = true

    const storedPeerId = localStorage.getItem("active_peer_id")
    if (!storedPeerId) {
      this.rejoinInProgress = false
      return
    }

    const peerId = Number(storedPeerId)
    if (!Number.isFinite(peerId) || peerId <= 0) {
      this.rejoinInProgress = false
      return
    }

    this.activePeerId = peerId
    this.callStartedAtMs = this.loadCallStartedAt()

    // Wait briefly for ActionCable subscription to be connected after page reload.
    for (let i = 0; i < 15 && !this.cableConnected; i++) {
      await new Promise(resolve => setTimeout(resolve, 200))
    }

    try {
      await this.initPeer()
      await this.initMedia()
      this.updateVideoButton()

      if (!this.peer || this.peer.signalingState !== "stable") return

      const offer = await this.peer.createOffer()
      await this.peer.setLocalDescription(offer)

      this.channel.perform("signal", {
        receiver_id: this.activePeerId,
        offer,
        caller_id: this.currentUserIdValue,
        caller_login: this.currentUserLoginValue,
        caller_avatar_url: this.currentUserAvatarUrlValue,
        call_started_at: this.callStartedAtMs
      })
    } catch (error) {
      console.warn("Call rejoin failed", error)
    } finally {
      this.rejoinInProgress = false
    }
  }

  returnToCall() {
    this.showModal("activeCallModal")

    const btn = document.getElementById("returnToCall")
    if (btn) btn.classList.add("d-none")
  }
}
