import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reply"
export default class extends Controller {
  toggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const commentId = button.dataset.commentId
    const form = document.getElementById(`reply-form-${commentId}`)
    if (form) {
      form.style.display = form.style.display === "none" ? "block" : "none"
      // Focus the textarea when showing the form
      if (form.style.display === "block") {
        const textarea = form.querySelector("textarea")
        if (textarea) textarea.focus()
      }
    }
  }

  cancel(event) {
    event.preventDefault()
    const button = event.currentTarget
    const commentId = button.dataset.commentId
    const form = document.getElementById(`reply-form-${commentId}`)
    if (form) {
      form.style.display = "none"
      // Clear the textarea
      const textarea = form.querySelector("textarea")
      if (textarea) textarea.value = ""
    }
  }
}
