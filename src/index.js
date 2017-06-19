// cheap way of doing AA
c.width = 32e2, c.height = 18e2, // 16:9 aspect ratio
//c.width = 192, c.height = 108; // battery saving

b = new AudioContext;
a = b.createScriptProcessor(512, t = 1, K = 1);
a.connect(b.destination);

// bass & arpeggio sequencers
// (compresses better when inlined)

// s=(notes,octave,rate,len) =>
//   31 & t * Math.pow(2, notes[(t>>rate) % len] / 12 - octave)

t = 1500000;

// music
X = a.onaudioprocess = a =>
  a.outputBuffer.getChannelData(f=0).map(_ =>
    a.outputBuffer.getChannelData(0)[f++] =
    (
      (
        // kick drum
        ((
          // envelope
          K = 1e4 / (
            t & 16382
          )
        ) & 1) * 31

        // bass
        + (31 & t * Math.pow(2,
          // melody
          '7050'
        [(t>>
          // rate
          17
        ) %
          // melody length
          4
        ] / 12 -
          // octave
          4
        )) / K
      )

      // turn off above instruments after a while
      * !(t>>22)

      // hihat TODO improve/golf envelope
      + (t % 100 * t & 128) * Math.min(.2, 1e1 / ((t>>3) % 512))

      // enable hihat after t>>19
      * !!(t>>19)

      // arpeggio
      + (31 & t * Math.pow(2, (
        // melody
        ((t>>17) % 2 ? '027' : '037')
      )[(t>>(
        // rate
        13 - 3 * (t>>20) % 12
      )) %
        // melody length
        4
      ] / 12 -
        // octave
        1
      )) / K

      // enable arpeggio after t>>20
      * !!(t>>20)
    ) * (
      // fade out
      X = Math.min(Math.max(0, 1e1 - ++t / 5e5), 1)
    ) / 212
  );

// gfx
g = c.getContext`webgl`;
P = g.createProgram();

// NOTE: 2nd argument to drawArrays used to be 0, but undefined works
r = _ => g.drawArrays(g.TRIANGLE_FAN,
  // x-res, y-res, time (s), fade out
  g.uniform4f(g.getUniformLocation(P, 'a'), c.width, c.height, (t + 512e1 *(t >> 14)) / 5e5, X),
  3,
  // 1, 0, kick envelope, unused
  g.uniform4f(g.getUniformLocation(P, 'b'), 1, 1/K, t>>20, requestAnimationFrame(r))
);

// vertex shader
g.shaderSource(S=g.createShader(g.VERTEX_SHADER), require("./vertex.glsl"));
g.compileShader(S);g.attachShader(P,S);

// fragment shader
g.shaderSource(S=g.createShader(g.FRAGMENT_SHADER), require("./fragment.glsl"));
g.compileShader(S);g.attachShader(P,S);

// Log compilation errors
// if (!g.getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
//   throw g.getShaderInfoLog(S);
// }

g.bindBuffer(g.ARRAY_BUFFER, g.createBuffer(c.parentElement.style.margin = 0));
// 1st argument to enableVertexAttribArray used to be 0, but undefined works
// 1st argument to vertexAttribPointer used to be 0, but undefined works
g.vertexAttribPointer(
  g.enableVertexAttribArray(
    g.bufferData(g.ARRAY_BUFFER, Int8Array.of(-3, 1, 1, -3, 1, 1), g.STATIC_DRAW)
  ),
2, g.BYTE, r(c.style.height = '1e2vh'), g.linkProgram(P), g.useProgram(P));
