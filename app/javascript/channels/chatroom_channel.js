import consumer from "channels/consumer"

document.addEventListener("turbo:load", () => {
  const chatroom = document.getElementById("chatroom")
  if (chatroom){
      chatroom.scrollTop = chatroom.scrollHeight
  }

  const match =
      window.location.pathname.match(/rooms\/(\d+)/)||
      window.location.pathname.match(/conversations\/(\d+)/)

  if (!match) return

  const roomId = match[1];

  consumer.subscriptions.create(
      {
        channel: "ChatroomChannel",
        room_id: roomId
      },
      {
        connected(){
          console.log("Connected to ChatroomChannel")

        },

        received(data) {
            if (data.action === "delete"){
                const el = document.getElementById(`message_${data.message_id}`)
                if(el) el.remove()
                return
            }

            if (!data.html) return

            chatroom.insertAdjacentHTML("beforeend", data.html)

            const trix = document.querySelector("trix-editor")
            if (trix) trix.editor.loadHTML("");

            chatroom.scrollTop = chatroom.scrollHeight
        }
      }
  )
})
