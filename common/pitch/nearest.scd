(
{
  (
    inRange: { |pitchClass, target, low, high|
      var candidates, index;

      candidates = (low..high).select { |note|
        (note % 12) == pitchClass
      };

      if(candidates.isEmpty) {
        Error(
          "No matching pitch fits the requested range."
        ).throw;
      };

      index = candidates.minIndex { |note|
        (note - target).abs
      };

      candidates[index]
    }
  )
}.value
)
