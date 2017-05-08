var soundbox;
(function() {
soundbox = {};

var audioCtx = new AudioContext();
soundbox.audioCtx = audioCtx;

const waveforms = [
  "sine",
  "square",
  "sawtooth",
  "triangle",
];

const createNoiseOsc = () => {
  let osc = audioCtx.createScriptProcessor(2048, 1, 1);

  osc.onaudioprocess = e => {
      var output = e.outputBuffer.getChannelData(0);
      for (var i = 0; i < 2048; i++) {
          output[i] = Math.random() * 2 - 1;
      }
  }

  return osc;
};

const filters = [
  "highpass",
  "lowpass",
  "bandpass",
];

let initCol = () => {
  //  master out / "post" filter mixer
  let out = audioCtx.createGain();
  // "pre" filter mixer
  let preFilter = audioCtx.createGain();

  // oscillator envelopes
  let osc1env = audioCtx.createGain();
  let osc2env = audioCtx.createGain();
  let osc3env = audioCtx.createGain();

  // make sure oscillators start out muted
  osc1env.gain.value = 0;
  osc2env.gain.value = 0;
  osc3env.gain.value = 0;

  // oscillators
  let osc1 = audioCtx.createOscillator();
  let osc2 = audioCtx.createOscillator();
  let osc3 = createNoiseOsc();

  // delay
  let delayGain = audioCtx.createGain();
  let delay = audioCtx.createDelay();

  // filter
  let biquadFilter = audioCtx.createBiquadFilter();

  // lfo
  let lfo = audioCtx.createOscillator();
  let modulationGain = audioCtx.createGain();

  osc1env.connect(preFilter);
  osc2env.connect(preFilter);
  osc3env.connect(preFilter);

  osc1.connect(osc1env);
  osc2.connect(osc2env);
  osc3.connect(osc3env);

  delayGain.connect(out);
  delay.connect(delayGain);

  preFilter.connect(biquadFilter);
  biquadFilter.connect(delay);
  biquadFilter.connect(out);

  lfo.connect(modulationGain);
  modulationGain.connect(biquadFilter.frequency);

  return {
    out,
    preFilter,
    osc1env,
    osc2env,
    osc3env,
    osc1,
    osc2,
    osc3,
    delayGain,
    delay,
    biquadFilter,
    lfo,
    modulationGain,
  };
};

let initTrack = () => {
  // Support max 4 columns per track
  return [
    initCol(),
    initCol(),
    initCol(),
    initCol(),
  ];
};

let setParams = (params, rowLen, column) => {
  // TODO get rid of unused params
  var osc1t = waveforms[params[0]],
      o1vol = params[1] / 255,
      o1xenv = params[3],
      osc2t = waveforms[params[4]],
      o2vol = params[5] / 255,
      o2xenv = params[8],
      noiseVol = params[9] / 255,
      attack = params[10] * params[10] * 4 / 44100,
      sustain = params[11] * params[11] * 4 / 44100,
      release = params[12] * params[12] * 4 / 44100,
      arp = params[13],
      arpInterval = rowLen * Math.pow(2, 2 - params[14]),
      oscLFO = waveforms[params[15]],
      lfoAmt = params[16] / 255,
      lfoFreq = Math.pow(2, params[17] - 9) / rowLen * 2,
      fxLFO = params[18],
      fxFilter = params[19],
      fxFreq = params[20] * 20,
      q = 1 - params[21] / 255,
      dist = params[22] * 1e-5,
      drive = params[23] / 32,
      panAmt = params[24] / 512,
      panFreq = 6.283184 * Math.pow(2, params[25] - 9) / rowLen,
      dlyAmt = params[26] / 255,
      dly = params[27] * rowLen;

    // master
    column.out.gain.value = 1;
    column.preFilter.gain.value = 1;

    // oscillators
    column.osc1env.gain.value = 0;
    column.osc2env.gain.value = 0;
    column.osc3env.gain.value = 0;

    column.osc1.type = osc1t;
    column.osc2.type = osc2t;

    // delay
    column.delayGain.gain.value = dlyAmt;

    column.delay.delayTime.value = dly;

    // filter
    column.biquadFilter.type = filters[fxFilter - 1];
    column.biquadFilter.frequency.value = fxFreq;
    column.biquadFilter.Q.value = q;

    if (fxLFO) {
      // lfo
      column.lfo.type = oscLFO;
      column.lfo.frequency.value = lfoFreq;

      // TODO: whats the correct value?
      column.modulationGain.gain.value = lfoAmt * 1000;
      //modulationGain.gain.value = 1000;

      //column.lfo.start(); // TODO: where to do this?
    } else {
      // disable LFO
      column.modulationGain.gain.value = 0;
    }
};

let setNotes = (params, patterns, patternOrder, rowLen, patternLen, when, column, cIndex) => {
  // TODO get rid of unused params
  var osc1t = waveforms[params[0]],
      o1vol = params[1] / 255,
      o1xenv = params[3],
      osc2t = waveforms[params[4]],
      o2vol = params[5] / 255,
      o2xenv = params[8],
      noiseVol = params[9] / 255,
      attack = params[10] * params[10] * 4 / 44100,
      sustain = params[11] * params[11] * 4 / 44100,
      release = params[12] * params[12] * 4 / 44100,
      arp = params[13],
      arpInterval = rowLen * Math.pow(2, 2 - params[14]),
      oscLFO = waveforms[params[15]],
      lfoAmt = params[16] / 255,
      lfoFreq = Math.pow(2, params[17] - 9) / rowLen * 2,
      fxLFO = params[18],
      fxFilter = params[19],
      fxFreq = params[20] * 20,
      q = 1 - params[21] / 255,
      dist = params[22] * 1e-5,
      drive = params[23] / 32,
      panAmt = params[24] / 512,
      panFreq = 6.283184 * Math.pow(2, params[25] - 9) / rowLen,
      dlyAmt = params[26] / 255,
      dly = params[27] * rowLen;

  // parse song into more suitable format
  let notes = [];
  let effects = [];

  // program in all notes
  patternOrder.forEach((patIdx, numPattern) => {
    // loop over patterns
    if (patIdx) {
      let pattern = patterns[patIdx - 1];
      let n = pattern.n.slice(cIndex * patternLen, cIndex * patternLen + patternLen);
      let f = pattern.f.slice(cIndex * patternLen, cIndex * patternLen + patternLen);

      for (let i = 0; i < patternLen; i++) {
        notes[numPattern * patternLen + i] = n[i];
        effects[numPattern * patternLen + i] = f[i];
      }
    }
  });

  // TODO: arpeggio
  //var o1t = getnotefreq(n + (arp & 15) + params[2] - 128);
  //var o2t = getnotefreq(n + (arp & 15) + params[6] - 128) * (1 + 0.0008 * params[7]);
  notes.forEach((note, index) => {
    if (!note) return;

    //let startTime = t + rowLen * index;
    let startTime = when + rowLen * index;
    let osc1freq = 440 * Math.pow(2, (note + params[2] - 272) / 12);
    let osc2freq = 440 * Math.pow(2, (note + params[6] - 272 + 0.008 * params[7]) / 12);
    column.osc1.frequency.setValueAtTime(osc1freq, startTime);
    column.osc2.frequency.setValueAtTime(osc2freq, startTime);

    if (o1xenv) {
      column.osc1.frequency.setValueAtTime(0, startTime);
      column.osc1.frequency.linearRampToValueAtTime(osc1freq, startTime + attack);
      // sustain
      column.osc1.frequency.setValueAtTime(osc1freq, startTime + attack + sustain);
      // release
      column.osc1.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
    }

    if (o2xenv) {
      column.osc2.frequency.setValueAtTime(0, startTime);
      column.osc2.frequency.linearRampToValueAtTime(osc2freq, startTime + attack);
      // sustain
      column.osc2.frequency.setValueAtTime(osc2freq, startTime + attack + sustain);
      // release
      column.osc2.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
    }

    // attack
    column.osc1env.gain.setValueAtTime(0, startTime);
    column.osc2env.gain.setValueAtTime(0, startTime);
    column.osc3env.gain.setValueAtTime(0, startTime);
    column.osc1env.gain.linearRampToValueAtTime(o1vol, startTime + attack);
    column.osc2env.gain.linearRampToValueAtTime(o2vol, startTime + attack);
    column.osc3env.gain.linearRampToValueAtTime(noiseVol, startTime + attack);
    // sustain
    column.osc1env.gain.setValueAtTime(o1vol, startTime + attack + sustain);
    column.osc2env.gain.setValueAtTime(o2vol, startTime + attack + sustain);
    column.osc3env.gain.setValueAtTime(noiseVol, startTime + attack + sustain);
    // release
    column.osc1env.gain.linearRampToValueAtTime(0, startTime + attack + sustain + release);
    column.osc2env.gain.linearRampToValueAtTime(0, startTime + attack + sustain + release);
    column.osc3env.gain.linearRampToValueAtTime(0, startTime + attack + sustain + release);
  });
};

soundbox.MusicGenerator = function() {
    // Support max 8 tracks
    this.tracks = [
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
    ];

    this.mixer = audioCtx.createGain();
    this.mixer.gain.value = 0.25;

    // connect each column in each track to the mixer and start oscillators
    this.tracks.forEach(track =>
      track.forEach(column => {
        column.out.connect(this.mixer);
        column.osc1.start();
        column.osc2.start();
        //column.osc3.start(); // TODO: start/stop noise osc
        column.lfo.start();
      })
    );
};

soundbox.MusicGenerator.prototype.play = function(song, when = 0) {
  song.songData.forEach((track, tIndex) =>
    this.tracks[tIndex].forEach((column, cIndex) => {
      // TODO: better way of resetting lfo?
      // currently it's recreated
      column.lfo.disconnect();
      column.lfo = audioCtx.createOscillator();
      column.lfo.connect(column.modulationGain);
      column.lfo.start();

      // Set initial parameters for each column
      setParams(track.i, song.rowLen / 44100, column);

      // Program notes for each oscillator
      setNotes(track.i, track.c, track.p, song.rowLen / 44100, song.patternLen, when, column, cIndex);
    })
  );
};
soundbox.MusicGenerator.prototype.stop = function() {
  this.tracks.forEach(track =>
    track.forEach(column => {
      column.osc1.frequency.cancelScheduledValues(audioCtx.currentTime);
      column.osc2.frequency.cancelScheduledValues(audioCtx.currentTime);
      column.osc1env.gain.cancelScheduledValues(audioCtx.currentTime);
      column.osc2env.gain.cancelScheduledValues(audioCtx.currentTime);
      column.osc3env.gain.cancelScheduledValues(audioCtx.currentTime);
      column.osc1env.gain.value = 0;
      column.osc2env.gain.value = 0;
      column.osc3env.gain.value = 0;

      column.lfo.stop();
    })
  );
};
soundbox.MusicGenerator.prototype.connect = function(target) {
  this.mixer.connect(target);
};

})();
