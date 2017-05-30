precision highp float;

// time variable (seconds)
uniform float a;

float calcPlasma(float x, float y, float z, float t) {
  // horizontal sinusoid
  float sine1 = sin(x * 10. + t * 2.);

  // rotating sinusoid
  float sine2 = sin(10. * (x * sin(t / 2.) + z * cos(t / 3.)) + t);

  // circular sinusoid
  float cx = x + .5 * sin(t / 5.);
  float cy = y + .5 * cos(t / 3.);
  float sine3 = sin(sqrt(100. * (cx * cx + cy * cy) + 1.) + t);

  float blend = sine1 + sine2 + sine3;

  //blend *= 1.0 + sin(t / 4.0) * 2.0;
  blend *= 3.0;
  //blend = sin(blend * 3.14 / 2.) / 2. + .5;
  blend = sin(blend * 3.14 / 2.0) / 2.0;
  //blend = pow(blend, 2.0);

  return blend;
}

// t = time to start transition
// tt = transition length
// vec2 opMorph( vec2 d1, vec2 d2, float t, float tt ) {
//   float k = (a - t) / tt;
//
//   /*
//   k = min(1., k);
//   k = max(0., k);
//   */
//
//   k = clamp(0., k, 1.);
//
//   return vec2(
//     d1.x * (1. - k) + d2.x * k,
//     d1.y * (1. - k) + d2.y * k
//   );
// }

vec2 opU(vec2 d1, vec2 d2) {
  return (d1.x<d2.x) ? d1 : d2;
}

float sdPlane(vec3 p) {
  return p.y;
}

float sdSphere(vec3 p, float s) {
  return length(p)-s;
}

float sdPlasmaSphere(vec3 p, float s) {
  float plasma = calcPlasma(p.x, p.y, p.z, a);

  return sdSphere(p, s) + plasma * sin(a / 100.0);
}

vec2 plasmaSphere(vec3 p) {
  float plasma4 = calcPlasma(p.x, p.y, p.z, a);
  plasma4 += 1.;
  float hue = sin(plasma4) * 100.0 + a;
  return vec2(sdPlasmaSphere(p, 0.5), hue);
}

vec2 plane(vec3 p) {
  return vec2(sdPlane(p), 0.);
}

// float sdPlasma(vec3 p) {
//   float plasma = calcPlasma(p.x, p.y, p.z, a / 10.0);
//   return plasma;
// }

// float sdTunnelThingPlasma(vec3 p) {
//   return (cos(p.x) + sin(p.y) + sin(p.z)) / 20.0 * (sin(a / 10.0) + 2.0);
// }

// vec2 fullScreenPlasma(vec3 p) {
//   // Full screen cool plasma thing (works best with tunnel thing at hue 0.0)
//   // works best with tmin = 0.2?
//   float plasma3 = calcPlasma(p.x, p.y, p.z, a);
//   float hue = sin(plasma3) * 100.0 + a * 100.0;
//   vec2 res = vec2(
//     sdTunnelThingPlasma(p),
//     hue / 3.0
//   );
//   return opU(res,
//     vec2(sdPlasma(p), hue)
//   );
// }

// SCENES
vec2 scene0(vec3 pos) {
  return opU(
    plasmaSphere(pos),
    plane(pos + vec3(.5))
  );
}

// vec2 scene1(vec3 pos) {
//   return fullScreenPlasma(pos);
// }

vec2 map(vec3 pos) {
  // vec2 res = vec2(.0);
  //
  // float transitionTime = 10.;
  // float end0 = 20.;
  // float end1 = 34.;
  // float end2 = 50.;
  // float end3 = 70.;

  /* ---------- DEBUGGING ---------- */
  // Uncomment when debugging single scene
  return scene0(pos);

  /* ---------- SCENES --------- */

  // first scene
  // if (a < end0 + transitionTime) {
  //   res = scene0(pos);
  // }

  // start rendering after previous scene,
  // stop rendering after transitioning to next scene
  /*
  if (a >= end0 && a < end1 + transitionTime) {
    res = opMorph(res,
      scene1(pos + vec3(a, .0, sin(a))),

      // Timing
      end0,
      transitionTime
    );
  }
  */

  // last scene
  // if (a >= end0) {
  //   res = opMorph(res,
  //     scene1(pos),
  //
  //     // Timing
  //     end1,
  //     transitionTime
  //   );
  // }
  //
  // return res;
}

vec2 castRay(vec3 ro, vec3 rd) {
  const int maxIterations = 64;
  float tmin = .2;
  float tmax = 30.;

  float m = -1.;
  for( int i=0; i<maxIterations; i++ ) {
    float precis = .000001*tmin;
    vec2 res = map( ro+rd*tmin );
    if( res.x<precis || tmin>tmax ) break;
    tmin += res.x;
    m = res.y;
  }

  if( tmin>tmax ) m=-1.;
  return vec2( tmin, m );
}


float softshadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float res = 2.;
  float t = mint;

  for( int i=0; i<16; i++ ) {
    float h = map( ro + rd*t ).x;
    res = min( res, 8.*h/t );
    t += clamp( h, .02, .10 );
    if( h<.001 || t>tmax ) break;
  }

  return clamp( res, .0, 1. );
}

vec3 calcNormal(vec3 pos) {
  vec2 e = vec2(.001,-.001); // (1, -1) * .5773*.0005
  return normalize( e.xyy*map( pos + e.xyy ).x +
    e.yyx*map( pos + e.yyx ).x +
    e.yxy*map( pos + e.yxy ).x +
    e.xxx*map( pos + e.xxx ).x );
}

float calcAO(vec3 pos, vec3 nor) {
  float occ = .0;
  float sca = 1.;

  for(int i=0; i<5; i++) {
    float hr = .01 + .12*float(i)/4.;
    vec3 aopos =  nor * hr + pos;
    float dd = map( aopos ).x;
    occ += -(dd-hr)*sca;
    sca *= .95;
  }

  return clamp( 1. - 3.*occ, .0, 1. );
}

vec3 render(vec3 ro, vec3 rd) {
  vec3 col = vec3(0.);
  //vec3 col = vec3(.05, .05, .05) +rd.y*.1;
  vec2 res = castRay(ro,rd);
  float t = res.x;
  float m = res.y;
  if( m>-.5 ) {
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos );
    vec3 ref = reflect( rd, nor );

    // material
    col = .45 + .35*sin( vec3(.05,.08,.10)*(m-1.0) );
    /*
    if( m<1.5 ) {
      float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
      col = .3 + .1*f*vec3(1.0);
    }
    */

    // lighitng. Seems Lighit
    float occ = calcAO( pos, nor );
    vec3  lig = normalize( vec3(-.4, .7, -.6) );
    float amb = clamp( .5+.5*nor.y, .0, 1. );
    float dif = clamp( dot( nor, lig ), .0, 1. );
    float bac = clamp( dot( nor, normalize(vec3(-lig.x,.0,-lig.z))), .0, 1. )*clamp( 1.-pos.y,.0,1.);
    float dom = smoothstep( -.1, .1, ref.y );
    float fre = pow( clamp(1.+dot(nor,rd),.0,1.), 2. );
    float spe = pow(clamp( dot( ref, lig ), .0, 1. ),16.);

    dif *= softshadow( pos, lig, .02, 2.5 );
    dom *= softshadow( pos, ref, .02, 2.5 );

    vec3 lin = vec3(.0);
    lin += 1.3*dif*vec3(1.,.8,.55);
    lin += 2.*spe*vec3(1.,.9,.7)*dif;
    lin += .4*amb*vec3(.4,.6,1.)*occ;
    lin += .5*dom*vec3(.4,.6,1.)*occ;
    lin += .5*bac*vec3(.25,.25,.25)*occ;
    lin += .25*fre*vec3(1.)*occ;
    col = col*lin;

    // fog
    col = mix( col, vec3(.0), 1.-exp( -.001*t*t*t ) );

    /*
    float fade = 1. - min(1., (a - 2.)  / 8.);
    col = mix( col, vec3(.0), fade );
    */
  }

  return vec3( clamp(col,.0,1.) );
}

void main() {
  vec3 tot = vec3(.0);

  // resolution
  vec2 res = vec2(240, 135);
  for( int m=0; m<2; m++ )   // 2x AA
  for( int n=0; n<2; n++ ) { // 2x AA
    // pixel coordinates
    vec2 o = vec2(float(m),float(n)) / float(2) - .5;
    vec2 p = (-res.xy + 3.*(gl_FragCoord.xy+o))/res.y;

    // camera
    // ro = ray origin = where the camera is
    // ta = camera direction (where the camera is looking)
    // cr = camera rotation
    //vec3 ro = vec3( -.5+3.5*cos(.1*a), 1.0, .5 + 4.0*sin(.1*a) );
    vec3 ro = vec3( cos(a), 1., sin(a) );
    // camera-to-world transformation
    //mat3 ca = setCamera(ro);

  	vec3 cw = normalize(-ro);
  	vec3 cp = vec3(.0, 1., .0);
  	vec3 cu = normalize( cross(cw,cp) );
  	vec3 cv = normalize( cross(cu,cw) );

    mat3 ca = mat3( cu, cv, cw );
    // ray direction
    vec3 rd = ca * normalize( vec3(p.xy,2.) );

    // render
    vec3 col = render( ro, rd );

  	// gamma
    col = pow( col, vec3(.7) );

    tot += col;
  }

  tot /= 4.; // AA * AA

  gl_FragColor = vec4( tot, 1. );
}
