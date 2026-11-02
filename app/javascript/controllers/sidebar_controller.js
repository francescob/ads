import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const sidebar = document.getElementById("sidebar")
    const backdrop = document.getElementById("mobile-sidebar-backdrop")

    if (sidebar.classList.contains("-translate-x-full")) {
      sidebar.classList.remove("-translate-x-full")
      backdrop.classList.remove("hidden")
    } else {
      sidebar.classList.add("-translate-x-full")
      backdrop.classList.add("hidden")
    }
  }

  close() {
    const sidebar = document.getElementById("sidebar")
    const backdrop = document.getElementById("mobile-sidebar-backdrop")
    sidebar.classList.add("-translate-x-full")
    backdrop.classList.add("hidden")
  }
}