precision highp float;

// a.xy = resolution
// a.z = time variable (seconds / 10)
uniform vec3 a;

vec2 map(vec3 p) {
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
      1e2 * pow(p.y + cos(a.z / 1e1), 2.)
    ))
  ); // / 2. + .5; // smaller plasma, always positive

  // cool alternatives
  //return vec2(plasma * (1. - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);
  //return vec2(sin(a) * (length(p)-1.) + plasma * (1. - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);

  // TODO: cos varies between [-1, 1] and causes plasma to grow too high
  // ideas: sin^2(x) between [-1, 1]
  return vec2(length(p)-.5 + plasma * sin(a.z / 1e2), sin(plasma) + a.z);
}

void main() {
  // ray origin
  vec3 ro = vec3( sin(1. - a.z), 1e0, sin(a.z) ), // rotating
	cw = normalize(-ro),
	cu = cross(cw, vec3(.0, 1e0, .0));

  // ray direction
  vec3 rd = mat3(
    cu,
    cross(cu, cw),
    cw
  ) * vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y;

  float t = .5; // initial ray step amount
        //mat; // material

  // ray marcher
  vec2 e; // result
  for( float i=.0; i<1e1; i++ ) { // maxIterations
    e = map(cw = ro+rd*t);
    t += e.x;
    //mat = e.y;
    if(e.x < -1e-4) break; // fixes "holes" in weird shapes
    if(e.x > 1e0) break;  // results in trippy background
  }

  // calculate normal from surface
  cu = vec3(.1, -.1, 2.); // epsilon, z is unused
  cw = normalize(
    cu.xyy * map(cw + cu.xyy).x +
    cu.yyx * map(cw + cu.yyx).x +
    cu.yxy * map(cw + cu.yxy).x +
    cu.xxx * map(cw + cu.xxx).x
  );

  // color of surface
  gl_FragColor = vec4(
    (
      // material color
      sin(e.y * vec3(3., 2., 1.)) +

      // diffuse lighting
      vec3(reflect(rd, cw).y)
    )
    // cheap vignette
    * (2. - length(vec3(-a.xy + 2. * gl_FragCoord.xy, a.y) / a.y))
    // fade in/out
    //* clamp(0., (-abs(a - 1e1) + 1e1), 1.)
    ,
  1.);
}
