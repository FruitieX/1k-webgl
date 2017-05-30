precision highp float;

// time variable (seconds)
uniform float a;

vec2 opU(vec2 d1, vec2 d2) {
  return d1.x<d2.x ? d1 : d2;
}

vec2 map(vec3 p) {
  float plasma = sin(5. *
    // horizontal sinusoid
    sin(10. * p.x + a * 2.) +
    // rotating sinusoid
    sin(10. * (p.x * sin(a / 2.) + p.z * cos(a / 3.)) + a) +
    // circular sinusoid
    sin(sqrt(10. * (
      // cx
      pow(p.x + .5 * sin(a / 2.), 2.) +
      // cy
      pow(p.y + .5 * cos(a / 3.), 2.)
    ) + 1.) + a)
  ) / 2.;

  return opU(
    // plasma sphere

    // return vec2(sdPlasmaSphere(p, 0.5), hue);
    vec2(length(p)-.5 + plasma * sin(a / 10.), 100. * sin(plasma) + a),
    // plane
    vec2(1. + p.y, .0)
  );
}

void main() {
  vec3 tot = vec3(.0);

  // resolution
  //vec2 res = vec2(240, 135);
  //for( float m=0.; m<2.; m++ )   // 2x AA
  //for( float n=0.; n<2.; n++ ) { // 2x AA
    //vec2 p = (-res.xy + 3.*(gl_FragCoord.xy+o))/res.y;
    //vec2 p = ;

    // camera
    // ro = ray origin = where the camera is
    // ta = camera direction (where the camera is looking)
    // cr = camera rotation
    //vec3 ro = vec3( -.5+3.5*cos(.1*a), 1.0, .5 + 4.0*sin(.1*a) );
    vec3 ro = vec3( cos(a), 1., sin(a) );
    // camera-to-world transformation
    //mat3 ca = setCamera(ro);

  	vec3 cw = normalize(-ro);
  	vec3 cu = cross(cw, vec3(.0, 1., .0));

    // ray direction
    vec3 rd = mat3(
      cu,
      cross(cu,cw),
      cw
    ) * normalize(
      vec3(
        (
          -vec2(240., 135.) + 2. * (
            gl_FragCoord.xy //+
            // pixel coordinates when doing AA
            //vec2(m,n) / 2. - .5
          )
        ) / 135.,
        2.
      )
    );

    // render
    //vec3 col = render( ro, rd );

    // castRay(ro, rd)
    float tmin = 1., mat = -1.;
    for( float i=.0; i<64.; i++ ) { // 64 = maxIterations
      cw = ro+rd*tmin;
      vec2 rayRes = map(cw);
      //float precis = .000001*tmin;
      //if( rayRes.x<precis) break; // TODO: nice optimisation, but eats space
      tmin += rayRes.x;
      mat = rayRes.y;
    }

    //if( tmin>30. ) mat=-1.; // 30. = tmax
    // end

    // vec3 nor = calcNormal(ro + tmin*rd);
    // calcNormal(pos)
    vec2 e = vec2(.01,-.01); // (1, -1) * .5773*.0005
    // normal
    cu = normalize(
      e.xyy*map( cw+ e.xyy ).x +
      e.yyx*map( cw+ e.yyx ).x +
      e.yxy*map( cw+ e.yxy ).x +
      e.xxx*map( cw+ e.xxx ).x
    );
    // end

    tot +=
      .5 * sin(vec3(.05,.08,.1) * mat) + //* vec3(dot(cu, vec3(1.))) +
      .5 * vec3(reflect( rd, cu ).y);

  	// gamma
    //col = pow( col, vec3(.7) );

    //tot /= 4.; // AA * AA
  //}

  gl_FragColor = vec4( tot, 1. );
}
