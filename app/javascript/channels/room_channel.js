import consumer from "channels/consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    console.log("Connected to RoomChannel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if (data.action === "delete") {
      const el = document.getElementById(`room_${data.room_id}`)
      if (el) el.remove()
      return
    }

    if (!data.html) return

    const roomList = document.getElementById("room_list")
    if (!roomList) return

    const existing = document.getElementById(`room_${data.room_id}`)
    if (existing) {
      existing.outerHTML = data.html
      return
    }

    roomList.insertAdjacentHTML("afterbegin", data.html)
  }
});
