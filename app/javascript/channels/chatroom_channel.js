import consumer from "channels/consumer"

document.addEventListener("turbo:load", () => {
  const chatroom = document.getElementById("chatroom")
  if (!chatroom) return

  const match = window.location.pathname.match(/conversations\/(\d+)/)
  if (!match) return

  const conversationId = match[1]

  consumer.subscriptions.create(
      {
        channel: "ChatroomChannel",
        conversation_id: conversationId
      },
      {
        connected(){
          console.log("Connected to ChatroomChannel")

        },

        received(data) {
          chatroom.insertAdjacentHTML("beforeend", data.html)

          const trix = document.querySelector("trix-editor")
          if (trix) trix.editor.loadHTML("")
        }
      }
  )
})
