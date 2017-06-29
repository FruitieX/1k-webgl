precision highp float;

// a.xy = resolution
// a.z = time
// a.w = fade
uniform vec4 a;

// b.x = 1
// b.y = kick drum volume
// b.z = t>>18
uniform vec4 b;

void main() {
  // ray marcher temp result
	vec3 e = b.xxx,
  cu = -e + sin(a.z + b.z),

  // ray direction
  rd = (gl_FragCoord.xyz - a.xyz) * 2. / a.y + cu;

  // ray marcher
  for( int f=0; f<1e1; f++ ) {
    // plasma + sphere
    cu += e = sin(sin(rd*cu) + length(sin(rd*cu)));
  }

  gl_FragColor = vec4(
    // material color
    a.w * sin(sin(sin(a.z + a.xyw + e.y) * a.z + b.y) / 1e1 + e.y),

		1e0
  );
}
