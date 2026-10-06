(
{
  var nearest, chordQuality;
  var fits, nextThird;

  nearest = thisProcess.interpreter.executeFile(
    "../common/pitch/nearest.scd".resolveRelative
  );

  chordQuality = thisProcess.interpreter.executeFile(
    "../common/harmony/chord-quality.scd".resolveRelative
  );

  nextThird = {
    |third, notes, quality, nextQuality,
    rootDelta, low, high|

    var rootPitchClass;
    var nextRootPitchClass;
    var nextThirdPitchClass;

    rootPitchClass = (
      third
      - chordQuality[\thirdOffset].value(quality)
    ) % 12;

    nextRootPitchClass = (
      rootPitchClass + rootDelta
    ) % 12;

    nextThirdPitchClass = (
      nextRootPitchClass
      + chordQuality[\thirdOffset].value(nextQuality)
    ) % 12;

    nearest[\inRange].value(
      nextThirdPitchClass,
      notes.last,
      low,
      high
    )
  };

  fits = {
    |notes, third, low, high,
    quality, nextQuality, rootDelta|

    var required, leapsFit, followingThird;

    followingThird = nextThird.value(
      third,
      notes,
      quality,
      nextQuality,
      rootDelta,
      low,
      high
    );

    required = notes ++ [followingThird];

    leapsFit = true;

    notes.doAdjacentPairs { |a, b|
      if((b - a).abs > 7) {
        leapsFit = false;
      };
    };

    (required.minItem >= low) and: {
      (required.maxItem <= high) and: {
        leapsFit
      }
    };
  };

  (
    step: {
      |figure, third, direction, low, high,
      quality = \dom7,
      nextQuality = \dom7,
      rootDelta = 5|

      var chosen, candidates, notes;

      chosen = direction;

      candidates = figure[\variants]
        .value(third, chosen, quality)
        .select { |candidate|
          fits.value(
            candidate,
            third,
            low,
            high,
            quality,
            nextQuality,
            rootDelta
          )
        };

      if(candidates.isEmpty) {
        chosen = if(chosen == \up) {
          \down
        } {
          \up
        };

        candidates = figure[\variants]
          .value(third, chosen, quality)
          .select { |candidate|
            fits.value(
              candidate,
              third,
              low,
              high,
              quality,
              nextQuality,
              rootDelta
            )
          };
      };

      if(candidates.isEmpty) {
        Error(
          "No valid figure fits the constraints."
        ).throw;
      };

      notes = candidates.choose;

      (
        notes: notes,

        nextThird: nextThird.value(
          third,
          notes,
          quality,
          nextQuality,
          rootDelta,
          low,
          high
        ),

        direction: chosen
      )
    }
  )
}.value
)
