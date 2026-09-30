// Mobile navigation toggle
document.addEventListener('DOMContentLoaded', function () {
  const toggleBtn = document.getElementById('navToggleBtn');
  const navMenu = document.getElementById('navLinksMenu');

  if (toggleBtn && navMenu) {
    toggleBtn.addEventListener('click', function () {
      const isExpanded = toggleBtn.getAttribute('aria-expanded') === 'true';
      toggleBtn.setAttribute('aria-expanded', !isExpanded);
      navMenu.classList.toggle('is-open');
    });

    // Close menu when clicking outside
    document.addEventListener('click', function (event) {
      if (!toggleBtn.contains(event.target) && !navMenu.contains(event.target)) {
        navMenu.classList.remove('is-open');
        toggleBtn.setAttribute('aria-expanded', 'false');
      }
    });
  }
});
