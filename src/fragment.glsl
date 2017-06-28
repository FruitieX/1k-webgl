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
	vec3 e = b.xxx,
  cu = -e + sin(a.z + b.z),

  // ray direction
  rd = gl_FragCoord.xyz / a.y - a.xyz / a.y + cu;

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) {
    cu += (e =
      // sphere
      sin(sin(rd*cu) + length(sin(rd*cu))) * b.z / 8.

      // plasma
      //+ sin(rd) * b.z / 8.
    );
  }

  gl_FragColor = vec4(
    // material color
    a.w * sin(sin(a.xyw + a.z + b.y) / 8. + e.y),

		1e0
  );
}
