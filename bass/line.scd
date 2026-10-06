(
{
  var nearest, chordQuality;

  nearest = thisProcess.interpreter.executeFile(
    "../common/pitch/nearest.scd".resolveRelative
  );

  chordQuality = thisProcess.interpreter.executeFile(
    "../common/harmony/chord-quality.scd".resolveRelative
  );

  (
    step: {
      |root, low = 36, high = 60,
      quality = \dom7, rootDelta = 5|

      var nextRoot, chordThird;
      var nextRootPitchClass, thirdPitchClass;

      nextRootPitchClass = (
        root + rootDelta
      ) % 12;

      nextRoot = nearest[\inRange].value(
        nextRootPitchClass,
        root,
        low,
        high
      );

      thirdPitchClass = (
        root
        + chordQuality[\thirdOffset].value(quality)
      ) % 12;

      // Choose the octave of the current chord's 3rd
      // that leads most smoothly toward the next root.
      chordThird = nearest[\inRange].value(
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
