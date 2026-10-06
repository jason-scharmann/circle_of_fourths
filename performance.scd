(
{
  var tempo = 96 / 60;
  var beatsPerBar = 4;

  var figure, traversal, realize, leadRhythm, harmony;
  var bass, bassline, lead;
  var rideSynth, ride;
  var comp, comping, compRhythm;
  var pattern;

  figure = thisProcess.interpreter.executeFile(
    "lead/figure.scd".resolveRelative
  );

  traversal = thisProcess.interpreter.executeFile(
    "lead/traversal.scd".resolveRelative
  );

  realize = thisProcess.interpreter.executeFile(
    "lead/realize.scd".resolveRelative
  );

  leadRhythm = thisProcess.interpreter.executeFile(
    "lead/rhythm.scd".resolveRelative
  );

  harmony = thisProcess.interpreter.executeFile(
    "harmony.scd".resolveRelative
  );

  bass = thisProcess.interpreter.executeFile(
    "bass/synth.scd".resolveRelative
  );

  bassline = thisProcess.interpreter.executeFile(
    "bass/line.scd".resolveRelative
  );

  lead = thisProcess.interpreter.executeFile(
    "lead/synth.scd".resolveRelative
  );

  rideSynth = thisProcess.interpreter.executeFile(
    "drums/ride-synth.scd".resolveRelative
  );

  ride = thisProcess.interpreter.executeFile(
    "drums/ride.scd".resolveRelative
  );

  comp = thisProcess.interpreter.executeFile(
    "comp/synth.scd".resolveRelative
  );

  comping = thisProcess.interpreter.executeFile(
    "comp/voicing.scd".resolveRelative
  );

  compRhythm = thisProcess.interpreter.executeFile(
    "comp/rhythm.scd".resolveRelative
  );

  pattern = Pspawner({ |sp|
    var root = 36;
    var third = 64;
    var quality = \dom7;
    var role = \cycle;
    var previousQuality = nil;

    var transition;
    var nextQuality, nextRole, rootDelta;

    var leadResult, bassResult;
    var realization, sparseRealization, realized;
    var previousCompVoicing = nil;
    var compVoicing, compKind, compEvents;

    // Ride continues independently throughout.
    sp.par(
      Pbindf(
        Pseq(ride[\basic].value, inf),
        \instrument, rideSynth[\rideName],
        \amp, Pkey(\amp) * 0.55
      )
    );

    loop {
      // Make ONE harmonic decision for this transition.
      transition = harmony[\next].value(
        quality,
        previousQuality,
        role
      );

      nextQuality = transition[\quality];
      nextRole = transition[\role];
      rootDelta = transition[\rootDelta];

      // Lead uses that shared harmonic state.
      leadResult = traversal[\step].value(
        figure,
        third,
        [\up, \down].choose,
        48,
        84,
        quality,
        nextQuality,
        rootDelta
      );

      realization = leadRhythm[\base].value(
        quality
      );

      // Bass uses the SAME quality and root movement.
      bassResult = bassline[\step].value(
        root,
        36,
        60,
        quality,
        rootDelta
      );

      // Generate the comping voicing from the selected figure.
      compVoicing = comping[\voice].value(
        leadResult[\notes],
        previousCompVoicing
      );

      // Select one rhythmic realization.
      compKind = compRhythm[\choose].value;

      // Construct the actual comping events.
      compEvents = compRhythm[compKind].value(
        compVoicing
      );

      // Remember only chords that actually sounded.
      if(compKind != \silent) {
        previousCompVoicing = compVoicing;
      };

      // Sparse overrides follow comping selection, so a third-only
      // pulse is chosen only when the piano supplies the full harmony.
      sparseRealization = leadRhythm[\sparseOverride].value(
        quality,
        compKind,
        leadResult[\notes][0],
        leadResult[\nextThird]
      );

      if(sparseRealization.notNil) {
        realization = sparseRealization;
      };

      // Realize exactly once, after the final rhythm choice.
      realized = realize[realization].value(
        leadResult[\notes]
      );

      // One complete two-beat harmonic section.
      sp.seq(
        Ppar([
          Pbindf(
            Pseq(realized, 1),
            \instrument, lead[\name],
            \legato, 0.8,
            \amp, 0.06
          ),

          Pbindf(
            Pseq(bassResult[\events], 1),
            \instrument, bass[\name],
            \legato, 0.8,
            \amp, 0.16
          ),

          Pbindf(
            Pseq(compEvents, 1),
            \instrument, comp[\name]
          )
        ])
      );

      // Advance all shared state together.
      previousQuality = quality;
      quality = nextQuality;
      role = nextRole;

      third = leadResult[\nextThird];
      root = bassResult[\nextRoot];
    };
  });

  (
    install: {
      bass[\install].value;
      lead[\install].value;
      comp[\install].value;
      rideSynth[\install].value;
    },

    pattern: pattern,
    tempo: tempo,
    beatsPerBar: beatsPerBar
  )
}.value
)
