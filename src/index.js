// cheap way of doing AA
c.width = 192, c.height = 108; // 16:9 aspect ratio

f = new AudioContext;
a = f.createScriptProcessor(0x200, t = 1, K = 1);
a.connect(f.destination);

// music
X = a.onaudioprocess = audioEvent => {
  L = audioEvent.outputBuffer.getChannelData(i=0);
  //R = audioEvent.outputBuffer.getChannelData(1);

  //L.map((sample, i) => {
  for(;i++<0x200;) {
  //for(;i++<L.length;) {
    // TODO: golf
    // debug: set Math.max(x <- to 0 when done
    /*
    X = Math.max(0., Math.min(
      -Math.abs(++t/5e5 - 5) + 5,
    1e0)) // 5 = demo length
    */
    //X = t/1e5
    //if(!i) console.log(X);
    ++t;
    X = 1 // debug

    // sequencer thing
    S=(notes,octave,rate,len) =>
      31 & t * Math.pow(2, notes[(t>>rate)%len] / 12 - octave)
    // version which supports whitespace for silence
      // notes.charCodeAt((t>>rate)%len) - 32 // Is the note a whitespace?
      //   ? 31 & t * Math.pow(2, notes.charCodeAt((t>>rate)%len) / 12 - octave)
      //   : 0

    // kick drum with variation
    L[i] = (((K=1e4/(t&0x3fff*(
      (t>>15)%16 - 15 ? 1 : 0.75
    )))&1)*35)

    // bass
    + (S('7050',4,17,4)&0xff) / K;

    L[i] *= !(t>>22);
    //R[i] = L[i];

    // hihat envelope TODO: golf
    //E=Math.min(1, (1e1/((t>>5)%0x80))) * 0.2;
    E=Math.min(0.2, (1e1/((t>>3)%512)));
    //if (i<2) console.log(t>>1);

    // LEFT CHANNEL
    // hihat
    L[i] += (((t%100)*(t%100)*(t>>5))&0x80)*E * !!(t>>19)
    // sierpinski thing
    //+ ((t*(t>>11))&0x80)*E * !!(t>>20)
    //+ ((t*(t>>11))&128)*E * !!(t>>20)
    // arpeggio
    //+ (!!(t/4&0x1000)*S((t>>17)%2 ? '027' : '037',1,11,3)*(0x1000-(t&0xfff))>>11) / K * !!(t>>21);
    + (!!(t/4&0x1000)*S((t>>17)%2 ? '027' : '037',1,10,4)) / K * !!(t>>21);
    //+ (t/4&4096?S((t>>17)%2 ? '027' : '037',5,11,3)*(4096-(t&4095))>>11 : 0) / K * !!(t>>21);

    // RIGHT CHANNEL
    // hihat
    /*
    R[i] += (((t%100)*(t%100)*(t>>4))&128)*E * !!(t>>19)
    // sierpinski thing
    + ((t*(t>>12))&128)*E * !!(t>>20)
    // arpeggio
    + (!!(t/4&4096)*S((t>>17)%2 ? '072' : '073',1,11,3)*(4096-(t&4095))>>11) / K * !!(t>>21);
    //+ (t/4&4096?S((t>>17)%2 ? '072' : '073',5,11,3)*(4096-(t&4095))>>11 : 0) / K * !!(t>>21);
    */

    L[i] *= X / 200;
    //R[i] *= X / 200;
    //if (L[i] > 1 || R[i] > 1) console.log('clipping');

    //i; // *something* in the prod build removes i without this line: WTF TODO

    // limit volume while testing
    //L[i] = Math.max(-0.5, Math.min(0.5, L[i]));
    //R[i] = Math.max(-0.5, Math.min(0.5, R[i]));
  }
}

// gfx
g=c.getContext`webgl`;
P = g.createProgram();

// NOTE: 2nd argument to drawArrays used to be 0, but undefined works
r = time => g.drawArrays(g.TRIANGLE_FAN,
  // Send resolution and time to shader
  g.uniform4f(g.getUniformLocation(P, 'a'), c.width, c.height, time / 1e3, X),
  3,
  g.uniform4f(g.getUniformLocation(P, 'b'), 1, 0, .2/K, requestAnimationFrame(r))
);

// vertex shader
g.shaderSource(S=g.createShader(g.VERTEX_SHADER), require('./vertex.glsl'));
g.compileShader(S);g.attachShader(P,S);

// fragment shader
g.shaderSource(S=g.createShader(g.FRAGMENT_SHADER), require('./fragment.glsl'));
g.compileShader(S);g.attachShader(P,S);

// Log compilation errors
// if (!getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
//   throw getShaderInfoLog(S);
// }

g.bindBuffer(g.ARRAY_BUFFER, g.createBuffer(c.parentElement.style.margin = 0));
// 1st argument to enableVertexAttribArray used to be 0, but undefined works
// 1st argument to vertexAttribPointer used to be 0, but undefined works
g.vertexAttribPointer(
  g.enableVertexAttribArray(
    g.bufferData(g.ARRAY_BUFFER, Int8Array.of(-3, 1, 1, -3, 1, 1), g.STATIC_DRAW)
  ),
2, g.BYTE, r(c.style.height = '100vh'), g.linkProgram(P), g.useProgram(P));
