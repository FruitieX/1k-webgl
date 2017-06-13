// cheap way of doing AA
//c.width = 3200, c.height = 1800; // 16:9 aspect ratio
c.width = 192, c.height = 108; // battery saving

f = new AudioContext;
a = f.createScriptProcessor(0x200, t = 1, K = 1);
a.connect(f.destination);

// sequencer thing
s=(notes,octave,rate,len) =>
  31 & t * Math.pow(2, notes[(t>>rate)%len] / 12 - octave)

// music debug
//t= 1744100
//t= 3744100
//t= 4744100

// music
X = a.onaudioprocess = audioEvent => {
  L = audioEvent.outputBuffer.getChannelData(i=0);

  for(;i++<0x200;t++) {
    // TODO: golf
    /*
    X = Math.max(0., Math.min(
      -Math.abs(++t/5e5 - 5) + 5,
    1e0)) // 5 = demo length
    */
    //X = t/1e5
    //if(!i) console.log(X);
    X = 1 // debug

    // kick drum with variation
    L[i] = (((K=1e4/(t&0x3fff*(
      (t>>15)%16 - 15 ? 1 : 0.75
    )))&1)*35)

    // bass
    + (s('7050',4,17,4)&0xff) / K;

    L[i] *= !(t>>22); // turn off above instruments after a while

    // LEFT CHANNEL
    // hihat TODO improve/golf envelope
    L[i] += ((t%150*t%130*t)&0x80)*Math.min(0.2, (1e1/((t>>3)%512))) * !!(t>>19)
    // arpeggio
    + (s((t>>17)%2 ? '027' : '037',1,13-(3*(t>>20)%12),4)) / K * !!(t>>20);

    L[i] *= X / 200;
    //if (L[i] > 1) console.log('clipping');

    // limit volume while testing
    //L[i] = Math.max(-0.5, Math.min(0.5, L[i]));
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
