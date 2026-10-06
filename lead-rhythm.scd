(
{
  (
    base: { |quality|
      if(quality == \min7b5) {
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
      }
    },

    sparseOverride: {
      |quality, compKind, firstNote, nextThird|

      var realization = nil;

      // This is the only sparse probability decision (14%).
      if(0.14.coin) {
        if(quality == \min7b5) {

          // Retain the defining b3, b5, and b7
          // even when comping rests.
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
              (nextThird - firstNote).abs <= 4
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
            // Always articulate both guide tones
            // if piano is silent.
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

      realization
    }
  )
}.value
)
