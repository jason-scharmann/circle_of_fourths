(
{
  var name, synthDef;

  name = \circleLead;

  synthDef = SynthDef(name, {
    |out = 0, freq = 440, amp = 0.10, gate = 1, pan = 0|

    var ampEnv, brightEnv;
    var pitchRatio, vibratoDepth, soundingFreq;
    var source, body, breath, sig;
    var cutoff;

    ampEnv = EnvGen.kr(
      Env.adsr(
        0.01,   // attack
        0.10,   // decay
        0.85,   // sustain
        0.10,   // release
        1,
        -4
      ),
      gate,
      doneAction: 2
    );

    // Brightness swells at the attack, then relaxes slightly.
    brightEnv = EnvGen.kr(
      Env.adsr(
        0.005,
        0.12,
        0.55,
        0.08,
        1,
        -3
      ),
      gate
    );

    // Slight upward lip/scoop into the pitch.
    pitchRatio = XLine.kr(
      Rand(0.985, 0.995),
      1,
      0.035
    );

    // Delayed, restrained vibrato.
    vibratoDepth = Line.kr(
      0,
      Rand(0.0012, 0.0020),
      0.22
    );

    soundingFreq = freq
    * pitchRatio
    * (1 + SinOsc.kr(5.1, 0, vibratoDepth));

    // Buzzier brass-like excitation.
    source =
    (Saw.ar(soundingFreq) * 0.55)
    + (Pulse.ar(soundingFreq, 0.46) * 0.12);

    // Mild lip-like saturation.
    source = (source * 2.0).tanh;

    // Brass gets brighter as excitation increases.
    cutoff = (
      (soundingFreq * 4)
      + (brightEnv * 3400)
    ).clip(900, 6500);

    source = RLPF.ar(
      source,
      cutoff,
      0.32
    );

    // Broad horn/body emphasis.
    body = BPF.ar(
      source,
      [500, 900, 1600, 2500],
      [0.80, 0.65, 0.45, 0.35],
      [0.30, 0.26, 0.16, 0.09]
    ).sum;

    breath = BPF.ar(
      PinkNoise.ar(0.015),
      3000,
      0.8
    ) * brightEnv;

    sig =
    (source * 0.75)
    + (body * 0.50)
    + breath;

    sig = HPF.ar(sig, 100);
    sig = LPF.ar(sig, 5800);
    sig = (sig * 1.1).tanh;

    Out.ar(
      out,
      Pan2.ar(sig * ampEnv * amp, pan)
    );
  });

  (
    name: name,

    install: {
      synthDef.add;
    }
  )
}.value
)
