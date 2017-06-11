// cheap way of doing AA
c.width = 200, c.height = 120; // 16:9 aspect ratio

f = new AudioContext();
a = f.createScriptProcessor();
a.connect(f.destination);

t = 0;

// onload
with(c.getContext('webgl')) {
  P = createProgram();

  // NOTE: 2nd argument to drawArrays used to be 0, but undefined works
  r = time => drawArrays(6,  // TRIANGLE_FAN = 6
    // Send resolution and time to shader
    uniform4f(getUniformLocation(P, 'a'), c.width, c.height, time / 1e4, requestAnimationFrame(r)),
    3,

    // music
    a.onaudioprocess = e =>
    {
      left = e.outputBuffer.getChannelData(0);
      right = e.outputBuffer.getChannelData(1);

      left.map((e, i) =>
      {
        //t = Math.floor(f.sampleRate * e.playbackTime + i);
        t++;
        //t /= 4;

        //if (!i) console.log(e.playbackTime, 'start', t);
        //if (i===16383) console.log(e.playbackTime, 'end', t);
        //left[i] = Math.sin(t / 23) * 128;
        //left[i] = Math.sin(t / 4);

        // melody thing
        //left[i] += ((t*("36364689"[t>>13&7]&15))/12&128)

        // melody thing 2
        /*
        left[i] = (((3e3/(y=t&16383))&1)*35) +
               (x=t*("3346"[t>>16&3]&15)/24&127)*y/4e4 +
               ((t>>8^t>>10|t>>14|x)&63)
               */

        // kick
        //left[i] += (((1e4/(y=t&16383*1.5))&1)*35)

        // drum beat thing
        //left[i] += ((((u=t&0x3fff)&0+((u+1<<(18+(t>>12&1*6)))/u)&255)/(u>>8))&240-128);

        // beep thing
        //left[i] += (((1e4/(t&16383*2+8000))&2)*10)

        // bass
        //left[i] += (x=t*('9754'[t>>16&3]&15)/24&100)*y/5e4

        //left[i] += ((t>>8^t>>10|t>>14|x)&63)

        /*
        with(Math) {
          left[i] += (((j=Math.round(t/1500)%16))%8==1|(j==3)|(j==6)) * sin(200-200*Math.sqrt((t%6000)/6000))*50 + Math.random()*40*(j%8==5) + (((t|(t>>9|t>>7))*t&(t>>11|t>>9) )&63)*(j%3==0);
        }
        */

        // white noise
        /*
        with(Math) {
          left[i] += (a=(1-((t&0xfff)/0xfff)));
          left[i] += Math.max(
            Math.min(
              (
                sin(
                  (y=([0.25,0.30,0.17,0.20][(t>>12)&3]))
                  * (z=0.313)*t
                )
                + sin(y*z*t*1.001)
                + sin(y*z*t*1.003)
                + sin(y*z*t*1.005)
              )
              *
              (
                sin(t*0.0001) + 1.1
              ) * 44 * a,
              63
            ),
            -64
          ) * Math.min(t/0x1ffff,1)

          left[i] += Math.max(
            Math.min(
              (
                sin((t&0xfff)*0.07*a*a*a)
                *64
              )
              *
              ((0x55355535>>(t>>12&31))&1)*a*2.2 +((d=(sin((t^0x1ffff)*0.1*t*a)*64)*a))*((0xb4446444>>((t>>12)  &31))&1)*a*0.9 +((a*d*((t>>10&3)==0)&0xff))*a*0.04 ,63),-64)*(t>0x3ffff)
        }
        */

        //left[i] += ([1.122,1.259,1.498,1.681,1.887][((t >> 12) ^ ((t >> 10)+ 3561)) %5]) * t & 128 | (([1.122,1.259,1.498,1.681,1.887][((t >> 11) ^ ((t >> 9) +2137)) %5]) * t) & ((t>>14)%120+8) | (t>>4);

        // square wave
        //left[i] = t & 512;
        // debugging
        // sierpinski
        //left[i] += t*9&t>>4|t*5&t>>7|t*3&t/1024;
        //left[i] += Math.sin(t>>(t/18500)%10) * 500;
        //left[i] += (t*9&t>>4|t*5&t>>7|t*3&t/1024)-1;

        //left[i] += t>>6&1?t>>5:-t>>4;

        //left[i] = (t&255)^(-t*0.75);
        //left[i] = (t*0.01)^(t*0.001)^(-t*0.75);
        /*
        with(Math) {
          left[i] += (f=0x3fffff/t)*0+(y=((((((t>>1)^(t)^(t>>2))>>(10+((t<65535) <<2))&0x3)+1)*(((t-65535)>>(16-(t>>17&1))&0x3^1)+1) )*t))*0+(((y*1.33)&255)>sin(t*0.00004+f)*110+128)+127;
        }
        */

        SS=(notes,octave,rate,len) =>
          notes.charCodeAt((t>>rate)%len) - 32 // Is the note a whitespace?
            ? 31 & t * Math.pow(2, notes.charCodeAt((t>>rate)%len) / 12 - octave)
            : 0
        // synth thing

        //p="4444"[t>>15&3]&7;

        // envelope
        //e=Math.min(1, (5e3/(y=t&8191*3)));

        // kick drum with variation
        left[i] += (((y=1e4/(t&16383*(
          (t>>15)%16 - 15 ? 1 : 0.75
        )))&1)*35)
        right[i] = left[i];
        //right[i] += (((1e4/(y=t&16383))&1)*35)

        left[i] += (SS("7050",8,17,4)&255) / y;
        right[i] += (SS("7050",8,17,4)&255) / y;

        if(!i) console.log(y);

        // cool noise percussion stuff
        e=Math.min(1, (2e1/((t>>4)%256))) * 0.2;

        left[i] += ((t*(t>>5)*t)&128)*e;
        right[i] += ((t*(t>>4)*t)&128)*e;

        // sierpinski thing
        left[i] += ((t*(t>>11))&128)*e;
        right[i] += ((t*(t>>12))&128)*e;

        //left[i] += (t*p/6&128)*e;
        //right[i] += ((t*p+350)/4&128)*e;
        //left[i] += (((((t>>12)^(t>>12)-2)%11*t)/4|t>>13)&127);

        // arpeggio
        left[i] += (t/4&4096?SS((t>>17)%2 ? '027' : '037',5,11,3)*(4096-(t&4095))>>11 : 0) / y;
        right[i] += (t/4&4096?SS((t>>17)%2 ? '072' : '073',5,11,3)*(4096-(t&4095))>>11 : 0) / y;
        //right[i] += t/4&4096?SS('037',5,11,3)*(4096-(t&4095))>>11 : 0;
        //left[i] += t/4&4096?SS('027',5,11,3)*(4096-(t&4095))>>11 : 0;
        //left[i] += t/4&4096?SS('-23',5,11,3)*(4096-(t&4095))>>11 : 0;
        //left[i] += (t/4&4096?SS('237',5,11,3)*(4096-(t&4095))>>11 : 0);
        //right[i] = left[i];

        // limit volume while testing
        left[i] /= 512;
        //left[i] = Math.max(-0.125, Math.min(0.125, left[i]));
        right[i] /= 512;
        //right[i] = Math.max(-0.125, Math.min(0.125, right[i]));
      })
    }
  );

  // vertex shader
  shaderSource(S=createShader(35633), require('./vertex.glsl')); // VERTEX_SHADER = 35633
  compileShader(S);attachShader(P,S);

  // fragment shader
  shaderSource(S=createShader(35632), require('./fragment.glsl')); // FRAGMENT_SHADER = 35632
  compileShader(S);attachShader(P,S);

  // Log compilation errors
  // if (!getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
  //   throw getShaderInfoLog(S);
  // }

  bindBuffer(34962, createBuffer(c.parentElement.style.margin = 0)); // ARRAY_BUFFER = 34962
  // 1st argument to enableVertexAttribArray used to be 0, but undefined works
  // 1st argument to vertexAttribPointer used to be 0, but undefined works
  vertexAttribPointer(
    enableVertexAttribArray(
      bufferData(34962, Int8Array.of(-3, 1, 1, -3, 1, 1), 35044) // 35044 = gl.STATIC_DRAW
    ),
  2, 5120, r(c.style.height = '100vh'), linkProgram(P), useProgram(P)); // BYTE = 5120
}

/*
// generate music
for(var t=0,S='RIFF_oO_WAVEfmt '+atob('EAAAAAEAAQAcRwAAHEcAAAEACABkYXRh')+'data';++t<1e5;)S+=String.fromCharCode(eval(

// formula
'((((u=t&0x3fff)&0+((u+1<<(18+(t>>12&1*6)))/u)&255)/(u>>8))&240-128)'

// failsafe thing
+ '&255'
));

// play music
new Audio( 'data:audio/wav;base64,'+btoa(S) ).play();
*/
/*
a = new AudioContext();

dly = a.createDelay();
osc1env = a.createGain();
osc1 = a.createOscillator();
lfo = a.createOscillator();

osc1.type = 'sawtooth';
osc1.frequency.value = 40;

lfo.type = 'sawtooth';
lfo.frequency.value = 2;
lfo.connect(osc1env.gain);

dly.delayTime.value = 2 / 3;

osc1.connect(osc1env);
osc1env.connect(a.destination);
osc1env.connect(dly);
dly.connect(a.destination);

lfo.start();
osc1.start();
*/
