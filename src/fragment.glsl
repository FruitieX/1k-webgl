precision highp float;

// a.xy = resolution
// a.z = time variable (seconds / 10)
uniform vec3 a;

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
  ); // / 2. + .5; // smaller plasma, always positive

  // cool alternatives
  //return vec2(plasma * (1e0 - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);
  //return vec2(sin(a) * (length(p)-1e0) + plasma * (1e0 - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);

  // TODO: cos varies between [-1, 1] and causes plasma to grow too high
  // ideas: sin^2(x) between [-1, 1]
  return vec3(length(p)-.5 + plasma * sin(a.z / 1e2), plasma + a.z, 2.);

  // shorter, worth investigating?
  //return vec3(length(p)-.5 + plasma * sin(a.z / 1e2));
}

void main() {
  // ray origin
  vec3 ro = vec3( sin(1e0 - a.z), 1e0, sin(a.z) ), // rotating
	cw = normalize(-ro),
	cu = cross(cw, vec3(.0, 1e0, .0));

  // ray direction
  vec3 rd = mat3(
    cu,
    cross(cu, cw),
    cw
  ) * vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y;

  cu.x = .5; // initial ray step amount

  // ray marcher
  vec3 e; // result
  for( float i=.0; i<1e1; i++ ) { // maxIterations
    cu += (e = map(cw = ro+rd*cu.x));
    if(e.x < -1e-4) break; // fixes "holes" in weird shapes
    if(e.x > 1e0) break;  // results in trippy background
  }

  // calculate normal from surface
  cu = vec3(.1, -.1, .5); // epsilon, z is unused
  cw = normalize(
    cu.xyy * map(cw + cu.xyy).x +
    cu.yyx * map(cw + cu.yyx).x +
    cu.yxy * map(cw + cu.yxy).x +
    cu.xxx * map(cw + cu.xxx).x
  );

  // TODO: color vector (cu) should have high common denominator components
  // but normal calculations need equal but opposite xy components
  //cu.y = .3;

  // color of surface
  gl_FragColor = vec4(
    (
      // material color
      sin(a.z * e.y * cu) +

      // diffuse lighting
      reflect(rd, cw).y
    )
    // cheap vignette
    * (2. - length(vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y))
    // fade in/out
    //* clamp(0., (-abs(a.z - 1e1) + 1e1), 1e0)
    ,
  1e0);
}
