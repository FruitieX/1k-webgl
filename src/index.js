// cheap way of doing AA
c.width = 3200, c.height = 1800; // 16:9 aspect ratio

// onload
with(c.getContext('webgl')) {
  P = createProgram();

  // NOTE: 2nd argument to drawArrays used to be 0, but undefined works
  r = t => drawArrays(6,  // TRIANGLE_FAN = 6
    // Send resolution and time to shader
    uniform3f(getUniformLocation(P, 'a'), c.width, c.height, t / 1e4, requestAnimationFrame(r)),
    3
  );

  // vertex shader
  shaderSource(S=createShader(35633), require('./vertex.glsl')); // VERTEX_SHADER = 35633
  compileShader(S);attachShader(P,S);

  // fragment shader
  shaderSource(S=createShader(35632), require('./fragment.glsl')); // FRAGMENT_SHADER = 35632
  compileShader(S);attachShader(P,S);

  // Log compilation errors
  // if (!getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
  //   throw getShaderInfoLog(S);
  // }

  bindBuffer(34962, createBuffer(c.parentElement.style.margin = 0)); // ARRAY_BUFFER = 34962
  // 1st argument to enableVertexAttribArray used to be 0, but undefined works
  // 1st argument to vertexAttribPointer used to be 0, but undefined works
  vertexAttribPointer(
    enableVertexAttribArray(
      bufferData(34962, Int8Array.of(-3, 1, 1, -3, 1, 1), 35044) // 35044 = gl.STATIC_DRAW
    ),
  2, 5120, r(c.style.height = '100vh'), linkProgram(P), useProgram(P)); // BYTE = 5120
}

// generate music
for(var t=0,S='RIFF_oO_WAVEfmt '+atob('EAAAAAEAAQAcRwAAHEcAAAEACABkYXRh')+'data';++t<1e5;)S+=String.fromCharCode(eval(

// formula
'((((u=t&0x3fff)&0+((u+1<<(18+(t>>12&1*6)))/u)&255)/(u>>8))&240-128)'

// failsafe thing
+ '&255'
));

// play music
new Audio( 'data:audio/wav;base64,'+btoa(S) ).play();
/*
a = new AudioContext();

dly = a.createDelay();
osc1env = a.createGain();
osc1 = a.createOscillator();
lfo = a.createOscillator();

osc1.type = 'sawtooth';
osc1.frequency.value = 40;

lfo.type = 'sawtooth';
lfo.frequency.value = 2;
lfo.connect(osc1env.gain);

dly.delayTime.value = 2 / 3;

osc1.connect(osc1env);
osc1env.connect(a.destination);
osc1env.connect(dly);
dly.connect(a.destination);

lfo.start();
osc1.start();
*/
