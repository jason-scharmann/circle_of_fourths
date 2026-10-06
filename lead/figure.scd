(
{
  var shapes, shapesFor;

  // Semitone offsets relative to the chordal third.
  shapes = (
    dom7: (
      up: [
        [0, 3, 8, 6],   // 5
        [0, 2, 8, 6],   // #11
        [0, 4, 8, 6],   // b13
        [0, 5, 8, 6]    // 13
      ],

      down: [
        [0, -2, -4, -6], // 9
        [0, -3, -4, -6], // b9
        [0, -1, -4, -6]  // #9
      ]
    ),

    min7: (
      up: [
        [0, 4, 9, 7],
        [0, 2, 9, 7],
        [0, 6, 9, 7],

        [0, -3, 2, 7],
        [0, -3, 4, 7]
      ],

      down: [
        [0, -1, -3, -5],
        [0, 2, -3, -5],
        [0, 4, -3, -5],
        [0, -6, -3, -5]
      ]
    ),
    maj7: (
      up: [
        [0, 3, 8, 7],
        [0, 2, 8, 7],
        [0, 5, 8, 7],

        [0, -4, 2, 7],
        [0, -4, 3, 7]
      ],

      down: [
        [0, -2, -4, -5],
        [0, 2, -4, -5],
        [0, 3, -4, -5],
        [0, -7, -4, -5]
      ]
    ),

    min7b5: (
      up: [
        [0, 3, 9, 7],     // b3 - b5 - 1 - b7
        [0, -3, 3, 7]     // b3 - 1 - b5 - b7
      ],

      down: [
        [0, -3, -9, -5],  // b3 - 1 - b5 - b7
        [0, 3, -3, -5]    // b3 - b5 - 1 - b7
      ]
    ),

    minMaj7: (
      up: [
        [0, 4, 9, 8],     // b3 - 5  - 1 - 7
        [0, 2, 9, 8],     // b3 - 11 - 1 - 7
        [0, 6, 9, 8],     // b3 - 13 - 1 - 7
        [0, -3, 4, 8]     // b3 - 1  - 5 - 7
      ],

      down: [
        [0, -3, -8, -4],  // b3 - 1  - 5  - 7
        [0, -1, -3, -4],  // b3 - 9  - 1  - 7
        [0, -3, -6, -4]   // b3 - 1  - 13 - 7
      ]
    ),

  );

  shapesFor = { |quality, direction|
    var qualityShapes, directionShapes;

    qualityShapes = shapes[quality];

    if(qualityShapes.isNil) {
      Error(
        "Unknown chord quality: " ++ quality
      ).throw;
    };

    directionShapes = qualityShapes[direction];

    if(directionShapes.isNil) {
      Error(
        "Unknown figure direction: " ++ direction
      ).throw;
    };

    directionShapes
  };

  (
    make: { |third, direction, quality = \dom7|
      shapesFor.value(quality, direction)[0].collect { |n|
        third + n
      }
    },

    variants: { |third, direction, quality = \dom7|
      shapesFor.value(quality, direction).collect { |shape|
        shape.collect { |n|
          third + n
        }
      }
    }
  )
}.value
)
