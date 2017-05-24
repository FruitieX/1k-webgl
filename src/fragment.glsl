precision highp float;

// time variable (seconds)
uniform float a;
// resolution (1920.0, 1080.0)
uniform vec2 b;

// bass
uniform float c;
// treble
uniform float d;
// accumulated bass
uniform float e;
// frequency of lead synth
uniform float f;

float PI = 3.14;

float smin( float a, float b, float k ) {
  return -log(exp( -k*a ) + exp( -k*b ))/k;
}

/*
float sdPlane(vec3 p) {
  return p.y;
}
*/

float sdSphere(vec3 p, float s) {
  return length(p)-s;
}

/*
float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,.0));
}
*/

/*
float sdBlob2(vec3 p, vec2 t) {
  //return sqrt(p.x*p.x*.125 + p.y*p.y + p.z*p.z*.125) - .1;
  float P = .2;
  float Q = .1;
  return -pow(p.x*p.x + p.y*p.y, 2.) + P * (p.x*p.x + p.y*p.y) + Q * p.z*p.z + .1;
}
*/

float sdBloodCell(vec3 p, vec3 t) {
  return pow(p.x*p.x + p.z*p.z, 2.) + t.x * (p.x*p.x + p.z*p.z) + t.y * p.y*p.y + t.z;
}


float sdBloodCell2(vec3 p) {
  float d1 = length(vec2(length(p.xz)-.3,p.y)) - .1;
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.3,.06);
  float d2 = min(max(d.x,d.y),.0) + length(max(d,.0));
  return smin(d1,d2,32.);
}


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
  //blend *= 3.0;
  blend = sin(blend * PI / 2.) / 2. + .5;
  //blend = pow(blend, 2.0);

  return blend;
}

/*
float sdPlasmaSphere(vec3 p, float s, float t) {
  float plasma = calcPlasma(p.x, p.y, p.z, t / 1.);

  return sdSphere(p, s) + plasma * sin(t / 20.);
}
*/

/*
float calcPlasma2(float x, float y, float z, float t) {
  // horizontal sinusoid
  float sine1 = sin(x * 10. + t * 2.);

  // rotating sinusoid
  float sine2 = sin(10. * (x * sin(t / 2.) + z * cos(t / 3.)) + t);

  // circular sinusoid
  float cx = x + .5 * sin(t / 5.);
  float cy = y + .5 * cos(t / 3.);
  float sine3 = sin(sqrt(100. * (cx * cx + cy * cy) + 1.) + t);

  float blend = sine1 + sine2 + sine3;

  //blend *= 1. + sin(t / 4.) * 2.;
  blend *= 3.;
  blend = sin(blend * PI / 2.) / 2.;
  //blend /= 1.;
  //blend = pow(blend, 2.);
  return blend;
}
*/

/*
float sdPlasma(vec3 p, float t) {
  float plasma = calcPlasma2(p.x, p.y, p.z, t / 100.);
  return plasma;
}
*/

/*
float random(vec2 p) {
  vec2 r = vec2(
    23.14069263277926, // e^pi (Gelfonds constant)
    2.665144142690225 // 2^sqrt(2) (GelfondSchneider constant)
  );
  return fract( cos( mod( 12345678., 256. * dot(p,r) ) ) );
}

float sdRandom(vec3 p) {
  return length(random(vec2(p.x, p.y)));
}

float sdRandomSphere(vec3 p) {
  float rand = length(random(vec2(p.x, p.y)));

  return sdSphere(p, rand);
}
*/

/*
float opS_1(float d1, float d2) {
  return max(-d2,d1);
}
*/

// TODO: test me
vec2 opS(vec2 d1, vec2 d2) {
  return (d1.x<-d2.x) ? d2 : d1;
}

// TODO: remove all _1 functions (take in float instead of vec2)
float opBlend_1( float d1, float d2 ) {
    return smin( d1, d2, 32. );
}

/*
vec2 opBlend( vec2 d1, vec2 d2, float k ) {
    return vec2(
      smin( d1.x, d2.x, k ),
      smin( d1.y, d2.y, k )
    );
}
*/

// t = time to start transition
// tt = transition length
vec2 opMorph( vec2 d1, vec2 d2, float t, float tt ) {
  float k = (a - t) / tt;

  /*
  k = min(1., k);
  k = max(0., k);
  */

  k = clamp(0., k, 1.);

  return vec2(
    d1.x * (1. - k) + d2.x * k,
    d1.y * (1. - k) + d2.y * k
  );
}

vec2 opU(vec2 d1, vec2 d2) {
  return (d1.x<d2.x) ? d1 : d2;
}

vec3 opRep(vec3 p, vec3 c) {
  return mod(p,c)-.5*c;
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
vec2 pR(vec2 p, float a) {
	return cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

/*
vec3 opTwist(vec3 p) {
  float  c = cos(p.y);
  float  s = sin(p.y);
  mat2   m = mat2(c,-s,s,c);
  return vec3(m*p.xz,p.y);
}
*/

float fCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

float sdTunnelThing(vec3 p) {
  return (1. - c * .25) * (cos(p.x) + sin(p.y) + sin(p.z)) / 20. * (2. * (sin(a / 20.) + 1.15));
}

float sdBloodVein(vec3 p) {
  vec3 c = vec3(2.,3.,5.);
  return -(length(p.xy-c.xz)-c.y);
}

float sdBloodVein2(vec3 p) {
  // the first constant sets size of torus
  // second sets size of middle
  return -(length(vec2(length(p.xz)-4.,p.y)) - 1.5);
}


vec2 heart(vec3 p) {
  float plasma1 = calcPlasma(p.x, p.y, p.z, a / 10.);
  float hue = sin(plasma1) * 100. + a * 10.;

  return vec2(
    // tunnel shape
    sdTunnelThing(p)

    // blobby surface
    + (1. - c) * .05 * sin(10. * p.x) * sin(10. * p.y) * sin(10. * p.z) * sin(plasma1),

    // color
    hue / 3.
  );
}

vec2 bloodCellField(vec3 p) {
  float plasmaBlood = calcPlasma(p.x, p.y, p.z, a / 10.);
  //vec2(sdSphere(p-offs, .5 - 0.01 * sin(20.0* p.x + 15.0*p.y + a * 3.0)), 80.0)

  vec3 repeated =
    opRep(
      p + vec3(.0, .0, e + a),
      vec3(1.5)
    );
    // TODO: tweak parameters

  repeated.xy = pR(repeated.xy, p.z / 4.0);

  return vec2(sdBloodCell(
    repeated,
    vec3(-.15, 1.275, -.001)
  )
  // blobby surface
  + .0005 * sin(30. * p.x) * sin(30. * p.y) * sin(30. * p.z) * sin(plasmaBlood),

  // color
  54.);
}

/*
float sdTunnelThingPlasma(vec3 p) {
  return (cos(p.x) + sin(p.y) + sin(p.z)) / 20. * (sin(a / 20.) + 2.);
}
*/

vec2 bloodVein(vec3 pos) {
  return vec2(
    // tunnel shape
    sdBloodVein2(pos + vec3(3.,-1.,1.)),

    // blobby surface
    // + 0.05 * sin(10.0 * pos.x) * sin(10.0 * pos.y) * sin(10.0 * pos.z),

    // color
    10.0 * a
  );
}


// SCENES
vec2 scene0(vec3 pos) {
  return opU(
    heart(pos),
    bloodCellField(pos)
  );
}

vec2 scene1(vec3 pos) {
  return bloodVein(pos);
}
/*
vec2 scene1(vec3 pos) {
  // Blood vein thing

  return vec2(sdBloodVein2(
    pos,
    // TODO: tweak parameters
    vec3(2.0, 3.2, 2.0)
  ),

  // color
  54.0);
}
*/

vec2 scene2(vec3 pos) {
  // Blood cell thing
  // hue 80.0 = water ish
  // hue 240.0 = green ish
  float plasmaBlood = calcPlasma(pos.x, pos.y, pos.z, a / 10.);
  //vec2(sdSphere(pos-offs, .5 - 0.01 * sin(20.0* pos.x + 15.0*pos.y + a * 3.0)), 80.0)

  return vec2(sdBloodCell(
    opRep(
      pos,
      vec3(1.)
    ),
    // TODO: tweak parameters
    vec3(-.15, 1.275, -.001)
  )
  // blobby surface
  + d * .005 * sin(30. * pos.x) * sin(30. * pos.y) * sin(30. * pos.z) * sin(plasmaBlood),

  // color
  54.);
}

/*
vec2 scene3(vec3 pos) {
  // virus
  vec3 offs = vec3(sin(a) / 4.,.75,.0);
  return vec2(.5 *
    sdSphere(
      pos - offs, .5
    )
    + .01 * sin(100. * pos.x) * sin(100. * pos.y) * sin(100. * pos.z),
    .0
  );
}

vec2 scene4(vec3 pos) {
  // Sphere
  return vec2(sdSphere(
    pos,
  .5), 1.);
}

vec2 scene5(vec3 pos) {
  // Plasma sphere with repetition
  float plasma2 = calcPlasma(pos.x, pos.y, pos.z, a / 10.);
  float hue = sin(plasma2) * 100. + a * 10.;
  return vec2(sdPlasmaSphere(opRep(
    pos,
    vec3(1.5, 1.0, 1.0)
  ), .5, a), hue);
}

vec2 scene6(vec3 pos) {
  // Full screen cool plasma thing (works best with tunnel thing at hue 0.0)
  // works best with tmin = 0.2?
  float plasma3 = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  float hue = sin(plasma3) * 100.0 + a * 10.0;
  vec2 res = vec2(
    sdTunnelThingPlasma(pos),
    hue / 3.0
  );
  return opU(res,
    vec2(sdPlasma(pos, a), hue)
  );
}

vec2 scene7(vec3 pos) {
  // Plasma sphere
  float plasma4 = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  float hue = sin(plasma4) * 100.0 + a * 10.0;
  vec3 offs = vec3(0.0,0.75,0.0);
  return vec2(sdPlasmaSphere(
    pos-offs,
  0.25, a), hue);
}

vec2 scene8(vec3 pos) {
  // stars with pattern
  return vec2(5.0 *
    opS_1(
      sdSphere(
        pos, 5.0
      )
      + 5.0 * sin(20.0 * pos.x) * sin(20.0 * pos.y) * sin(20.0 * pos.z),
      // bounding sphere
      sdSphere(
        pos, 9.0
      )
    ),
    0.0
  );
}

vec2 scene9(vec3 pos) {
  // ????? bounding sphere
  return vec2(5.5 *
    opS_1(
      sdSphere(
        pos, 5.0
      )
      + 5.0 * sin(20.0 * pos.x) * sin(20.0 * pos.y) * sin(20.0 * pos.z),
      // bounding sphere
      sdSphere(
        pos, 3.0
      )
    ),
    50.0
  );
}
*/

vec2 scene10(vec3 pos) {
  // Plasma starfield thing
  // works best with very low tmin
  float plasma = calcPlasma(pos.x, pos.y, pos.z, a / 2.);
  float hue = sin(plasma) * 80. + a + mod(f / 4., 360.);
  return vec2(sdSphere(
    opRep(
      pos,
      vec3(sin(a / 20.) / 4., cos(a / 17.4) / 4., cos(a / 21.24) / 4.) // WTF alternative
      //vec3(.1)
    ),
    //(sin(a / 15.0) + 1.0) * 0.01), hue)
    (1. + sin(a + 5. * (pos.y + pos.x + pos.z))) * .01), hue // WTF alternative
  );
}

/*
vec2 scene11(vec3 pos) {
  // Repeated spheres
  return vec2(sdSphere(
    opRep(
      //opTwist(
        pos
      //)
      ,
      vec3(2.)
    ),
    0.1), 0.0
  );
}

vec2 scene12(vec3 pos) {
  return vec2(sdSphere(
    opRep(
      //opTwist(
        pos
      //)
      ,
      vec3(2.)
    ),
    0.2), 0.0
  );
}
*/

vec2 scene14(vec3 pos) {
  // Blood cell thing v2
  // hue 80.0 = water ish
  // hue 240.0 = green ish
    //vec2(sdSphere(pos-offs, .5 - 0.01 * sin(20.0* pos.x + 15.0*pos.y + a * 3.0)), 80.0)
  return vec2(sdBloodCell2(
    opRep(
      pos,
      vec3(1.)
    )
  ), 54.0);
}


vec2 scene15(vec3 pos) {
  // wtf ceiling and floor is this
  return vec2(sdBloodCell(
    opRep(
      pos,
      vec3(sin(a / 5.) * .4, 1., sin(a / 5.) * .4)
    ),
    vec3(-.15, 1.275, -.001)
  ), 84.);
}

vec2 scene16(vec3 pos) {
  vec3 offs = vec3(-.5, -.35 * sin(a) / 5., sin(a) / 4.);
  vec2 res = vec2(opBlend_1(
    sdSphere(pos, .5),
    sdSphere(pos + offs, .5)
  ), abs(50. + sin(pos.x)*100.));

  res = opU(res,
    vec2(
      -sdSphere(pos, 6.),
      abs(50. + sin(pos.x) * 10.)
    )
  );

  return res;
}

vec2 map(in vec3 pos, in vec3 origin) {
  vec2 res = vec2(.0);

  float transitionTime = 10.;
  float end0 = 20.;
  float end1 = 34.;
  float end2 = 50.;
  float end3 = 70.;

  // Uncomment when debugging single scene
  return scene1(pos);

  /* ---------- SCENES --------- */

  // first scene
  if (a < end0 + transitionTime) {
    res = scene0(pos);
  }

  // start rendering after previous scene,
  // stop rendering after transitioning to next scene
  if (a >= end0 && a < end1 + transitionTime) {
    res = opMorph(res,
      scene2(pos + vec3(a, .0, sin(a))),

      // Timing
      end0,
      transitionTime
    );
  }

  // start rendering after previous scene,
  // stop rendering after transitioning to next scene
  if (a >= end1 && a < end2 + transitionTime) {
    res = opMorph(res,
      scene10(pos),

      // Timing
      end1,
      transitionTime
    );
  }

  if (a >= end2 && a < end3 + transitionTime) {
    res = opMorph(res,
      scene16(pos),

      // Timing
      end2,
      transitionTime
    );
  }

  // last scene
  if (a >= end3) {
    res = opMorph(res,
      scene15(pos),

      // Timing
      end3,
      transitionTime
    );
  }

  return res;
}

vec2 castRay(in vec3 ro, in vec3 rd) {
  const int maxIterations = 64;
  float tmin = .02;
  float tmax = 50.;

  float t = tmin;
  float m = -1.;
  for( int i=0; i<maxIterations; i++ ) {
    float precis = .000001*t;
    vec2 res = map( ro+rd*t, ro );
    if( res.x<precis || t>tmax ) break;
    t += res.x;
    m = res.y;
  }

  if( t>tmax ) m=-1.;
  return vec2( t, m );
}


float softshadow(in vec3 ro, in vec3 rd, in float mint, in float tmax) {
  float res = 1.;
  float t = mint;

  for( int i=0; i<16; i++ ) {
    float h = map( ro + rd*t, ro ).x;
    res = min( res, 8.*h/t );
    t += clamp( h, .02, .10 );
    if( h<.001 || t>tmax ) break;
  }

  return clamp( res, .0, 1. );
}

vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.,-1.)*.5773*.0005;
  return normalize( e.xyy*map( pos + e.xyy, pos ).x +
    e.yyx*map( pos + e.yyx, pos ).x +
    e.yxy*map( pos + e.yxy, pos ).x +
    e.xxx*map( pos + e.xxx, pos ).x );
}

float calcAO(in vec3 pos, in vec3 nor) {
  float occ = .0;
  float sca = 1.;

  for(int i=0; i<5; i++) {
    float hr = .01 + .12*float(i)/4.;
    vec3 aopos =  nor * hr + pos;
    float dd = map( aopos, pos ).x;
    occ += -(dd-hr)*sca;
    sca *= .95;
  }

  return clamp( 1. - 3.*occ, .0, 1. );
}

vec3 render(in vec3 ro, in vec3 rd) {
  vec3 col = vec3(.0);
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

    col = mix( col, vec3(.8,.9,1.), 1.-exp( -.0002*t*t*t ) );
  }

  return vec3( clamp(col,.0,1.) );
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );

  return mat3( cu, cv, cw );
}

void main() {
  vec3 tot = vec3(.0);
  for( int m=0; m<2; m++ )   // 2x AA
  for( int n=0; n<2; n++ ) { // 2x AA
    // pixel coordinates
    vec2 o = vec2(float(m),float(n)) / float(2) - .5;
    vec2 p = (-b.xy + 3.*(gl_FragCoord.xy+o))/b.y;

    // camera
    // ro = ray origin = where the camera is
    // ta = camera direction (where the camera is looking)
    // cr = camera rotation
    //vec3 ro = vec3( -.5+3.5*cos(.1*a), 1.0, .5 + 4.0*sin(.1*a) );
    vec3 ro = vec3( -.5+.2*cos(.1*a), 1., .0 + 2.*sin(.1*a) );
    vec3 ta = vec3( .0 );
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, .0 );
    // ray direction
    vec3 rd = ca * normalize( vec3(p.xy,2.) );

    // render
    vec3 col = render( ro, rd );

  	// gamma
    col = pow( col, vec3(.5) );

    tot += col;
  }

  tot /= 4.; // AA * AA

  gl_FragColor = vec4( tot, 1. );
}
