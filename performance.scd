(
{
  var figure, traversal, realize, harmony;
  var bass, bassline, lead;
  var drums, ride;
  var comp, comping, compRhythm;
  var pattern;

  figure = thisProcess.interpreter.executeFile(
    "figure.scd".resolveRelative
  );

  traversal = thisProcess.interpreter.executeFile(
    "traversal.scd".resolveRelative
  );

  realize = thisProcess.interpreter.executeFile(
    "realize.scd".resolveRelative
  );

  harmony = thisProcess.interpreter.executeFile(
    "harmony.scd".resolveRelative
  );

  bass = thisProcess.interpreter.executeFile(
    "bass.scd".resolveRelative
  );

  bassline = thisProcess.interpreter.executeFile(
    "bassline.scd".resolveRelative
  );

  lead = thisProcess.interpreter.executeFile(
    "lead.scd".resolveRelative
  );

  drums = thisProcess.interpreter.executeFile(
    "drums.scd".resolveRelative
  );

  ride = thisProcess.interpreter.executeFile(
    "ride.scd".resolveRelative
  );

  comp = thisProcess.interpreter.executeFile(
    "comp.scd".resolveRelative
  );

  comping = thisProcess.interpreter.executeFile(
    "comping.scd".resolveRelative
  );

  compRhythm = thisProcess.interpreter.executeFile(
    "comp-rhythm.scd".resolveRelative
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
    var realization, realized;
    var previousCompVoicing = nil;
    var compVoicing, compKind, compEvents;

    // Ride continues independently throughout.
    sp.par(
      Pbindf(
        Pseq(ride[\basic].value, inf),
        \instrument, drums[\rideName],
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

      realization = if(quality == \min7b5) {

        // Favor triplet activity; retain all four chord tones.
        [
          \swing,
          \tripletTail,
          \middleDelay,
          \middlePush,
          \tripletLaunch,
          \tripletAnswer,
          \tripletDisplace,
          \restTriplets,
          \shortRest
        ].wchoose([
          0.10, 0.10, 0.05, 0.05,
          0.15, 0.15, 0.10, 0.16, 0.14
        ])

      } {
        if(quality == \dom7) {

          // Preserve the established dominant character.
          // Occasionally introduce the new rhythms.
          [
            \swing,
            \tripletTail,
            \omitSecondHold,
            \omitSecondRest,
            \tripletLaunch,
            \tripletAnswer,
            \restTriplets
          ].wchoose([
            0.22, 0.20, 0.20, 0.20,
            0.06, 0.06, 0.06
          ])

        } {

          // min7, maj7, and minMaj7:
          // Full rhythmic vocabulary.
          [
            \swing,
            \tripletTail,
            \omitSecondHold,
            \omitSecondRest,
            \middleDelay,
            \middlePush,
            \tripletLaunch,
            \tripletAnswer,
            \tripletDisplace,
            \restTriplets,
            \shortRest
          ].wchoose([
            0.14, 0.13, 0.10, 0.09,
            0.08, 0.08, 0.08, 0.08,
            0.06, 0.08, 0.08
          ])
        }
      };

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
      compKind = [
        \single,
        \double,
        \charleston,
        \reverseCell,
        \silent
      ].wchoose([
        0.30,
        0.20,
        0.20,
        0.15,
        0.15
      ]);

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
      // This is the only sparse probability decision (14%).
      if(0.14.coin) {
        if(quality == \min7b5) {

          // Retain the defining b3, b5, and b7 even when comping rests.
          realization = [
            \halfDimAir,
            \halfDimPulse,
            \halfDimHinge
          ].wchoose([
            0.45,
            0.35,
            0.20
          ]);

        } {
          if(
            (compKind != \silent)
            and: {
              (
                leadResult[\nextThird]
                - leadResult[\notes][0]
              ).abs <= 4
            }
          ) {
            realization = [
              \thirdPulse,
              \guideSpace,
              \guidePickup,
              \guideEcho
            ].wchoose([
              0.18,
              0.27,
              0.27,
              0.28
            ]);
          } {
            // Always articulate both guide tones if piano is silent.
            realization = [
              \guideSpace,
              \guidePickup,
              \guideEcho
            ].wchoose([
              0.34,
              0.33,
              0.33
            ]);
          };
        };
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
      drums[\install].value;
    },

    pattern: pattern
  )
}.value
)
