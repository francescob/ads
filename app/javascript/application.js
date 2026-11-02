// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Visual debug indicator
function showDebugMessage(message, color = "blue") {
  const existing = document.getElementById("turbo-debug-indicator")
  if (existing) existing.remove()
  
  const indicator = document.createElement("div")
  indicator.id = "turbo-debug-indicator"
  indicator.textContent = message
  indicator.style.cssText = `
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    background: ${color};
    color: white;
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: bold;
    z-index: 99999;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    font-size: 14px;
  `
  
  document.body.appendChild(indicator)
  
  setTimeout(() => {
    indicator.style.transition = "opacity 0.3s"
    indicator.style.opacity = "0"
    setTimeout(() => indicator.remove(), 300)
  }, 2000)
}

// Debug Turbo events
document.addEventListener("turbo:click", (event) => {
  console.log("Turbo click:", event.detail.url)
  showDebugMessage("🔵 Navigating...", "#3B82F6")
})

document.addEventListener("turbo:before-visit", (event) => {
  console.log("Turbo before-visit:", event.detail.url)
})

document.addEventListener("turbo:visit", (event) => {
  console.log("Turbo visit:", event.detail.url)
})

document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("Turbo before-fetch-request:", event.detail.url)
  showDebugMessage("⏳ Loading...", "#F59E0B")
})

document.addEventListener("turbo:before-fetch-response", (event) => {
  console.log("Turbo before-fetch-response:", event.detail.fetchResponse.response.url)
})

document.addEventListener("turbo:submit-start", (event) => {
  console.log("Turbo submit-start:", event.target)
  showDebugMessage("📤 Submitting...", "#8B5CF6")
})

document.addEventListener("turbo:submit-end", (event) => {
  console.log("Turbo submit-end:", event.detail.success)
  if (event.detail.success) {
    showDebugMessage("✅ Submitted", "#10B981")
  } else {
    showDebugMessage("❌ Submit failed", "#EF4444")
  }
})

document.addEventListener("turbo:before-render", (event) => {
  console.log("Turbo before-render")
})

document.addEventListener("turbo:render", (event) => {
  console.log("Turbo render")
})

document.addEventListener("turbo:load", (event) => {
  console.log("Turbo load - page loaded")
  showDebugMessage("✅ Page loaded", "#10B981")
})

document.addEventListener("turbo:frame-load", (event) => {
  console.log("Turbo frame-load:", event.target.id)
})