precision highp float;

// a.xy = resolution
// a.z = time variable (seconds / 10)
uniform vec4 a;

// b.x = 1
// b.y = 0
// b.z = kick drum volume
uniform vec4 b;

// x = distance to sdf
// y = material color
// z = unused
vec3 map(vec3 p) {
  /*
  float plasma = sin(
    // horizontal sinusoid
    //sin(a.z) * 4. *
    sin(a.z + 1e1 * p.x) + // * sqrt(
      //pow(p.x + sin(a.z / 1e1), 2.))) +

    // rotating sinusoid
    //sin(a) * 4. *
    //sin(a + 1e1 * p.x * sin(a / 1e1) + 1e1 * p.z * cos(a / 1e1)) +

    // circular sinusoid
    //sin(a.z) * 4. *
    sin(a.z + 1e1 * sqrt(
      // cx
      //pow(p.x + sin(a.z / 1e1), 2.) +
      // cy
      // used to be:
      // 1e2 * pow(p.y + cos(a.z / 1e1), 2.)
      pow(p.y + sin(b.x - a.z / 1e1), 2.)
    ))

    + b.z
  ); // / 2. + .5; // smaller plasma, always positive
  */

  // cool alternatives
  //return vec3(plasma * (b.x - cos(a / 2.)), 1e2 * sin(plasma) + a * 10., 2.);
  //return vec3(sin(a) * (length(p)-b.x) + plasma * (b.x - cos(a / 2.)), 1e2 * sin(plasma) + a * 10., 2.);

  // TODO: cos varies between [-1, 1] and causes plasma to grow too high
  // ideas: sin^2(x) between [-1, 1]
  //return vec3(length(p)-b.x + plasma * sin(a.z / 5e1), plasma + a.z, 2.);

  // shorter, worth investigating?
  return vec3(length(p)-1. +

  // This used to be the plasma variable
  sin(
    // horizontal sinusoid
    //sin(a.z) * 4. *
    sin(a.z + 1e1 * p.x) + // * sqrt(
      //pow(p.x + sin(a.z / 1e1), 2.))) +

    // rotating sinusoid
    /*
    sin(a) * 4. *
    sin(a + 1e1 * p.x * sin(a / 1e1) + 1e1 * p.z * cos(a / 1e1)) +
    */

    // circular sinusoid
    //sin(a.z) * 4. *
    sin(a.z + 1e1 * sqrt(
      // cx
      //pow(p.x + sin(a.z / 1e1), 2.) +
      // cy
      // used to be:
      // 1e2 * pow(p.y + cos(a.z / 1e1), 2.)
      pow(p.y + sin(b.x - a.z / 1e1), 2.)
    ))

    + b.z + a.z
  )

  * 0.1);
}

void main() {
  // ray origin
  //vec3 ro = vec3( sin(a.z), b.x, sin(b.x - a.z) ), // rotating
  //vec3 ro = b.xxy,
	vec3 e, // e = ray marcher temp result
	//cu = cross(cw, b.yxy);
  cu = b.xxx,

  // ray direction
  rd = mat3(
    b.xyx,
    //b.yxy,
    b.yxy,
    //cross(cu, cw),
    -b.xxy
  ) * vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y;

  //cu.x = .5; // initial ray step amount

  // ray marcher
  for( float i=1e0; i<1e1; i++ ) { // maxIterations
    if(e.x < 1e0) cu += (e = map(b.xxy+rd*cu.x));
    //if(e.x < -1e-4) break; // fixes "holes" in weird shapes
    //if(2e0 < e.x) break;  // results in trippy background
  }

  // calculate normal from surface
  //cu = vec3(.1, -.1, .3); // epsilon, z is unused
  // TODO: very crappy estimation of surface normals
  //cw =
    //cu.xyy * map(cw + cu.xyy).x +
    //cu.yyx * map(cw + cu.yyx).x +
    //cu.yxy * map(cw + cu.yxy).x +
    //cu.yyx * map(cw + cu.yyx).x;
    //cu.xxx * map(cw + cu.xxx).x;

  // Color vector (cu) should have high common denominator components
  //cu = vec3(.5, .3, .2); // epsilon, z is unused
  //cu.x = .5;
  //cu.y++;

  // color of surface
  gl_FragColor = a.w * vec4(
      // material color
      sin(e.y + sin(b.zyz))

      // diffuse lighting
      //0.01 * reflect(rd, cw / length(cw)).y
    // cheap vignette
    //* (2. - length(vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y))
    // fade in/out
    ,
  b.x/a.w);
}
