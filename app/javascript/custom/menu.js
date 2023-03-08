// Menu manipulation
function addToggleListener(buttonId, menuId, toggleClass) {
  let button = document.querySelector(`#${buttonId}`);
  button.addEventListener('click', function(event) {
    event.preventDefault();
    let menu = document.querySelector(`#${menuId}`);
    menu.classList.toggle(toggleClass);
  });
}

// Add toggle listeners to listen for clicks.
document.addEventListener('turbo:load', function() {
  addToggleListener('hamburger', 'navbar-menu', 'collapse');
  addToggleListener('account', 'dropdown-menu', 'active');
});