document.addEventListener('DOMContentLoaded', () =>{
  const menuContents = document.querySelectorAll('#menu-content html body');
  menuContents.forEach(menuContent => {
    menuContent.style.height = `${window.outerHeight}px`;
  });
});