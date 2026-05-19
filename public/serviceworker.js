self.addEventListener('push', (event) => {
    const data = event.data ? event.data.json() : {}
    const title = data.title || "New notification"
    const body = data.body || ""
    const icon = "/icon.png"

    event.waitUntil(
        self.registration.showNotification(title, { body, icon, badge: icon })
    )
})