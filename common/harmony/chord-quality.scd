(
{
  (
    thirdOffset: { |quality|
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
    }
  )
}.value
)
