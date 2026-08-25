(function() {
    function closeSiblings(menu) {
        if (!menu) return;

        menu.parentElement.querySelectorAll(':scope > .dropdown > .dropdown-menu.show').forEach(function (openMenu) {
            if (openMenu !== menu) {
                openMenu.classList.remove('show');
                openMenu.closest('.dropdown')?.classList.remove('show');
            }
        });
    }

    function bindDeepDropdowns(navbar) {
        if (!navbar) return;

        var dropdowns = navbar.querySelectorAll('.dropdown');

        dropdowns.forEach(function (dropdown) {
            var trigger = dropdown.querySelector('[data-bs-toggle="dropdown"]');
            if (!trigger) return;

            trigger.addEventListener('click', function (event) {
                var menu = dropdown.querySelector(':scope > .dropdown-menu');
                if (!menu) return;

                var isNestedDropdown = dropdown.parentElement && dropdown.parentElement.closest('.dropdown-menu');
                if (isNestedDropdown) {
                    event.preventDefault();
                    event.stopPropagation();

                    closeSiblings(menu);
                    menu.classList.toggle('show');
                    dropdown.classList.toggle('show', menu.classList.contains('show'));
                    trigger.setAttribute('aria-expanded', String(menu.classList.contains('show')));
                    return;
                }

                if (window.innerWidth < 992) {
                    event.preventDefault();
                    event.stopPropagation();
                    var isOpen = menu.classList.contains('show');
                    closeSiblings(menu);
                    menu.classList.toggle('show', !isOpen);
                    dropdown.classList.toggle('show', !isOpen);
                    trigger.setAttribute('aria-expanded', String(!isOpen));
                }
            });

            if (window.matchMedia('(min-width: 992px)').matches) {
                dropdown.addEventListener('mouseenter', function () {
                    var menu = dropdown.querySelector(':scope > .dropdown-menu');
                    if (!menu) return;
                    dropdown.classList.add('show');
                    menu.classList.add('show');
                    trigger.setAttribute('aria-expanded', 'true');
                });

                dropdown.addEventListener('mouseleave', function () {
                    var menu = dropdown.querySelector(':scope > .dropdown-menu');
                    if (!menu) return;
                    dropdown.classList.remove('show');
                    menu.classList.remove('show');
                    trigger.setAttribute('aria-expanded', 'false');
                });
            }
        });
    }

    document.addEventListener('turbo:load', function () {
        var mainNavbar = document.getElementById('main_navbar');
        if (mainNavbar) {
            bindDeepDropdowns(mainNavbar);
        }
    });
})();
