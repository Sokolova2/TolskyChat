import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const container = document.getElementById("notifications_counter")
    if (container) {
      container.outerHTML = data.html
    }
  }
});
