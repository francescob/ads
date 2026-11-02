import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification"
export default class extends Controller {
  static targets = ["toast"]
  static values = {
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 }, // 5 seconds
    notificationId: Number
  }

  connect() {
    // Animate in
    this.element.classList.add("opacity-0", "translate-x-full")
    
    // Force reflow for animation
    this.element.offsetHeight
    
    // Slide in animation
    this.element.classList.remove("opacity-0", "translate-x-full")
    this.element.classList.add("opacity-100", "translate-x-0")
    
    // Auto-dismiss if enabled
    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Clear timeout if exists
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Animate out
    this.element.classList.remove("opacity-100", "translate-x-0")
    this.element.classList.add("opacity-0", "translate-x-full")

    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  pauseDismiss() {
    // Pause auto-dismiss on hover
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  resumeDismiss() {
    // Resume auto-dismiss after hover
    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.dismissAfterValue)
    }
  }

  markAsRead(event) {
    event.preventDefault()
    
    if (!this.notificationIdValue) {
      this.dismiss()
      return
    }

    // Send request to mark as read
    const url = `/notifications/${this.notificationIdValue}/mark_as_read`
    
    fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    })
    .then(response => {
      if (response.ok) {
        this.dismiss()
      }
    })
    .catch(error => {
      console.error('Error marking notification as read:', error)
      this.dismiss()
    })
  }
}