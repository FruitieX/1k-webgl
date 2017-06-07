precision highp float;

// time variable (seconds)
uniform float a;
// res
uniform vec2 b;

vec2 map(vec3 p) {
  float plasma = sin(
    // horizontal sinusoid
    sin(a) * 4. *
    sin(a + 1e1 * p.x) +

    // rotating sinusoid
    /*
    sin(a) * 4. *
    sin(a + 1e1 * p.x * sin(a / 1e1) + 1e1 * p.z * cos(a / 1e1)) +
    */

    // circular sinusoid
    sin(a) * 4. *
    sin(a + sqrt(
      // cx
      1e2 * pow(p.x + sin(a / 1e1), 2.) +
      // cy
      1e2 * pow(p.y + cos(a / 1e1), 2.)
    ))
  ); // / 2. + .5; // smaller plasma, always positive

  // cool alternatives
  //return vec2(plasma * (1. - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);
  //return vec2(sin(a) * (length(p)-1.) + plasma * (1. - cos(a / 2.)), 1e2 * sin(plasma) + a * 10.);

  // TODO: cos varies between [-1, 1] and causes plasma to grow too high
  // ideas: sin^2(x) between [-1, 1]
  return vec2(length(p)-.5 + plasma * sin(a / 1e2), sin(plasma) + a);
}

void main() {
  // camera
  vec3 ro = vec3( sin(1. - a), 1e0, sin(a) ), // rotating
	cw = normalize(-ro),
	cu = cross(cw, vec3(.0, 1e0, .0));

  // ray direction
  vec3 rd = mat3(
    cu,
    cross(cu, cw),
    cw
  ) * vec3(-b + 2. * gl_FragCoord.xy, b.y) / b.y;

  float t = .5, // initial ray step amount
        mat; // material

  vec2 e;
  for( float i=.0; i<1e1; i++ ) { // maxIterations
    e = map(cw = ro+rd*t);
    t += e.x;
    mat = e.y;
    if(e.x < -1e-4) break; // fixes "holes" in weird shapes
    if(e.x > 1e0) break;  // results in trippy background
  }

  e = vec2(.1, -.1); // epsilon
  cu = normalize(
    e.xyy * map(cw + e.xyy).x +
    e.yyx * map(cw + e.yyx).x +
    e.yxy * map(cw + e.yxy).x +
    e.xxx * map(cw + e.xxx).x
  );

  // color of surface
  gl_FragColor = vec4(
    (
      // material color
      sin(mat * vec3(3., 2., 1.)) +

      // diffuse lighting
      vec3(reflect(rd, cu).y)
    )
    // cheap vignette
    * (2. - length(vec3(-b + 2. * gl_FragCoord.xy, b.y) / b.y))
    // fade in/out
    //* clamp(0., (-abs(a - 1e1) + 1e1), 1.)
    ,
  1.);
}
