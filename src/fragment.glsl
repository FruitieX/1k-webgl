precision highp float;

// a.xy = resolution
// a.z = time variable (seconds / 10)
// a.w = fade variable
uniform vec4 a;

// b.x = 1
// b.y = 0
// b.z = kick drum volume
uniform vec4 b;

void main() {
  // ray marcher temp result
	vec3 e = b.yyy,
  cu = b.xxx,

  // ray direction
  rd = vec3(2. * gl_FragCoord.xy - a.xy, a.y) / a.y - cu;

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) {
    if(e.x < 1e0) // results in trippy background
      cu += (e =
				// x = distance to sdf
				// y = material color
				// z = unused
        vec3(
          // sphere
          length(b.xxz+rd*cu) - 1e0 +

          // plasma
          .1 * sin(b.z + 1e1 * rd.x*cu.x + a.z)
        )
      );
  }

  gl_FragColor = vec4(
    // material color
    a.w * sin(e.y + sin(b.zyz)),

		1e0
  );
}
