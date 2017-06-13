// cheap way of doing AA
c.width = 200, c.height = 120; // 16:9 aspect ratio

f = new AudioContext();
a = f.createScriptProcessor(512, t = 2, K = 2);
a.connect(f.destination);

// music
X = a.onaudioprocess = audioEvent => {
  L = audioEvent.outputBuffer.getChannelData(0);
  R = audioEvent.outputBuffer.getChannelData(1);

  L.map((sample, i) => {
    X = Math.max(0., Math.min(
      -Math.abs(++t/5e5 - 5) + 5,
    1e0)) // 5 = demo length
    //X = t/1e5
    //if(!i) console.log(X);
    //X = 1 // debug

    // sequencer thing
    S=(notes,octave,rate,len) =>
      31 & t * Math.pow(2, notes[(t>>rate)%len] / 12 - octave)
    // version which supports whitespace for silence
      // notes.charCodeAt((t>>rate)%len) - 32 // Is the note a whitespace?
      //   ? 31 & t * Math.pow(2, notes.charCodeAt((t>>rate)%len) / 12 - octave)
      //   : 0

    // kick drum with variation
    L[i] += (((K=1e4/(t&16383*(
      (t>>15)%16 - 15 ? 1 : 0.75
    )))&1)*35) * !(t>>22)

    // bass
    + (S('7050',4,17,4)&255) / K * !(t>>22);

    R[i] = L[i];

    // envelope
    E=Math.min(1, (1e1/((t>>5)%128))) * 0.2;

    // LEFT CHANNEL
    // hihat
    L[i] += (((t%100)*(t%100)*(t>>5))&128)*E * !!(t>>19)
    // sierpinski thing
    + ((t*(t>>11))&128)*E * !!(t>>20)
    // arpeggio
    + (!!(t/4&4096)*S((t>>17)%2 ? '027' : '037',1,11,3)*(4096-(t&4095))>>11) / K * !!(t>>21);
    //+ (t/4&4096?S((t>>17)%2 ? '027' : '037',5,11,3)*(4096-(t&4095))>>11 : 0) / K * !!(t>>21);

    // RIGHT CHANNEL
    // hihat
    R[i] += (((t%100)*(t%100)*(t>>4))&128)*E * !!(t>>19)
    // sierpinski thing
    + ((t*(t>>12))&128)*E * !!(t>>20)
    // arpeggio
    + (!!(t/4&4096)*S((t>>17)%2 ? '072' : '073',1,11,3)*(4096-(t&4095))>>11) / K * !!(t>>21);
    //+ (t/4&4096?S((t>>17)%2 ? '072' : '073',5,11,3)*(4096-(t&4095))>>11 : 0) / K * !!(t>>21);

    L[i] *= X / 200;
    R[i] *= X / 200;
    //if (L[i] > 1 || R[i] > 1) console.log('clipping');

    i; // *something* in the prod build removes i without this line: WTF TODO

    // limit volume while testing
    //L[i] = Math.max(-0.5, Math.min(0.5, L[i]));
    //R[i] = Math.max(-0.5, Math.min(0.5, R[i]));
  })
}

// gfx
g=c.getContext('webgl');

  P = g.createProgram();

  // NOTE: 2nd argument to drawArrays used to be 0, but undefined works
  r = time => g.drawArrays(6,  // TRIANGLE_FAN = 6
    // Send resolution and time to shader
    g.uniform4f(g.getUniformLocation(P, 'a'), c.width, c.height, time / 1e4, X),
    3,
    g.uniform4f(g.getUniformLocation(P, 'b'), c.width, c.height, .2/K, requestAnimationFrame(r))
  );

  // vertex shader
  g.shaderSource(S=g.createShader(35633), require('./vertex.glsl')); // VERTEX_SHADER = 35633
  g.compileShader(S);g.attachShader(P,S);

  // fragment shader
  g.shaderSource(S=g.createShader(35632), require('./fragment.glsl')); // FRAGMENT_SHADER = 35632
  g.compileShader(S);g.attachShader(P,S);

  // Log compilation errors
  // if (!getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
  //   throw getShaderInfoLog(S);
  // }

  g.bindBuffer(34962, g.createBuffer(c.parentElement.style.margin = 0)); // ARRAY_BUFFER = 34962
  // 1st argument to enableVertexAttribArray used to be 0, but undefined works
  // 1st argument to vertexAttribPointer used to be 0, but undefined works
  g.vertexAttribPointer(
    g.enableVertexAttribArray(
      g.bufferData(34962, Int8Array.of(-3, 1, 1, -3, 1, 1), 35044) // 35044 = gl.STATIC_DRAW
    ),
  2, 5120, r(c.style.height = '100vh'), g.linkProgram(P), g.useProgram(P)); // BYTE = 5120
