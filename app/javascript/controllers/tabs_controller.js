import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { initial: String }

  connect() {
    const requested = this.tabTargets.find(tab => tab.dataset.tab === this.initialValue)
    this.showTab(requested ? this.initialValue : (this.tabTargets[0]?.dataset.tab || "profile"))
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    this.showTab(tab)
  }

  showTab(tabName) {
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === tabName) {
        tab.classList.add("border-blue-500", "text-blue-600")
        tab.classList.remove("border-transparent", "text-slate-500")
      } else {
        tab.classList.remove("border-blue-500", "text-blue-600")
        tab.classList.add("border-transparent", "text-slate-500")
      }
    })

    this.panelTargets.forEach(panel => {
      if (panel.dataset.tab === tabName) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}