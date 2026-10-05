(
{
  var figures;

  // Offsets from the tonic root.
  // Currently one Lydian figure per developmental role.

  figures = (
      arrival: [4, 7, 12, 11],
      explore: [12, 14, 16, 18, 19],
      exploreB: [7, 9, 11, 14, 18],
      exploreLink: [19, 18, 16, 14, 16],
      depart: [21, 19, 18, 11],
      departB: [18, 16, 14, 11]
  );

  (
    make: { |root, role|
      var offsets;

      offsets = figures[role];

      if(offsets.isNil) {
        Error(
          "Unknown tonic figure role: " ++ role
        ).throw;
      };

      offsets.collect { |offset|
        root + offset
      }
    }
  )
}.value
)
