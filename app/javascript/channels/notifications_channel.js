import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to NotificationsChannel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const counter = document.getElementById("notification-counter")
    if (!counter || data.count === undefined) return

    if (data.count > 0) {
      counter.textContent = data.count
      counter.classList.remove("d-none")
    } else {
      counter.classList.add("d-none")
    }

    const list = document.getElementById("notifications-list")
    if (list && data.html) {
      list.insertAdjacentHTML("afterbegin", data.html)
    }
  }
});
