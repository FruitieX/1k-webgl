precision highp float;

// a.xy = resolution
// a.z = time
// a.w = fade
uniform vec4 a;

// b.x = 1
// b.y = kick drum volume
// b.z = t>>17
uniform vec4 b;

void main() {
  // ray marcher temp result
	vec3 e = -b.xxx,
  cu = -b.xxx + sin(a.z),

  // ray direction
  rd = vec3(2. * gl_FragCoord.xy - a.xy, a.y) / a.y - cu;

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) {
    cu += (e =
      // sphere
      length(sin(cu))

      // plasma
      + sin(b.z + rd*cu) / 2.
    );
  }

  gl_FragColor = vec4(
    // material color
    a.w * sin(sin(-a.xyw + a.z) / 4. + a.z * e.y + a.z + b.y),

		1e0
  );
}
