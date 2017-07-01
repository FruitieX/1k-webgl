precision highp float;

// a.xy = resolution
// a.z = time
// a.w = fade
uniform vec4 a;

// b.x = 1
// b.y = kick drum volume
// b.z = t>>19
uniform vec4 b;

void main() {
  // ray marcher temp result
	vec3 e = b.xxx,
  cu = -e + sin(a.z - b.z),

  // ray direction
  rd = (gl_FragCoord.xyz - a.xyz) * a.z / a.x + cu;

  // ray marcher
  for(int f=0; f<9; f++)
    // plasma + sphere
    cu += e = sin(sin(rd*cu) + length(sin(rd*cu)));

  gl_FragColor = vec4(
    // material color
    sin(a.xyz + rd*cu) / 1e1 + e.z,

		.5 / e.z * a.w
  );
}
