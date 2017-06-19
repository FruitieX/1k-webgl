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
  cu = -b.xxx,

  // ray direction
  rd = vec3(2. * gl_FragCoord.xy - a.xy, a.y) / a.y - cu;

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) {
    //if(e.x < 1e0) // results in trippy background
      cu += (e =
        // sphere
        length(rd*cu) - 1e0

        // plasma
        + sin(b.xyz + 1e1 * a.z + 1e1 * rd*cu) / 1e1
      );
  }

  gl_FragColor = vec4(
    // material color
    a.w * sin((a.zww * b.zyz) / 1e1 + e.y),

		1e0
  );
}
