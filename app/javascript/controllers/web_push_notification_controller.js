import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="web-push-notification"
export default class extends Controller {
  static values = {
    vap: Array,
  }

  connect() {
    if (!navigator.serviceWorker) {
      console.error('Service worker is not supported in this browser');
      return
    }

    if (window.__webPushInitDone) return
    window.__webPushInitDone = true

    this.initializeSubscription()
  }

  async initializeSubscription() {
    try {
      if (!this.hasVapValue || !Array.isArray(this.vapValue) || this.vapValue.length === 0) return

      const vapidPublicKey = new Uint8Array(this.vapValue)
      const registration = await navigator.serviceWorker.register('/serviceworker.js')
      console.log('Service worker registered', registration)

      let permission = Notification.permission
      if (permission === 'default') {
        permission = await Notification.requestPermission()
      }
      if (permission !== 'granted') return

      const serviceWorkerRegistration = await navigator.serviceWorker.ready
      let subscription = await serviceWorkerRegistration.pushManager.getSubscription()

      if (!subscription) {
        subscription = await serviceWorkerRegistration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: vapidPublicKey
        })
      }

      const token = document.querySelector('meta[name="csrf-token"]')?.content
      await fetch('/users/register_subscription', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ subscription: JSON.stringify(subscription) })
      })
    } catch (error) {
      console.error('Web push subscription failed', error)
    }
  }
}
