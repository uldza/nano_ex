const ScrollToBottom = {
  mounted() {
    this.scrollToBottom();
  },
  updated() {
    this.scrollToBottom();
  },
  scrollToBottom() {
    const container = this.el;
    console.log(container);
    container.scrollTop = container.scrollHeight;
  }
};

export default ScrollToBottom; 