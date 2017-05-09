/*
 * Copyright 2017 Rasmus Eskola
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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

const bound = (min, value, max) => {
  return Math.max(min, Math.min(value, max));
};

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

  // pan
  let panNode = audioCtx.createStereoPanner();
  let panLFO = audioCtx.createOscillator();
  let panAmt = audioCtx.createGain();

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

  panNode.connect(out);
  panLFO.connect(panAmt);
  panAmt.connect(panNode.pan);

  preFilter.connect(biquadFilter);
  biquadFilter.connect(delay);
  biquadFilter.connect(panNode);

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
    panNode,
    panLFO,
    panAmt,
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
      q = Math.pow(params[21] / 255, 2) * 10,
      dist = params[22] * 1e-5,
      drive = params[23] / 32,
      panAmt = params[24] / 255,
      panFreq = 3.14 * Math.pow(2, params[25] - 9) / rowLen,
      dlyAmt = params[26] / 255,
      dly = params[27] * rowLen;

    // master
    column.out.gain.value = drive;
    column.preFilter.gain.value = 1;

    // oscillators
    column.osc1env.gain.value = 0;
    column.osc2env.gain.value = 0;
    column.osc3env.gain.value = 0;

    column.osc1.type = osc1t;
    column.osc2.type = osc2t;

    // pan
    column.panAmt.gain.value = panAmt;
    // TODO: correct value?
    column.panLFO.frequency.value = panFreq;

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
      panAmt = params[24] / 511,
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

  // Program notes in reverse order and keep track of the next note.
  // If next note is too close, don't program in sustain / release events
  notes.reverse();
  let nextNote;

  notes.forEach((note, index) => {
    if (!note) return;

    //let startTime = t + rowLen * index;
    let startTime = when + rowLen * (notes.length - index - 1);
    let osc1freq = 440 * Math.pow(2, (note + params[2] - 272) / 12);
    let osc2freq = 440 * Math.pow(2, (note + params[6] - 272 + 0.0125 * params[7]) / 12);
    column.osc1.frequency.setValueAtTime(osc1freq, startTime);
    column.osc2.frequency.setValueAtTime(osc2freq, startTime);

    // Envelope modulated frequency on oscillator 1
    if (o1xenv) {
      column.osc1.frequency.setValueAtTime(0, startTime);
      column.osc1.frequency.linearRampToValueAtTime(osc1freq, startTime + attack);

      if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc1.frequency.setValueAtTime(osc1freq, startTime + attack + sustain);
        // release
        column.osc1.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
      }
    }

    // Envelope modulated frequency on oscillator 2
    if (o2xenv) {
      column.osc2.frequency.setValueAtTime(0, startTime);
      column.osc2.frequency.linearRampToValueAtTime(osc2freq, startTime + attack);

      if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc2.frequency.setValueAtTime(osc2freq, startTime + attack + sustain);
        // release
        column.osc2.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
      }
    }

    let a = startTime + attack;
    let s = startTime + attack + sustain;
    let r = startTime + attack + sustain + release;

    // small delta required so clamped events don't overlap
    let d = 0.001;

    // don't overlap frequent events
    if (nextNote) {
      a = Math.min(nextNote - d, a);
      s = Math.min(nextNote - d, s);
      r = Math.min(nextNote - d, r);
    }

    // attack
    column.osc1env.gain.setValueAtTime(0, startTime);
    column.osc2env.gain.setValueAtTime(0, startTime);
    column.osc3env.gain.setValueAtTime(0, startTime);
    column.osc1env.gain.linearRampToValueAtTime(o1vol, a);
    column.osc2env.gain.linearRampToValueAtTime(o2vol, a);
    column.osc3env.gain.linearRampToValueAtTime(noiseVol, a);

    if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc1env.gain.setValueAtTime(o1vol, s);
        column.osc2env.gain.setValueAtTime(o2vol, s);
        column.osc3env.gain.setValueAtTime(noiseVol, s);

        // release
        let releaseVal = bound(0, 1 - (r - startTime) / (attack + sustain + release), 1);
        column.osc1env.gain.linearRampToValueAtTime(o1vol * releaseVal, r);
        column.osc2env.gain.linearRampToValueAtTime(o2vol * releaseVal, r);
        column.osc3env.gain.linearRampToValueAtTime(noiseVol * releaseVal, r);
    }

    nextNote = startTime;
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
    this.mixer.gain.value = 0.4;

    // connect each column in each track to the mixer and start oscillators
    this.tracks.forEach(track =>
      track.forEach(column => {
        column.out.connect(this.mixer);
        column.osc1.start();
        column.osc2.start();
        //column.osc3.start(); // TODO: start/stop noise osc
        column.lfo.start();
        column.panLFO.start();
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

      column.panLFO.disconnect();
      column.panLFO = audioCtx.createOscillator();
      column.panLFO.connect(column.panAmt);
      column.panLFO.start();

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
      column.osc1.frequency.cancelScheduledValues(0);
      column.osc2.frequency.cancelScheduledValues(0);
      column.osc1env.gain.cancelScheduledValues(0);
      column.osc2env.gain.cancelScheduledValues(0);
      column.osc3env.gain.cancelScheduledValues(0);
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
