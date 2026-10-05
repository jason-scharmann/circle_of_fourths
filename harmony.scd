(
{
  var chooseAfterDominant;

  chooseAfterDominant = { |cameFromMinor|
    if(cameFromMinor) {
      // Preserve the existing major ii-V-I opportunity.
      [\dom7, \min7, \maj7].wchoose(
        [0.50, 0.30, 0.20]
      )
    } {
      // Ordinary minor and half-diminished introductions
      // are equally likely at eligible decision points.
      [\dom7, \min7, \min7b5].wchoose(
        [0.40, 0.30, 0.30]
      )
    }
  };

  (
    next: { |quality, previousQuality, role = \cycle|
      var nextQuality = \dom7;
      var nextRole = \cycle;
      var rootDelta = 5;

      case
      { role == \tritoneSub } {
        // Complete the existing chromatic resolution.
        rootDelta = -1;
      }

      { role == \minorCadenceV } {
        // A committed minor V must resolve to i(maj7).
        if(quality != \dom7) {
          Error("Minor cadence V must be dom7.").throw;
        };

        nextQuality = \minMaj7;
      }

      { quality == \min7b5 } {
        // ii half-diminished: commit the following V.
        nextQuality = \dom7;
        nextRole = \minorCadenceV;
      }

      { quality == \min7 } {
        nextQuality = \dom7;
      }

      {
        (quality == \maj7)
        or: { quality == \minMaj7 }
      } {
        // Both tonic qualities resume the fourth cycle.
        nextQuality = \dom7;
      }

      { quality == \dom7 } {
        if(0.20.coin) {
          nextQuality = \dom7;
          nextRole = \tritoneSub;
          rootDelta = 6;
        } {
          nextQuality = chooseAfterDominant.value(
            previousQuality == \min7
          );
        };
      }

      {
        Error(
          "Unknown chord quality: " ++ quality
        ).throw;
      };

      (
        quality: nextQuality,
        role: nextRole,
        rootDelta: rootDelta
      )
    }
  )
}.value
)
