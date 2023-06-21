const canvas = document.getElementById('cursor_canvas');
const canvasContext = canvas.getContext('2d');
const state = {
  mousedown: false,
};

export default {
  mounted() {
    canvas.addEventListener('mousedown', this.handleWritingStart.bind(this));
    canvas.addEventListener('mousemove', this.handleWritingInProgress.bind(this));

    canvas.addEventListener('touchstart', this.handleWritingStart.bind(this));
    canvas.addEventListener('touchmove', this.handleWritingInProgress.bind(this));
  },
  handleWritingStart(event) {
    event.preventDefault();

    this.pushNewCursorPosition(event);
    state.mousedown = true;
  },
  handleWritingInProgress(event) {
    event.preventDefault();

    if (state.mousedown) {
      this.pushNewCursorPosition(event);
    }
  },
  pushNewCursorPosition(event) {
    const clientX = event.clientX || event.touches[0].clientX;
    const clientY = event.clientY || event.touches[0].clientY;
    const { offsetLeft, offsetTop } = event.target;
    const canvasX = clientX - offsetLeft;
    const canvasY = clientY - offsetTop;
    
    this.pushEvent("cursor_position", {x: canvasX, y: canvasY})
  },
};
