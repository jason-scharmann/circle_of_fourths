(
{
  var requireFour, asEvents, flatFiveOf;

  requireFour = { |notes|
    if(notes.size != 4) {
      Error("Realization expects a four-note figure.").throw;
    };
  };

  asEvents = { |notes, durs|
    notes.collect { |note, i|
      (
        midinote: note,
        dur: durs[i]
      )
    }
  };

  flatFiveOf = { |notes|
    var pitchClass, note;

    requireFour.value(notes);

    // The figure begins on the minor third.
    // The diminished fifth is three semitones above it
    // in pitch-class space.
    pitchClass = (notes[0] + 3) % 12;

    note = notes.detect { |pitch|
      (pitch % 12) == pitchClass
    };

    if(note.isNil) {
      Error(
        "Half-diminished figure lacks its flat fifth."
      ).throw;
    };

    note
  };

  (
    swing: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [2/3, 1/3, 2/3, 1/3]
      )
    },

    tripletTail: { |notes|
      var approach;

      requireFour.value(notes);

      // Approach the final seventh chromatically,
      // following the direction of the preceding pitch.
      approach = if(notes[2] > notes[3]) {
        notes[3] + 1
      } {
        notes[3] - 1
      };

      // Avoid duplicating the preceding pitch when
      // the original movement is already a semitone.
      if(approach == notes[2]) {
        approach = if(notes[2] > notes[3]) {
          notes[3] - 1
        } {
          notes[3] + 1
        };
      };

      asEvents.value(
        [
          notes[0],
          notes[1],
          notes[2],
          approach,
          notes[3]
        ],
        [2/3, 1/3, 1/3, 1/3, 1/3]
      )
    },

    omitSecondHold: { |notes|
      requireFour.value(notes);

      [
        (
          midinote: notes[0],
          dur: 1,
          sustain: 1
        ),
        (
          midinote: notes[2],
          dur: 2/3
        ),
        (
          midinote: notes[3],
          dur: 1/3
        )
      ]
    },
    omitSecondRest: { |notes|
      requireFour.value(notes);

      [
        (
          midinote: notes[0],
          dur: 2/3
        ),
        (
          midinote: Rest(),
          dur: 1/3
        ),
        (
          midinote: notes[2],
          dur: 2/3
        ),
        (
          midinote: notes[3],
          dur: 1/3
        )
      ]
    },

    middleDelay: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [2/3, 2/3, 1/3, 1/3]
      )
    },

    middlePush: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [1/3, 2/3, 2/3, 1/3]
      )
    },

    tripletLaunch: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [1/3, 1/3, 1/3, 1]
      )
    },

    tripletAnswer: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [1, 1/3, 1/3, 1/3]
      )
    },

    tripletDisplace: { |notes|
      requireFour.value(notes);

      asEvents.value(
        notes,
        [1/3, 2/3, 1/3, 2/3]
      )
    },

    restTriplets: { |notes|
      requireFour.value(notes);

      asEvents.value(
        [
          notes[0],
          Rest(),
          notes[1],
          notes[2],
          notes[3]
        ],
        [2/3, 1/3, 1/3, 1/3, 1/3]
      )
    },

    shortRest: { |notes|
      requireFour.value(notes);

      asEvents.value(
        [
          notes[0],
          Rest(),
          notes[1],
          notes[2],
          notes[3]
        ],
        [1/3, 1/3, 1/3, 2/3, 1/3]
      )
    },

    thirdPulse: { |notes|
      requireFour.value(notes);

      [
        // A longer third, followed by two short pulses.
        (
          midinote: notes[0],
          dur: 1,
          sustain: 0.72
        ),
        (
          midinote: notes[0],
          dur: 1/3,
          sustain: 0.10
        ),
        (
          midinote: Rest(),
          dur: 1/3
        ),
        (
          midinote: notes[0],
          dur: 1/3,
          sustain: 0.11
        )
      ]
    },

    guideSpace: { |notes|
      requireFour.value(notes);

      [
        (
          midinote: notes[0],
          dur: 2/3,
          sustain: 0.32
        ),
        (
          midinote: Rest(),
          dur: 2/3
        ),
        (
          midinote: notes[3],
          dur: 2/3,
          sustain: 0.35
        )
      ]
    },

    guidePickup: { |notes|
      requireFour.value(notes);

      [
        (
          midinote: notes[0],
          dur: 1,
          sustain: 0.68
        ),
        (
          midinote: Rest(),
          dur: 2/3
        ),
        (
          midinote: notes[3],
          dur: 1/3,
          sustain: 0.13
        )
      ]
    },

    guideEcho: { |notes|
      requireFour.value(notes);

      [
        (midinote: notes[0], dur: 2/3, sustain: 0.30),
        (type: \rest, dur: 1/3),
        (midinote: notes[3], dur: 1/3, sustain: 0.12),
        (type: \rest, dur: 1/3),
        (midinote: notes[3], dur: 1/3, sustain: 0.12)
      ]
    },

    halfDimAir: { |notes|
      var flatFive;

      flatFive = flatFiveOf.value(notes);

      [
        (midinote: notes[0], dur: 2/3, sustain: 0.28),
        (type: \rest, dur: 1/3),
        (midinote: flatFive, dur: 1/3, sustain: 0.13),
        (type: \rest, dur: 1/3),
        (midinote: notes[3], dur: 1/3, sustain: 0.14)
      ]
    },

    halfDimPulse: { |notes|
      var flatFive;

      flatFive = flatFiveOf.value(notes);

      [
        (midinote: notes[0], dur: 1/3, sustain: 0.13),
        (type: \rest, dur: 1/3),
        (midinote: flatFive, dur: 1/3, sustain: 0.12),
        (midinote: flatFive, dur: 1/3, sustain: 0.10),
        (midinote: notes[3], dur: 2/3, sustain: 0.30)
      ]
    },

    halfDimHinge: { |notes|
      var flatFive;

      flatFive = flatFiveOf.value(notes);

      [
        (midinote: notes[0], dur: 1, sustain: 0.60),
        (midinote: flatFive, dur: 1/3, sustain: 0.12),
        (midinote: notes[3], dur: 2/3, sustain: 0.28)
      ]
    }

  )
}.value
)
