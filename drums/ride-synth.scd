(
{
    var rideName, rideDef;

    rideName = \circleRide;

    rideDef = SynthDef(rideName, {
        |out = 0, amp = 0.08, pan = 0, decay = 1.8|

        var strikeEnv, washEnv;
        var strike, metal, wash, sig;

        // Stick transient.
        strikeEnv = EnvGen.ar(
            Env.perc(0.001, 0.015, 1, -6)
        );

        strike = WhiteNoise.ar(0.05) * strikeEnv;

        // Metallic "ping."
        metal = Klank.ar(
            `[
                [2400, 3150, 4070, 5100, 6350, 7900],
                [1.0, 0.82, 0.64, 0.48, 0.34, 0.22],
                [0.35, 0.45, 0.55, 0.65, 0.75, 0.90]
            ],
            strike
        );

        // This is the SSSSSSSSSSSSS.
        washEnv = EnvGen.ar(
            Env.perc(
                0.004,
                decay,
                1,
                -2
            ),
            doneAction: 2
        );

        wash = WhiteNoise.ar(0.16);

        // Keep mainly the upper noisy spectrum.
        wash = HPF.ar(wash, 4200);

        // Add a little extra high metallic haze.
        wash = wash + (
            BPF.ar(
                WhiteNoise.ar(0.12),
                LFNoise1.kr(0.8).range(4200, 5200),
                0.55
            ) * LFNoise1.kr(1.3).range(0.25, 0.75)
        );
        wash = wash + (
            BPF.ar(
                WhiteNoise.ar(0.10),
                LFNoise1.kr(1.5).range(7600, 9800),
                0.45
            )
            * LFNoise1.kr(2.1).range(0.15, 0.55)
        );

        wash = LPF.ar(wash, 12000);
        wash = wash * washEnv;
        sig =
            (metal * 0.50)
            + (wash * 1.0);

        sig = (sig * 1.1).tanh;

        Out.ar(
            out,
            Pan2.ar(sig * amp, pan)
        );
    });

    (
        rideName: rideName,

        install: {
            rideDef.add;
        }
    )
}.value
)
