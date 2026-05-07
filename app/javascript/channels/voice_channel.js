import consumer from "channels/consumer"

consumer.subscriptions.create("VoiceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if (!data?.offer || !data?.room_id) return

    const inRoomPath = window.location.pathname.match(/^\/rooms\/(\d+)$/)
    const currentRoomId = inRoomPath ? Number(inRoomPath[1]) : null
    const targetRoomId = Number(data.room_id)

    if (currentRoomId === targetRoomId) return

    try {
      localStorage.setItem("pending_offer_payload", JSON.stringify({
        offer: data.offer,
        caller_id: data.caller_id,
        caller_login: data.caller_login,
        caller_avatar_url: data.caller_avatar_url,
        call_started_at: data.call_started_at
      }))
      localStorage.setItem("active_peer_id", String(data.caller_id))
      if (data.call_started_at) {
        localStorage.setItem("call_started_at", String(data.call_started_at))
      }
    } catch (_error) {
      // Ignore storage errors and still redirect.
    }

    window.location.assign(`/rooms/${targetRoomId}`)
  }
});
