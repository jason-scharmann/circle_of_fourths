(
{
  var nearestPitch, thirdOffset;

  nearestPitch = { |pitchClass, target, low, high|
    var candidates, index;

    candidates = (low..high).select { |note|
      (note % 12) == pitchClass
    };

    if(candidates.isEmpty) {
      Error(
        "No bass pitch fits the requested range."
      ).throw;
    };

    index = candidates.minIndex { |note|
      (note - target).abs
    };

    candidates[index]
  };

  thirdOffset = { |quality|
    if(
      (quality == \dom7)
      or: { quality == \maj7 }
    ) {
      4
    } {
      if(
        [\min7, \min7b5, \minMaj7].includes(quality)
      ) {
        3
      } {
        Error(
          "Unknown chord quality: " ++ quality
        ).throw;
      }
    }
  };

  (
    step: {
      |root, low = 36, high = 60,
      quality = \dom7, rootDelta = 5|
      var nextRoot, chordThird;
      var nextRootPitchClass, thirdPitchClass;
      nextRootPitchClass = (root + rootDelta) % 12;

      nextRoot = nearestPitch.value(
        nextRootPitchClass,
        root,
        low,
        high
      );

      thirdPitchClass = (
        root + thirdOffset.value(quality)
      ) % 12;

      // Choose the octave of the current chord's 3rd
      // that leads most smoothly toward the next root.
      chordThird = nearestPitch.value(
        thirdPitchClass,
        nextRoot,
        low,
        high
      );

      (
        events: [
          (
            midinote: root,
            dur: 1
          ),
          (
            midinote: chordThird,
            dur: 1
          )
        ],

        nextRoot: nextRoot
      )
    }
  )
}.value
)
