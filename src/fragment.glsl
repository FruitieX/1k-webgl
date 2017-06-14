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
  // ray origin
  //vec3 ro = vec3( sin(a.z), b.x, sin(b.x - a.z) ), // rotating
  //vec3 ro = b.xxy,
	vec3 e = b.yyy, // e = ray marcher temp result
	//cu = cross(cw, b.yxy);
  cu = b.xxx,

  // ray direction
  rd = /*mat3(
    b.xyx,
    //b.yxy,
    b.yxy,
    //cross(cu, cw),
    -b.xxy
  ) * */-cu + vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y;

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) {
    if(e.x < 1e0) // results in trippy background
      cu += (e =

        // Used to be:
        // map(b.xxy+rd*cu)

				// x = distance to sdf
				// y = material color
				// z = unused
        vec3(
          // sphere
          length(b.xxy+rd*cu) - 1. +

          // plasma
          .1 * sin(
            // horizontal-ish sinusoid
            sin(1e1 * rd.x) +

            // circular-ish sinusoid
            //sin(1e1 * (p.y + sin(b.x - a.z / 1e1)))

            b.z + a.z
          )
        )
      );
  }

  // color of surface
  gl_FragColor = a.w * vec4(
    // material color
    sin(e.y + sin(b.zyz)),

    // fade in/out
    b.x/a.w
  );
}
