precision mediump float;

// time variable
uniform float a;
// resolution
uniform vec2 b;

// antialias
// TODO: in production get rid of if statements

float smin( float a, float b, float k ) {
    return -log(exp( -k*a ) + exp( -k*b ))/k;
}

float sdPlane(vec3 p) {
  return p.y;
}

float sdSphere(vec3 p, float s) {
  return length(p)-s;
}

float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,0.0));
}

float sdBlob2(vec3 p, vec2 t) {
  //return sqrt(p.x*p.x*0.125 + p.y*p.y + p.z*p.z*0.125) - 0.1;
  float P = 0.2;
  float Q = 0.1;
  return -pow(p.x*p.x + p.y*p.y, 2.0) + P * (p.x*p.x + p.y*p.y) + Q * p.z*p.z + 0.1;
}

float sdBloodCell(vec3 p, vec3 t) {
  return pow(p.x*p.x + p.z*p.z, 2.0) + t.x * (p.x*p.x + p.z*p.z) + t.y * p.y*p.y + t.z;
}

float sdBloodCell2(vec3 p) {
  vec2 t = vec2(.2, .2);
  // vec3 b = vec3(.2,.06,.2);
  vec2 h = vec2(.3,.06);
  float d1 = length(vec2(length(p.xz)-t.x*1.5,p.y)) - t.y/2.2;
  // float d2 = udBox(p,b);
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  float d2 = min(max(d.x,d.y),0.0) + length(max(d,0.0));
  return smin(d1,d2,32.0);
}

float PI = 3.14;

float calcPlasma(float x, float y, float z, float t) {
  // horizontal sinusoid
  float sine1 = sin(x * 10.0 + t * 2.0);

  // rotating sinusoid
  float sine2 = sin(10.0 * (x * sin(t / 2.0) + z * cos(t / 3.0)) + t);

  // circular sinusoid
  float cx = x + 0.5 * sin(t / 5.0);
  float cy = y + 0.5 * cos(t / 3.0);
  float sine3 = sin(sqrt(100.0 * (cx * cx + cy * cy) + 1.0) + t);

  float blend = sine1 + sine2 + sine3;

  //blend *= 1.0 + sin(t / 4.0) * 2.0;
  //blend *= 3.0;
  blend = sin(blend * PI / 2.0) / 2.0 + 0.5;
  //blend = pow(blend, 2.0);

  return blend;
}

float sdPlasmaSphere(vec3 p, float s, float t) {
  float plasma = calcPlasma(p.x, p.y, p.z, t / 1.0);

  return sdSphere(p, s) + plasma * sin(t / 20.0);
}

float calcPlasma2(float x, float y, float z, float t) {
  // horizontal sinusoid
  float sine1 = sin(x * 10.0 + t * 2.0);

  // rotating sinusoid
  float sine2 = sin(10.0 * (x * sin(t / 2.0) + z * cos(t / 3.0)) + t);

  // circular sinusoid
  float cx = x + 0.5 * sin(t / 5.0);
  float cy = y + 0.5 * cos(t / 3.0);
  float sine3 = sin(sqrt(100.0 * (cx * cx + cy * cy) + 1.0) + t);

  float blend = sine1 + sine2 + sine3;

  //blend *= 1.0 + sin(t / 4.0) * 2.0;
  blend *= 3.0;
  blend = sin(blend * PI / 2.0) / 2.0;
  //blend /= 1.0;
  //blend = pow(blend, 2.0);
  return blend;
}

float sdPlasma(vec3 p, float t) {
  float plasma = calcPlasma2(p.x, p.y, p.z, t / 100.0);
  return plasma;
}

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

float opS(float d1, float d2) {
  return max(-d2,d1);
}

vec2 opU(vec2 d1, vec2 d2) {
  return (d1.x<d2.x) ? d1 : d2;
}

vec3 opRep(vec3 p, vec3 c) {
  return mod(p,c)-0.5*c;
}

vec3 opTwist(vec3 p) {
  float  c = cos(p.y);
  float  s = sin(p.y);
  mat2   m = mat2(c,-s,s,c);
  return vec3(m*p.xz,p.y);
}

float opBlend( float d1, float d2 ) {
    return smin( d1, d2, 32.0 );
}

float sdTunnelThing(vec3 p) {
  return (cos(p.x) + sin(p.y) + sin(p.z)) / 20.0 * (2.0 * (sin(a / 20.0) + 1.15));
}

float sdTunnelThingPlasma(vec3 p) {
  return (cos(p.x) + sin(p.y) + sin(p.z)) / 20.0 * (sin(a / 20.0) + 2.0);
}

float sdBloodVein(vec3 p) {
  vec3 c = vec3(2.0,5.0,5.0);
  return abs(length(p.xy-c.xz)-c.y);
}

float sdBloodVein2(vec3 p, vec3 t) {
  return -pow(p.x*p.x + p.z*p.z, 2.0) + t.x * (p.x*p.x + p.z*p.z) + t.y * p.y*p.y + t.z;
}

// SCENES
vec2 scene0(vec3 pos) {
  float plasma1 = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  float hue = sin(plasma1) * 100.0 + a * 10.0;

  return vec2(
    // tunnel shape
    sdTunnelThing(pos)

    // blobby surface
    + 0.05 * sin(10.0 * pos.x) * sin(10.0 * pos.y) * sin(10.0 * pos.z) * sin(plasma1),

    // color
    hue / 3.0
  );
}

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

vec2 scene2(vec3 pos) {
  // Blood cell thing
  // hue 80.0 = water ish
  // hue 240.0 = green ish
  float plasmaBlood = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  //vec2(sdSphere(pos-offs, .5 - 0.01 * sin(20.0* pos.x + 15.0*pos.y + a * 3.0)), 80.0)

  return vec2(sdBloodCell(
    opRep(
      pos,
      vec3(1.0, 1.0, 1.0)
    ),
    // TODO: tweak parameters
    vec3(-0.15, 1.275, -0.001)
  )
  // blobby surface
  + 0.0005 * sin(30.0 * pos.x) * sin(30.0 * pos.y) * sin(30.0 * pos.z) * sin(plasmaBlood),

  // color
  54.0);
}

vec2 scene3(vec3 pos) {
  // weird ass sphere
  vec3 offs = vec3(sin(a) / 4.0,0.75,0.0);
  return vec2(0.5 *
    sdSphere(
      pos - offs, 0.5
    )
    + 0.01 * sin(100.0 * pos.x) * sin(100.0 * pos.y) * sin(100.0 * pos.z),
    165.0
  );
}

vec2 scene4(vec3 pos) {
  // Sphere
  return vec2(sdSphere(
    pos,
  0.5), 1.0);
}

vec2 scene5(vec3 pos) {
  // Plasma sphere with repetition
  float plasma2 = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  float hue = sin(plasma2) * 100.0 + a * 10.0;
  return vec2(sdPlasmaSphere(opRep(
    pos,
    vec3(1.5, 1.0, 1.0)
  ), 0.5, a), hue);
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
    opS(
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
    opS(
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

vec2 scene10(vec3 pos) {
  // Plasma starfield thing
  // works best with very low tmin
  float plasma = calcPlasma(pos.x, pos.y, pos.z, a / 2.0);
  float hue = sin(plasma) * 80.0 + a * 1.0;
  return vec2(sdSphere(
    opRep(
      pos,
      vec3(sin(a / 20.0) / 4.0, cos(a / 17.4) / 4.0, cos(a / 21.24) / 4.0) // WTF alternative
      //vec3(.1, .1, .1)
    ),
    //(sin(a / 15.0) + 1.0) * 0.01), hue)
    (1.0 + sin(a + 5.0 * (pos.y + pos.x + pos.z))) * 0.01), hue // WTF alternative
  );
}

vec2 scene11(vec3 pos) {
  // Repeated spheres
  return vec2(sdSphere(
    opRep(
      //opTwist(
        pos
      //)
      ,
      vec3(2.0, 2.0, 2.0)
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
      vec3(2.0, 2.0, 2.0)
    ),
    0.2), 0.0
  );
}

vec2 scene13(vec3 pos) {
  // Yet another tunnel
  // float plasma1 = calcPlasma(pos.x, pos.y, pos.z, a / 10.0);
  return vec2(
    // tunnel shape
    sdBloodVein(pos + vec3(2.0,1.5,0.0)),

    // blobby surface
    // + 0.05 * sin(10.0 * pos.x) * sin(10.0 * pos.y) * sin(10.0 * pos.z),

    // color
    170.0 / 3.0
  );
}

vec2 scene14(vec3 pos) {
  // Blood cell thing v2
  // hue 80.0 = water ish
  // hue 240.0 = green ish
    //vec2(sdSphere(pos-offs, .5 - 0.01 * sin(20.0* pos.x + 15.0*pos.y + a * 3.0)), 80.0)
  return vec2(sdBloodCell2(
    opRep(
      pos,
      vec3(1.0, 1.0, 1.0)
    )
  ), 54.0);
}

vec2 scene15(vec3 pos) {
  // wtf ceiling and floor is this
  return vec2(sdBloodCell2(
    opRep(
      pos,
      vec3(sin(a / 5.0) * 0.4, 1.0, sin(a / 5.0) * 0.4)
    )
  ), 84.0);
}
vec2 scene16(vec3 pos) {
  vec3 offs = vec3(0.0, -0.35, 0.2);
  return vec2(opBlend(
    sdSphere(pos, .3),
    sdSphere(pos + offs, .3)
  ), 184.0);
}

vec2 map(in vec3 pos, in vec3 origin) {

  float hue = 0.0;
  vec3 offs = vec3(0.0, 0.0, 0.0);
  vec2 res = vec2(1.0, 1.0);

  /* ---------- SCENES --------- */

  // select scene
  // TODO: warp between scenes according to time?
  int SCENE = 0 + int(a / 10.0);
  //SCENE = 8; // TODO: broken
  SCENE = 0;

  // Tunnel thing

  if (SCENE == 0) {
    res = scene0(pos);
  } else if (SCENE == 1) {
    res = scene1(pos);
  } else if (SCENE == 2) {
    res = scene2(pos);
  } else if (SCENE == 3) {
    res = scene3(pos);
  } else if (SCENE == 4) {
    res = scene4(pos);
  } else if (SCENE == 5) {
    res = scene5(pos);
  } else if (SCENE == 6) {
    res = scene6(pos);
  } else if (SCENE == 7) {
    res = scene7(pos);
  } else if (SCENE == 8) {
    res = scene8(pos);
  } else if (SCENE == 9) {
    res = scene9(pos);
  } else if (SCENE == 10) {
    res = scene10(pos);
  } else if (SCENE == 11) {
    res = scene11(pos);
  } else if (SCENE == 12) {
    res = scene12(pos);
  } else if (SCENE == 13) {
    res = scene13(pos);
  } else if (SCENE == 14) {
    res = scene14(pos);
  } else if (SCENE == 15) {
    res = scene15(pos);
  } else if (SCENE == 16) {
    res = scene16(pos);
  }

  return res;
}

vec2 castRay(in vec3 ro, in vec3 rd) {
  const int maxIterations = 64;
  float tmin = 0.02;
  float tmax = 50.0;

  float t = tmin;
  float m = -1.0;
  for( int i=0; i<maxIterations; i++ ) {
    float precis = 0.000001*t;
    vec2 res = map( ro+rd*t, ro );
    if( res.x<precis || t>tmax ) break;
    t += res.x;
    m = res.y;
  }

  if( t>tmax ) m=-1.0;
  return vec2( t, m );
}


float softshadow(in vec3 ro, in vec3 rd, in float mint, in float tmax) {
  float res = 1.0;
  float t = mint;

  for( int i=0; i<16; i++ ) {
    float h = map( ro + rd*t, ro ).x;
    res = min( res, 8.0*h/t );
    t += clamp( h, 0.02, 0.10 );
    if( h<0.001 || t>tmax ) break;
  }

  return clamp( res, 0.0, 1.0 );
}

vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
  return normalize( e.xyy*map( pos + e.xyy, pos ).x +
    e.yyx*map( pos + e.yyx, pos ).x +
    e.yxy*map( pos + e.yxy, pos ).x +
    e.xxx*map( pos + e.xxx, pos ).x );
}

float calcAO(in vec3 pos, in vec3 nor) {
  float occ = 0.0;
  float sca = 1.0;

  for(int i=0; i<5; i++) {
    float hr = 0.01 + 0.12*float(i)/4.0;
    vec3 aopos =  nor * hr + pos;
    float dd = map( aopos, pos ).x;
    occ += -(dd-hr)*sca;
    sca *= 0.95;
  }

  return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}

vec3 render(in vec3 ro, in vec3 rd) {
  vec3 col = vec3(0.0, 0.0, 0.0);
  //vec3 col = vec3(0.05, 0.05, 0.05) +rd.y*0.1;
  vec2 res = castRay(ro,rd);
  float t = res.x;
  float m = res.y;
  if( m>-0.5 ) {
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos );
    vec3 ref = reflect( rd, nor );

    // material
    col = 0.45 + 0.35*sin( vec3(0.05,0.08,0.10)*(m-1.0) );
    /*
    if( m<1.5 ) {
      float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
      col = 0.3 + 0.1*f*vec3(1.0);
    }
    */

    // lighitng. Seems Lighit
    float occ = calcAO( pos, nor );
    vec3  lig = normalize( vec3(-0.4, 0.7, -0.6) );
    float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
    float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
    float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
    float dom = smoothstep( -0.1, 0.1, ref.y );
    float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
    float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);

    dif *= softshadow( pos, lig, 0.02, 2.5 );
    dom *= softshadow( pos, ref, 0.02, 2.5 );

    vec3 lin = vec3(0.0);
    lin += 1.3*dif*vec3(1.0,0.8,0.55);
    lin += 2.0*spe*vec3(1.0,0.9,0.7)*dif;
    lin += 0.4*amb*vec3(0.4,0.6,1.0)*occ;
    lin += 0.5*dom*vec3(0.4,0.6,1.0)*occ;
    lin += 0.5*bac*vec3(0.25,0.25,0.25)*occ;
    lin += 0.25*fre*vec3(1.0,1.0,1.0)*occ;
    col = col*lin;

    col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0002*t*t*t ) );
  }

  return vec3( clamp(col,0.0,1.0) );
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );

  return mat3( cu, cv, cw );
}

void main() {
  vec3 tot = vec3(0.0);
  for( int m=0; m<2; m++ )   // 2x AA
  for( int n=0; n<2; n++ ) { // 2x AA
    // pixel coordinates
    vec2 o = vec2(float(m),float(n)) / float(2) - 0.5;
    vec2 p = (-b.xy + 3.0*(gl_FragCoord.xy+o))/b.y;

    // camera
    //vec3 ro = vec3( -0.5+3.5*cos(0.1*a), 1.0, 0.5 + 4.0*sin(0.1*a) );
    vec3 ro = vec3( -0.5+0.2*cos(0.1*a), 1.0, 0.0 + 2.0*sin(0.1*a) );
    vec3 ta = vec3( 0.0, 0.5, 0.0 );
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 0.0 );
    // ray direction
    vec3 rd = ca * normalize( vec3(p.xy,2.0) );

    // render
    vec3 col = render( ro, rd );

  	// gamma
    col = pow( col, vec3(0.4545) );

    tot += col;
  }

  tot /= float(4); // AA * AA

  gl_FragColor = vec4( tot, 1.0 );
}
