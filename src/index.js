// potato level for PC, higher = faster :-)
// TODO: remove in production
potato = 4;
c.width = 1920 / potato;
c.height = 1080 / potato;

r = t => {
  requestAnimationFrame(r, c);

  // set the "b" resolution variable
  g.uniform2f(g.getUniformLocation(P, 'b'), g.canvas.width, g.canvas.height);

  // set the "a" time variable
  g.uniform1f(g.getUniformLocation(P, 'a'), t / 1000);

  g.drawArrays(6,0,3); // g.TRIANGLE_FAN = 6
}

m = _ => {
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

// onload
l = () => {
  g = c.getContext('webgl');

  P = g.createProgram();

  // vertex shader
  g.shaderSource(S=g.createShader(35633), require('./vertex.glsl')); // g.VERTEX_SHADER = 35633
  g.compileShader(S);g.attachShader(P,S);

  // fragment shader
  g.shaderSource(S=g.createShader(35632), require('./fragment.glsl')); // g.FRAGMENT_SHADER = 35632
  g.compileShader(S);g.attachShader(P,S);

  // Check for any compilation error
  // TODO: remove in production
  if (!g.getShaderParameter(S, 35713)) { // g.COMPILE_STATUS = 35713
      alert(g.getShaderInfoLog(S));
  }

  g.linkProgram(P);
  g.useProgram(P);

  // g.ARRAY_BUFFER = 34962
  g.bindBuffer(34962, g.createBuffer());
  g.bufferData(34962, new Int8Array([-3,1,1,-3,1,1]),35044); // 35044 = gl.STATIC_DRAW
  g.enableVertexAttribArray(0);
  g.vertexAttribPointer(0,2,5120,0,0,0); // g.BYTE = 5120

  // start rendering and music playback
  r();m();
}
