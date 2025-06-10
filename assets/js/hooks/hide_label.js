const HideLabel = {
  mounted() {
    // Find the closest form and then find the label within it
    const form = this.el.closest('form');
    const label = form.querySelector('label');
    
    if (label) {
      this.el.addEventListener('focus', () => {
        label.style.display = 'none';
      });
      
      this.el.addEventListener('blur', () => {
        if (!this.el.value) {
          label.style.display = 'block';
        }
      });
    }
  }
};

export default HideLabel; 