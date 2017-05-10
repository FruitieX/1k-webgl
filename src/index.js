// potato level for PC, higher = faster :-)
// TODO: remove in production
potato = 4;
c.width = 1920 / potato;
c.height = 1080 / potato;

// accumulators
bAcc = 0;
fAcc = 0;

r = t => {
  requestAnimationFrame(r, c);

  // run fft
  analyser.getByteFrequencyData(analyserArray);

  // set the "a" time variable
  g.uniform1f(g.getUniformLocation(P, 'a'), soundbox.audioCtx.currentTime);

  // set the "b" resolution variable
  g.uniform2f(g.getUniformLocation(P, 'b'), g.canvas.width, g.canvas.height);

  // set the "c" bass volume variable
  g.uniform1f(g.getUniformLocation(P, 'c'), analyserArray[11] / 255);
  // set the "d" treble volume variable
  g.uniform1f(g.getUniformLocation(P, 'd'), analyserArray[222] / 255);
  // accumulated bass
  g.uniform1f(g.getUniformLocation(P, 'e'), bAcc += analyserArray[11] / 1024);
  // frequency of lead synth
  g.uniform1f(g.getUniformLocation(P, 'f'), fAcc = 0.9 * fAcc + 0.1 * s.tracks[5][0].osc1.frequency.value);

  g.drawArrays(6,0,3); // g.TRIANGLE_FAN = 6
}

// music
s = new soundbox.MusicGenerator();
s.connect(soundbox.audioCtx.destination);
analyser = soundbox.audioCtx.createAnalyser();
analyserArray = new Uint8Array(analyser.frequencyBinCount);

// connect kick drum track, first column to analyser
s.tracks[0][0].out.connect(analyser);

// connect hihat drum track, first column to analyser
s.tracks[2][0].out.connect(analyser);

// onload
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
r();
s.play(song);
