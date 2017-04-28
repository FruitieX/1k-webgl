render = t => {
  window.requestAnimationFrame(render, canvas);

  // set the "r" resolution variable
  resolutionUniformLocation = gl.getUniformLocation(program, 'b');
  gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);

  // set the "time" variable
  timeUniformlocation = gl.getUniformLocation(program, 'a');
  gl.uniform1f(timeUniformlocation, t / 1000);

  positionLocation = gl.getAttribLocation(program, 'p');
  gl.enableVertexAttribArray(positionLocation);
  gl.vertexAttribPointer(positionLocation, 2, 5126, 0, 0, 0); // gl.FLOAT = 5126
  gl.drawArrays(4, 0, 6); // gl.TRIANGLES = 4
}

startMusic = _ => {
  // Initialize music generation (player).
  var player = new CPlayer();
  player.init(song);

  // Generate music...
  var done = false;
  setInterval(function () {
    if (done) {
      return;
    }

    done = player.generate() >= 1;

    if (done) {
      // Put the generated song in an Audio element.
      var wave = player.createWave();
      var audio = document.createElement("audio");
      audio.src = URL.createObjectURL(new Blob([wave], {type: "audio/wav"}));
      audio.play();
    }
  }, 0);
}

canvas        = document.getElementById('c');
gl            = canvas.getContext('webgl');

// potato level for PC, higher = faster :-)
// TODO: remove in production
potato = 8;
canvas.width  = 1920 / potato;
canvas.height = 1080 / potato;

// your problem if aspect ratio is incorrect
canvas.style='height: 100%; width: 100%';

// get rid of stupid body margin, FIXME: fewer bytes
body = document.getElementsByTagName('body')[0];
body.style='margin: 0';

gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);

buffer = gl.createBuffer();

// gl.ARRAY_BUFFER = 34962
gl.bindBuffer(34962, buffer);
gl.bufferData(
  34962,
  // TODO: optimize
  new Float32Array([
    -1.0, -1.0,
    1.0, -1.0,
    -1.0,  1.0,
    -1.0,  1.0,
    1.0, -1.0,
  1.0,  1.0]),
  gl.STATIC_DRAW
);

// vertex shader
v = 35633; // gl.VERTEX_SHADER = 35633
shaderSource = require('./vertex.glsl');
vertexShader = gl.createShader(v);
gl.shaderSource(vertexShader, shaderSource);
gl.compileShader(vertexShader);

// fragment shader
shaderSource = require('./fragment.glsl');
fragmentShader = gl.createShader(v-1); // gl.FRAGMENT_SHADER = 35632
gl.shaderSource(fragmentShader, shaderSource);
gl.compileShader(fragmentShader);

// Check for any compilation error
// TODO: remove in production
if (!gl.getShaderParameter(fragmentShader, 35713)) { // gl.COMPILE_STATUS = 35713
    alert(gl.getShaderInfoLog(fragmentShader));
}

program = gl.createProgram();

gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
gl.linkProgram(program);
gl.useProgram(program);

render();
startMusic();
