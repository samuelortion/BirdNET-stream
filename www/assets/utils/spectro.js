/**
 * Credits to:
 * https://codepen.io/jakealbaugh/pen/jvQweW
 */

// UPDATE: there is a problem in chrome with starting audio context
//  before a user gesture. This fixes it.
var started = false;
try {
  var spectro_button = document.getElementById('spectro-button');
  spectro_button.addEventListener('click', () => {
    if (started) return;
    started = true;
    console.log("starting spectro");
    initialize();
  })  
} catch {
  console.log("spectro not found");
}

function initialize() {
  const CVS = document.getElementById('spectro-canvas');
  const CTX = CVS.getContext('2d');
  const W = CVS.width = window.innerWidth;
  const H = CVS.height = window.innerHeight;

  const ACTX = new AudioContext();
  const ANALYSER = ACTX.createAnalyser();

  ANALYSER.fftSize = 4096;  
  
  navigator.mediaDevices
  .getUserMedia({ audio: true })
  .then(process);

  function process(stream) {
    const SOURCE = ACTX.createMediaStreamSource(stream);
    SOURCE.connect(ANALYSER);
    const DATA = new Uint8Array(ANALYSER.frequencyBinCount);
    const LEN = DATA.length;
    const h = H / LEN;
    const x = W - 1;
    CTX.fillStyle = 'hsl(280, 100%, 10%)';
    CTX.fillRect(0, 0, W, H);

    loop();

    function loop() {
      window.requestAnimationFrame(loop);
      let imgData = CTX.getImageData(1, 0, W - 1, H);
      CTX.fillRect(0, 0, W, H);
      CTX.putImageData(imgData, 0, 0);
      ANALYSER.getByteFrequencyData(DATA);
      for (let i = 0; i < LEN; i++) {
        let rat = DATA[i] / 255;
        let hue = Math.round((rat * 120) + 280 % 360);
        let sat = '100%';
        let lit = 10 + (70 * rat) + '%';
        CTX.beginPath();
        CTX.strokeStyle = `hsl(${hue}, ${sat}, ${lit})`;
        CTX.moveTo(x, H - (i * h));
        CTX.lineTo(x, H - (i * h + h));
        CTX.stroke();
      }
    }
  }
}
