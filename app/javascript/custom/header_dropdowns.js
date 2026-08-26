(function() {
    function closeSiblingMenus(menu) {
        var parentMenu = menu && menu.parentElement;
        if (!parentMenu) return;

        parentMenu.querySelectorAll(':scope > .dropdown > .dropdown-menu.show').forEach(function(openMenu) {
            if (openMenu !== menu) {
                openMenu.classList.remove('show');
                var siblingDropdown = openMenu.closest('.dropdown');
                if (siblingDropdown) {
                    siblingDropdown.classList.remove('show');
                    var siblingToggle = siblingDropdown.querySelector('[data-bs-toggle="dropdown"]');
                    if (siblingToggle) {
                        siblingToggle.setAttribute('aria-expanded', 'false');
                    }
                }
            }
        });
    }

    function bindDropdowns(navbar) {
        if (!navbar || navbar.dataset.dropdownHandlersBound === 'true') return;
        navbar.dataset.dropdownHandlersBound = 'true';

        navbar.querySelectorAll('.dropdown').forEach(function(dropdown) {
            var toggle = dropdown.querySelector(':scope > [data-bs-toggle="dropdown"]');
            var menu = dropdown.querySelector(':scope > .dropdown-menu');
            var isNested = dropdown.parentElement && dropdown.parentElement.closest('.dropdown-menu');

            if (!toggle || !menu) return;

            // Bootstrap handles top-level clicks. Nested menus need propagation
            // stopped so Bootstrap does not close their parent menu.
            if (isNested) {
                toggle.addEventListener('click', function(event) {
                    event.preventDefault();
                    event.stopPropagation();

                    var isOpen = menu.classList.contains('show');
                    closeSiblingMenus(menu);
                    menu.classList.toggle('show', !isOpen);
                    dropdown.classList.toggle('show', !isOpen);
                    toggle.setAttribute('aria-expanded', String(!isOpen));
                });
            }

        });
    }

    document.addEventListener('turbo:load', function() {
        bindDropdowns(document.getElementById('main_navbar'));
    });
})();
