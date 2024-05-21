document.addEventListener('DOMContentLoaded', () =>{
  const menuContents = document.querySelectorAll('#menu-content');
  menuContents.forEach(menuContent => {
    menuContent.style.height = `${window.outerHeight}px`;
  });
});