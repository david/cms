// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const Hooks = {
  Sidebar: {
    mounted() {
      this.el.addEventListener("click", (e) => {
        if (e.target.closest("a")) {
          this.el.parentElement.querySelector(".drawer-toggle").checked = false
        }
      })
    }
  },

  DatalistPopulator: {
    mounted() {
      this.el.addEventListener("input", (event) => {
        const textInput = event.target;
        const selected = Array.
          from(textInput.list.options).
          find(option => option.value === textInput.value);

        const hiddenInput = document.getElementById(textInput.dataset.inputId);
        const oldValue = hiddenInput.value;
        const newValue = selected ? selected.dataset.id : "";

        if (oldValue !== newValue) {
          hiddenInput.value = newValue;
          hiddenInput.dispatchEvent(new Event("change", { bubbles: true }));
        }
      });
    }
  },

  FontSizeApplier: {
    mounted() {
      document.getElementById("liturgy-increase-font-size").
        addEventListener("click", () => this.applyFontSize(+1));

      document.getElementById("liturgy-decrease-font-size").
        addEventListener("click", () => this.applyFontSize(-1));

      this.applyFontSize();
    },

    updated() {
      this.applyFontSize();
    },

    applyFontSize(delta) {
      let fontSize = this.getCurrentFontSize();

      if (!isNaN(delta) && delta != 0) {
        fontSize += delta;

        this.setCurrentFontSize(fontSize);
      }

      console.log("Font size is now " + fontSize);

      this.el.style.fontSize = `${fontSize}px`;
    },

    setCurrentFontSize(currentFontSize) {
      localStorage.setItem("liturgy-font-size", currentFontSize);
    },

    getCurrentFontSize() {
      let currentFontSize = parseInt(localStorage.getItem("liturgy-font-size"));

      if (isNaN(currentFontSize)) {
        currentFontSize =
          parseInt(window.getComputedStyle(document.body).getPropertyValue("font-size"));
      }

      return currentFontSize;
    }
  }
};

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

let deferredPrompt;

function isIos() {
  const userAgent = window.navigator.userAgent.toLowerCase();
  return /iphone|ipad|ipod/.test(userAgent);
}

// Function to detect if the device is likely mobile
function isMobileDevice() {
  return ('ontouchstart' in window || navigator.maxTouchPoints > 0 || navigator.msMaxTouchPoints > 0) &&
         window.innerWidth <= 768; // Adjust max width as needed for your definition of "mobile"
}

window.addEventListener('beforeinstallprompt', (e) => {
  console.log("beforeinstallprompt fired");
  e.preventDefault();
  deferredPrompt = e;

  if (!isMobileDevice()) {
    console.log("Not a mobile device, not showing banner.");
    return;
  }

  if (window.matchMedia('(display-mode: standalone)').matches) {
    console.log("App is already installed (standalone mode), not showing banner.");
    return;
  }

  // Check if the user has previously dismissed the banner
  if (localStorage.getItem('pwa-banner-dismissed') === 'true') {
    console.log("Banner previously dismissed, not showing.");
    return;
  }

  showInstallPromotion();
});

window.addEventListener('appinstalled', () => {
  console.log("App installed event fired.");
  hideInstallPromotion();
  // Clear the deferredPrompt so it can be garbage collected
  deferredPrompt = null;
  // Remove the dismissal flag as the app is now installed
  localStorage.removeItem('pwa-banner-dismissed');
});

function showInstallPromotion() {
  console.log("Attempting to show install promotion.");
  const installBanner = document.getElementById('pwa-install-banner');
  if (installBanner) {
    installBanner.classList.remove('hidden');
    console.log("Install banner shown.");
  }
}

function hideInstallPromotion() {
  console.log("Attempting to hide install promotion.");
  const installBanner = document.getElementById('pwa-install-banner');
  if (installBanner) {
    installBanner.classList.add('hidden');
    // Set a flag in localStorage to remember the dismissal
    localStorage.setItem('pwa-banner-dismissed', 'true');
    console.log("Install banner hidden and dismissal remembered.");
  }
}

function showIosInstallPromotion() {
  console.log("Attempting to show iOS install promotion.");
  const installBanner = document.getElementById('pwa-ios-install-banner');
  if (installBanner) {
    installBanner.classList.remove('hidden');
    console.log("iOS Install banner shown.");
  }
}

function hideIosInstallPromotion() {
  console.log("Attempting to hide iOS install promotion.");
  const installBanner = document.getElementById('pwa-ios-install-banner');
  if (installBanner) {
    installBanner.classList.add('hidden');
    // Set a flag in localStorage to remember the dismissal
    localStorage.setItem('pwa-banner-dismissed', 'true');
    console.log("iOS Install banner hidden and dismissal remembered.");
  }
}

async function handleInstallClick() {
  if (deferredPrompt) {
    // Show the install prompt
    deferredPrompt.prompt();
    // Wait for the user to respond to the prompt
    const { outcome } = await deferredPrompt.userChoice;
    // Optionally, send analytics event with outcome of user choice
    console.log(`User response to the install prompt: ${outcome}`);
    // We've used the prompt, and can't use it again, so clear it
    deferredPrompt = null;
    hideInstallPromotion();
  }
}

if (process.env.NODE_ENV === "production" && 'serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    if (isIos() && !window.matchMedia('(display-mode: standalone)').matches) {
      if (localStorage.getItem('pwa-banner-dismissed') !== 'true') {
        showIosInstallPromotion();
      }
    }

    navigator.serviceWorker.register('/sw.js')
      .then(registration => {
        console.log('ServiceWorker registration successful with scope: ', registration.scope);
      })
      .catch(err => {
        console.log('ServiceWorker registration failed: ', err);
      });
  });
}

// Expose handleInstallClick to the global scope or a LiveView hook if needed
window.handleInstallClick = handleInstallClick;
window.hideInstallPromotion = hideInstallPromotion;
window.hideIosInstallPromotion = hideIosInstallPromotion;
