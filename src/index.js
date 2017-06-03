w = 1920, h = 1080;

r = t => {
  requestAnimationFrame(r, c);
  g.uniform2f(g.getUniformLocation(P, 'b'), w, h)

  g.drawArrays(6,
    // 2nd argument to g.drawArrays used to be 0, but undefined works
    // set the "a" time variable
    g.uniform1f(g.getUniformLocation(P, 'a'), t / 1e4),
    3
  ); // g.TRIANGLE_FAN = 6
  //c.style = 'margin:-8';
}
c.width = w, c.height = h;

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
// if (!g.getShaderParameter(S, 35713)) { // g.COMPILE_STATUS = 35713
//     alert(g.getShaderInfoLog(S));
// }

g.bindBuffer(34962, g.createBuffer()); // g.ARRAY_BUFFER = 34962
// 1st argument to g.enableVertexAttribArray used to be 0, but undefined works
// 1st argument to g.vertexAttribPointer used to be 0, but undefined works
g.vertexAttribPointer(
  g.enableVertexAttribArray(
    g.bufferData(34962, Int8Array.of(-3,1,1,-3,1,1),35044) // 35044 = gl.STATIC_DRAW
  ),
2,5120,r(),g.linkProgram(P),g.useProgram(P)); // g.BYTE = 5120

// used to call r(0) here, but we do it above to save a byte or two
// NOTE: first frame is going to be borken as a result
