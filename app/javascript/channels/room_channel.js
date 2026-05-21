import consumer from "channels/consumer"

function renderDefaultRoomState() {
  const wrapper = document.querySelector(".room-wrapper")
  if (!wrapper) return

  wrapper.innerHTML = `
    <div class="container-content bg-light">
      <div class="px-3 pt-2 pb-3">
        <h5 class="mb-3">Hello from TolskyChat</h5>
        <p>Thanks to this chat, you can communicate with friends from different parts of the world.</p>
      </div>
    </div>
  `
}

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

      const currentRoomMatch =
        window.location.pathname.match(/^\/rooms\/(\d+)$/) ||
        window.location.pathname.match(/^\/conversations\/(\d+)$/)
      if (currentRoomMatch && Number(currentRoomMatch[1]) === Number(data.room_id)) {
        if (window.history?.pushState) {
          window.history.pushState({}, "", "/rooms")
        }
        renderDefaultRoomState()
      }
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
