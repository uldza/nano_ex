const OpenHide = {
    mounted() {
      const dropdown = document.getElementById(this.el.dataset.el);
      
      if (dropdown) {
        this.el.addEventListener('click', () => {
          dropdown.classList.toggle('hidden');
        });
      }
    }
  };
  
  export default OpenHide; 