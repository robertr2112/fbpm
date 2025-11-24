(function() {
    var defaults = {
        sm: 540,
        md: 720,
        lg: 960,
        xl: 1140,
        navbar_expand: 'lg',
        animation: true,
        animateIn: 'fadeIn',
    };

    function bootnavbar(options) {
        var screen_width = document.documentElement.clientWidth;
        var settings = Object.assign({}, defaults, options);
        var navElement = this; // The element on which bootnavbar() is called

        if (screen_width >= settings.lg) {
            var dropdowns = navElement.querySelectorAll('.dropdown');

            dropdowns.forEach(function(dropdown) {
                // Use 'mouseenter' and 'mouseleave' for hovering
                dropdown.addEventListener('mouseenter', function() {
                    this.classList.add('show');
                    var dropdownMenu = this.querySelector('.dropdown-menu');
                    if (dropdownMenu) {
                        dropdownMenu.classList.add('show');
                        if (settings.animation) {
                            dropdownMenu.classList.add('animated', settings.animateIn);
                        }
                    }
                });

                dropdown.addEventListener('mouseleave', function() {
                    this.classList.remove('show');
                    var dropdownMenu = this.querySelector('.dropdown-menu');
                    if (dropdownMenu) {
                        dropdownMenu.classList.remove('show');
                        // Remove animation classes on mouseleave
                        if (settings.animation) {
                            dropdownMenu.classList.remove('animated', settings.animateIn);
                        }
                    }
                });
            });
        }

        var dropdownToggles = navElement.querySelectorAll('.dropdown-menu a.dropdown-toggle');
        dropdownToggles.forEach(function(toggle) {
            toggle.addEventListener('click', function(e) {
                e.preventDefault(); // Prevent default link behavior

                var nextSibling = this.nextElementSibling;
                if (!nextSibling || !nextSibling.classList.contains('show')) {
                    // Find and hide other open sub-menus within the same parent
                    var parentMenu = this.closest('.dropdown-menu');
                    if (parentMenu) {
                        var shownMenus = parentMenu.querySelectorAll('.show');
                        shownMenus.forEach(function(menu) {
                            menu.classList.remove('show');
                        });
                    }
                }

                if (nextSibling) {
                    nextSibling.classList.toggle('show');
                }

                // Handle closing sub-menus when the main dropdown closes
                var parentDropdown = this.closest('li.nav-item.dropdown.show');
                if (parentDropdown) {
                    // This uses a custom event name as there's no native 'hidden.bs.dropdown' in vanilla JS this cleanly
                    // For Bootstrap compatibility, you might need their JS, but this handles simple class toggling.
                    // A simple solution is to clear all submenu shows when any main dropdown item is interacted with
                    // in a way that might close it. For this example, we'll omit the complex event listening.
                }
            });
        });
    }

    // Attach the bootnavbar function to the prototype of Element objects
    if (typeof Element !== 'undefined') {
        Element.prototype.bootnavbar = bootnavbar;
    }
})();

// Dropdown event handler for main navbar
document.addEventListener('turbo:load', function() {
    var mainNavbar = document.getElementById('main_navbar');
    if (mainNavbar) {
        mainNavbar.bootnavbar();
    }
});
