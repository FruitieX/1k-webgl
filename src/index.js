// cheap way of doing AA
c.width = 800, c.height = 480; // 16:9 aspect ratio

f = new AudioContext();
a = f.createScriptProcessor(512, 2, 2);
a.connect(f.destination);

t = 0;
fade = 0;
y = 0;

// music
a.onaudioprocess = e =>
{
  left = e.outputBuffer.getChannelData(0);
  right = e.outputBuffer.getChannelData(1);

  left.map((e, i) =>
  {
    t++;
    fade = Math.max(0., Math.min(
      -Math.abs(t/5e5 - 5) + 5,
    1e0)) // 5 = demo length
    //if(!i) console.log(t/5e5 - 5);
    //fade = 1 // debug

    // synth thing
    S=(notes,octave,rate,len) =>
      notes.charCodeAt((t>>rate)%len) - 32 // Is the note a whitespace?
        ? 31 & t * Math.pow(2, notes.charCodeAt((t>>rate)%len) / 12 - octave)
        : 0

    // kick drum with variation
    left[i] += (((y=1e4/(t&16383*(
      (t>>15)%16 - 15 ? 1 : 0.75
    )))&1)*35) * !(t>>22);
    right[i] = left[i];

    // bass
    left[i] += (S("7050",8,17,4)&255) / y * !(t>>22);
    right[i] += (S("7050",8,17,4)&255) / y * !(t>>22);

    // envelope
    envelope=Math.min(1, (2e1/((t>>4)%256))) * 0.2;

    // hihat
    left[i] += (((t%100)*(t%100)*(t>>5))&128)*envelope * !!(t>>19);
    right[i] += (((t%100)*(t%100)*(t>>4))&128)*envelope * !!(t>>19);

    // sierpinski thing
    left[i] += ((t*(t>>11))&128)*envelope * !!(t>>20);
    right[i] += ((t*(t>>12))&128)*envelope * !!(t>>20);

    // arpeggio
    left[i] += (t/4&4096?S((t>>17)%2 ? '027' : '037',5,11,3)*(4096-(t&4095))>>11 : 0) / y * !!(t>>21);
    right[i] += (t/4&4096?S((t>>17)%2 ? '072' : '073',5,11,3)*(4096-(t&4095))>>11 : 0) / y * !!(t>>21);

    left[i] *= fade;
    right[i] *= fade;

    // limit volume while testing
    left[i] /= 255;
    right[i] /= 255;
    //left[i] = Math.max(-0.5, Math.min(0.5, left[i]));
    //right[i] = Math.max(-0.5, Math.min(0.5, right[i]));
  })
}

// gfx
with(c.getContext('webgl')) {
  P = createProgram();

  // NOTE: 2nd argument to drawArrays used to be 0, but undefined works
  r = time => drawArrays(6,  // TRIANGLE_FAN = 6
    // Send resolution and time to shader
    uniform4f(getUniformLocation(P, 'a'), c.width, c.height, time / 1e4, fade),
    3,
    uniform4f(getUniformLocation(P, 'b'), c.width, c.height, 1/y, requestAnimationFrame(r))
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
