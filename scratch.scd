(
{
    var realize, notes, styles;

    realize = thisProcess.interpreter.executeFile(
        "realize.scd".resolveRelative
    );

    notes = [64, 67, 72, 71];

    styles = [
        \thirdPulse,
        \guideSpace,
        \guidePickup
    ];

    styles.do { |style|
        var events, duration;

        events = realize[style].value(notes);

        duration = events.sum { |event|
            event[\dur]
        };

        if((duration - 2).abs > 0.00001) {
            Error(
                "Invalid sparse duration: " ++ style
            ).throw;
        };

        [style, events].postln;
    };

    "Sparse realization checks passed.".postln;
}.value
)
