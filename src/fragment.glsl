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
  float plasma = sin(
    // horizontal sinusoid
    sin(a.z) * 4. *
    sin(a.z + 1e1 * p.x) +

    // rotating sinusoid
    /*
    sin(a) * 4. *
    sin(a + 1e1 * p.x * sin(a / 1e1) + 1e1 * p.z * cos(a / 1e1)) +
    */

    // circular sinusoid
    sin(a.z) * 4. *
    sin(a.z + sqrt(
      // cx
      1e2 * pow(p.x + sin(a.z / 1e1), 2.) +
      // cy
      // used to be:
      // 1e2 * pow(p.y + cos(a.z / 1e1), 2.)
      1e2 * pow(p.y + sin(1e0 - a.z / 1e1), 2.)
    ))

    + b.z
  ); // / 2. + .5; // smaller plasma, always positive

  // cool alternatives
  //return vec3(plasma * (1e0 - cos(a / 2.)), 1e2 * sin(plasma) + a * 10., 2.);
  //return vec3(sin(a) * (length(p)-1e0) + plasma * (1e0 - cos(a / 2.)), 1e2 * sin(plasma) + a * 10., 2.);

  // TODO: cos varies between [-1, 1] and causes plasma to grow too high
  // ideas: sin^2(x) between [-1, 1]
  return vec3(length(p)-.5 + plasma * sin(a.z / 5e1), plasma + a.z, 2.);

  // shorter, worth investigating?
  //return vec3(length(p)-.5 + plasma * sin(a.z / 5e1));
}

void main() {
  // ray origin
  vec3 ro = vec3( sin(a.z), 1e0, sin(1e0 - a.z) ), // rotating
	cw = ro/length(ro),
	cu = cross(cw, b.yxy);

  // ray direction
  vec3 rd = mat3(
    cu,
    cross(cu, cw),
    -cw
  ) * vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y,
  e; // ray marcher temp result

  //cu.x = .5; // initial ray step amount

  // ray marcher
  for( float i=.0; i<1e1; i++ ) { // maxIterations
    cu += (e = map(cw = ro+rd*cu.x));
    if(e.x < -1e-4) break; // fixes "holes" in weird shapes
    if(e.x > 2e0) break;  // results in trippy background
  }

  // calculate normal from surface
  cu = vec3(.1, -.1, .3); // epsilon, z is unused
  cw =
    cu.xyy * map(cw + cu.xyy).x +
    cu.yyx * map(cw + cu.yyx).x +
    cu.yxy * map(cw + cu.yxy).x +
    cu.xxx * map(cw + cu.xxx).x;

  // Color vector (cu) should have high common denominator components
  //cu.x = .5;
  //cu.y++;

  // color of surface
  gl_FragColor = a.w * vec4(
      // material color
      sin(a.z * e.y * cu + b.z) +

      // diffuse lighting
      reflect(rd, cw / length(cw)).y
    // cheap vignette
    //* (2. - length(vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y))
    // fade in/out
    ,
  1./a.w);
}
