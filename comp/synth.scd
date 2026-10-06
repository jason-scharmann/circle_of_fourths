(
{
    var name, synthDef;

    name = \circleComp;

    synthDef = SynthDef(name, {
        |out = 0, freq = 440, amp = 0.06,
         pan = 0, decay = 0.30|

        var env, hitEnv;
        var tone, hit, sig;

        env = EnvGen.kr(
            Env.perc(0.012, decay, 1, -3),
            doneAction: 2
        );

        hitEnv = EnvGen.kr(
            Env.perc(0.001, 0.025, 1, -5)
        );

        // A fuller, more harmonically developed body.
        tone =
            (SinOsc.ar(freq) * 0.45)
            + (LFTri.ar(freq) * 0.35)
            + (VarSaw.ar(freq, 0, 0.4) * 0.30);

        // Small percussive hammer/tine attack.
        hit = BPF.ar(
            WhiteNoise.ar(0.18),
            (freq * 5).clip(900, 2800),
            0.65
        ) * hitEnv;

        sig = (tone * env) + hit;

        sig = HPF.ar(sig, 95);
        sig = LPF.ar(sig, 3800);
        sig = (sig * 1.4).tanh;

        Out.ar(
            out,
            Pan2.ar(sig * amp, pan)
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
