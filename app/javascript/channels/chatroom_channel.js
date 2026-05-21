import consumer from "channels/consumer"

let subscription
let readHeartbeat = null
const pendingReadIds = new Set()

document.addEventListener("turbo:load", () => {
  const chatroom = document.getElementById("chatroom")
  const currentUserId = Number(document.querySelector('meta[name="current-user-id"]')?.content)
  if (chatroom) {
    chatroom.scrollTop = chatroom.scrollHeight
  }

  const match =
    window.location.pathname.match(/rooms\/(\d+)/) ||
    window.location.pathname.match(/conversations\/(\d+)/)

  if (!match) return

  const roomId = match[1]

  subscription = consumer.subscriptions.create(
    {
      channel: "ChatroomChannel",
      room_id: roomId
    },
    {
      connected() {
        this.perform("mark_read", {})
      },

      received(data) {
        if (data.action === "read_update") {
          (data.message_ids || []).forEach((id) => {
            const normalizedId = Number(id)
            const ticks = document.querySelector(`#message_${id} .ticks`)
            if (ticks) {
              ticks.innerHTML = '<i class="bi bi-check2-all"></i>'
              pendingReadIds.delete(normalizedId)
            } else {
              pendingReadIds.add(normalizedId)
            }
          })
          return
        }

        if (data.action === "delete") {
          const el = document.getElementById(`message_${data.message_id}`)
          if (el) el.remove()
          return
        }

        if (!data.html || !chatroom) return

        chatroom.insertAdjacentHTML("beforeend", data.html)
        const lastMessage = chatroom.lastElementChild
        const messageId = Number(lastMessage?.id?.replace("message_", ""))
        if (messageId && pendingReadIds.has(messageId)) {
          const ticks = lastMessage.querySelector(".ticks")
          if (ticks) ticks.innerHTML = '<i class="bi bi-check2-all"></i>'
          pendingReadIds.delete(messageId)
        }

        if (Number(data.sender_id) === currentUserId) {
          const trix = document.querySelector("trix-editor")
          if (trix) trix.editor.loadHTML("")
        } else if (document.visibilityState === "visible") {
          this.perform("mark_read", {})
        }

        chatroom.scrollTop = chatroom.scrollHeight
      }
    }
  )

  if (readHeartbeat) clearInterval(readHeartbeat)
  readHeartbeat = setInterval(() => {
    if (document.visibilityState === "visible" && subscription) {
      subscription.perform("mark_read", {})
    }
  }, 30000)

  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "visible" && subscription) {
      subscription.perform("mark_read", {})
    }
  })

  document.addEventListener("turbo:before-cache", () => {
    if (readHeartbeat) {
      clearInterval(readHeartbeat)
      readHeartbeat = null
    }
    if (subscription) {
      consumer.subscriptions.remove(subscription)
      subscription = null
    }
  }, { once: true })
})
