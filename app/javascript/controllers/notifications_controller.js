import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = ["badge", "dropdown"]
  static values = { count: Number }

  connect() {
    this.element.addEventListener("shown.bs.dropdown", this.markAsRead.bind(this))
  }

  markAsRead() {
    if (this.countValue > 0) {
      fetch("/notifications/mark_read", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "text/vnd.turbo-stream.html",
          "Content-Type": "text/vnd.turbo-stream.html"
        }
      })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
        this.clearBadge()
      })
    }
  }

  clearBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.remove()
    }
  }
}
