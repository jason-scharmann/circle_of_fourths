(
{
  var name, synthDef;

  name = \circleBass;

  synthDef = SynthDef(name, {
    |out = 0, freq = 110, amp = 0.16, gate = 1, pan = 0|

    var ampEnv, excEnv;
    var excitation, string, core, body, sig;
    var brightness;

    ampEnv = EnvGen.kr(
      Env.asr(0.005, 1, 0.20, -4),
      gate,
      doneAction: 2
    );

    excEnv = EnvGen.kr(
      Env.perc(0.001, 0.04, 1, -4)
    );

    brightness = Rand(1600, 2200);

    excitation = PinkNoise.ar(0.8) * excEnv;

    string = Pluck.ar(
      excitation,
      Impulse.kr(0),
      0.05,
      freq.reciprocal,
      2.8,
      0.45
    );

    // Gives the note some physical weight underneath the pluck.
    core =
    (SinOsc.ar(freq) * 0.45)
    + (LFTri.ar(freq) * 0.25);

    // Wooden-body coloration.
    body = BPF.ar(
      string,
      [90, 180, 320],
      [0.70, 0.55, 0.45],
      [0.50, 0.32, 0.18]
    ).sum;

    sig =
    (string * 0.70)
    + (core * 0.55)
    + (body * 0.70);

    sig = LPF.ar(sig, brightness);
    sig = LeakDC.ar(sig);

    // Very mild compression/saturation.
    sig = (sig * 1.2).tanh;

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
