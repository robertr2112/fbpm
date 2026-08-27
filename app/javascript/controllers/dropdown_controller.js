import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSubmenu(event) {
    event.preventDefault()
    event.stopPropagation()

    const submenu = event.currentTarget.parentElement.querySelector(".dropdown-menu")
    if (!submenu) return

    const parentMenu = submenu.parentElement.parentElement
    Array.from(parentMenu.children).forEach((sibling) => {
      if (!sibling.classList.contains("dropdown-submenu")) return

      const siblingMenu = Array.from(sibling.children).find((child) =>
        child.classList.contains("dropdown-menu")
      )
      if (siblingMenu && siblingMenu !== submenu) {
        siblingMenu.classList.remove("show")
        sibling.classList.remove("show")
      }
    })

    const isOpen = submenu.classList.toggle("show")
    submenu.parentElement.classList.toggle("show", isOpen)
    event.currentTarget.setAttribute("aria-expanded", String(isOpen))
  }
}
