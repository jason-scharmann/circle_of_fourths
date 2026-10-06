(
{
  (
    voice: { |notes, previous = nil, low = 55, high = 70|
      var pcs, candidates, center, index;

      if(notes.size != 4) {
        Error(
          "Close-position voicing expects four notes."
        ).throw;
      };

      pcs = notes.collect { |n|
        n % 12
      }.as(Set).asArray.sort;

      if(pcs.size != 4) {
        Error(
          "Four distinct pitch classes required."
        ).throw;
      };

      if(previous.notNil and: { previous.size != 4 }) {
        Error(
          "Previous voicing must have four notes."
        ).throw;
      };

      // Generate close-position inversions in the requested range.
      candidates = (low..high)
        .select { |bottom|
          pcs.includes(bottom % 12)
        }
        .collect { |bottom|
          pcs.collect { |pc|
            bottom + (
              (pc - (bottom % 12) + 12) % 12
            )
          }.sort
        }
        .select { |voicing|
          voicing.last <= high
        };

      if(candidates.isEmpty) {
        Error(
          "No close-position voicing fits the range."
        ).throw;
      };

      center = (low + high) / 2;

      // Prefer the middle initially.
      // Subsequently minimize total voice movement.
      index = candidates.minIndex { |voicing|
        var centerCost;

        centerCost = voicing.collect { |n|
          (n - center).abs
        }.sum;

        if(previous.isNil) {
          centerCost
        } {
          voicing.collect { |n, i|
            (n - previous[i]).abs
          }.sum + (centerCost * 0.05)
        }
      };

      candidates[index]
    }
  )
}.value
)
