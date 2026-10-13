import { Controller } from "@hotwired/stimulus"

// Turns a label wrapping a file input into a drag & drop target.
export default class extends Controller {
  static targets = ["zone", "input", "label", "submit"]

  over(event) {
    event.preventDefault()
    this.zoneTarget.classList.add("dropzone-active")
  }

  leave() {
    this.zoneTarget.classList.remove("dropzone-active")
  }

  drop(event) {
    event.preventDefault()
    this.leave()
    if (event.dataTransfer.files.length === 0) return

    const files = new DataTransfer()
    files.items.add(event.dataTransfer.files[0])
    this.inputTarget.files = files.files
    this.changed()
  }

  changed() {
    const file = this.inputTarget.files[0]
    this.labelTarget.textContent = file ? file.name : "Drop a file here or click to choose one"
    this.submitTarget.disabled = !file
  }
}
