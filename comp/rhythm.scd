(
{
  var hit, rest;

  rest = { |dur|
    (type: \rest, dur: dur)
  };

  hit = { |notes, dur, amp, decay|
    (
      midinote: notes,
      dur: dur,
      amp: amp * 1.5,
      decay: decay
    )
  };

  (
    single: { |notes|
      [
        rest.value(1),
        hit.value(notes, 1, 0.065, 0.38)
      ]
    },

    double: { |notes|
      [
        rest.value(1),
        hit.value(notes, 1/3, 0.070, 0.16),
        hit.value(notes, 1/3, 0.055, 0.16),
        rest.value(1/3)
      ]
    },

    charleston: { |notes|
      [
        hit.value(notes, 5/3, 0.055, 0.22),
        hit.value(notes, 1/3, 0.065, 0.16)
      ]
    },

    reverseCell: { |notes|
      [
        rest.value(2/3),
        hit.value(notes, 1/3, 0.055, 0.16),
        hit.value(notes, 1, 0.065, 0.30)
      ]
    },

    silent: { |notes|
      [rest.value(2)]
    },

    choose: {
      [
        \single,
        \double,
        \charleston,
        \reverseCell,
        \silent
      ].wchoose([
        0.30,
        0.20,
        0.20,
        0.15,
        0.15
      ])
    },

  )
}.value
)
