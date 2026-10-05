(
{
  var tonic, lead, bass, comp, comping, compRhythm;
  var drums, ride;
  var version, versions, specs, makeCell;
  var leadEvents, bassEvents, compEvents;
  var bassExplorations, cVoicing, fVoicing, fChord;
  var totalBeats, clock;

  // Change this to \short, \medium, or \long.
  version = \long;

  tonic = thisProcess.interpreter.executeFile(
    "tonic-figures.scd".resolveRelative
  );

  lead = thisProcess.interpreter.executeFile(
    "lead.scd".resolveRelative
  );

  bass = thisProcess.interpreter.executeFile(
    "bass.scd".resolveRelative
  );

  comp = thisProcess.interpreter.executeFile(
    "comp.scd".resolveRelative
  );

  comping = thisProcess.interpreter.executeFile(
    "comping.scd".resolveRelative
  );

  compRhythm = thisProcess.interpreter.executeFile(
    "comp-rhythm.scd".resolveRelative
  );

  drums = thisProcess.interpreter.executeFile(
    "drums.scd".resolveRelative
  );

  ride = thisProcess.interpreter.executeFile(
    "ride.scd".resolveRelative
  );

  versions = (
    short: [
      (role: \arrival, rhythm: \swing),
      (role: \explore, rhythm: \tripletStart),
      (role: \depart, rhythm: \omitSecondHold)
    ],

    medium: [
      (role: \arrival, rhythm: \swing),
      (role: \exploreB, rhythm: \tripletStart),
      (role: \exploreLink, rhythm: \tripletTail),
      (role: \departB, rhythm: \swing)
    ],

    long: [
      (role: \arrival, rhythm: \swing),
      (role: \exploreB, rhythm: \tripletStart),
      (role: \exploreLink, rhythm: \tripletTail),
      (role: \explore, rhythm: \omitSecondHold),
      (role: \departB, rhythm: \omitSecondRest)
    ]
  );

  specs = versions[version];

  if(specs.isNil) {
    Error("Unknown tonic development length.").throw;
  };

  // Rhythmically realize either a four-note or
  // five-note melodic figure into exactly two beats.
  makeCell = { |notes, rhythm|
    var durs, events;

    durs = if(notes.size == 4) {
      [2/3, 1/3, 2/3, 1/3]
    } {
      if(notes.size == 5) {
        if(rhythm == \tripletTail) {
          [2/3, 1/3, 1/3, 1/3, 1/3]
        } {
          [1/3, 1/3, 1/3, 1/3, 2/3]
        }
      } {
        Error("Expected four or five pitches.").throw;
      }
    };

    events = [];

    notes.do { |note, i|
      var dur;

      dur = durs[i];

      // Omission by holding the preceding note.
      if((i != 1) or: { rhythm != \omitSecondHold }) {

        if((i == 0) and: {
          rhythm == \omitSecondHold
        }) {
          dur = dur + durs[1];
        };

        // Alternative omission by inserting a rest.
        if((i == 1) and: {
          rhythm == \omitSecondRest
        }) {
          events = events.add((
            type: \rest,
            dur: dur
          ));
        } {
          events = events.add((
            midinote: note,
            dur: dur
          ));
        };
      };
    };

    if((events.sum { |e| e[\dur] } - 2).abs > 0.00001) {
      Error("Invalid two-beat realization.").throw;
    };

    events
  };

  // Lead.
  leadEvents = [];

  specs.do { |cell|
    var notes;

    notes = tonic[\make].value(
      60,
      cell[\role]
    );

    leadEvents = leadEvents ++ makeCell.value(
      notes,
      cell[\rhythm]
    );
  };

  // Two-beat F7 resolution: A4 C5 F5 Eb5.
  fChord = [69, 72, 77, 75];

  leadEvents = leadEvents ++ makeCell.value(
    fChord,
    \swing
  );

  // Bass. Give successive tonic explorations
  // slightly different root/third/fifth movements.
  bassExplorations = [
    [43, 40],
    [40, 43],
    [36, 40]
  ];

  bassEvents = [];

  specs.do { |cell, i|
    var pair;

    pair = if(i == 0) {
      [36, 40] // Arrival: C E
    } {
      if(i == (specs.size - 1)) {
        [36, 43] // Departure: C G
      } {
        bassExplorations.wrapAt(i - 1)
      }
    };

    bassEvents = bassEvents ++ pair.collect { |note|
      (midinote: note, dur: 1)
    };
  };

  bassEvents = bassEvents ++ [
    (midinote: 41, dur: 1),
    (midinote: 45, dur: 1)
  ];

  // Stable Cmaj7 piano voicing throughout development.
  cVoicing = comping[\voice].value(
    tonic[\make].value(60, \arrival)
  );

  fVoicing = comping[\voice].value(
    fChord,
    cVoicing
  );

  compEvents = [];

  specs.do { |cell, i|
    var compStyle;

    compStyle = if(i == 0) {
      \single
    } {
      if(i == (specs.size - 1)) {
        \reverseCell
      } {
        if((i % 2) == 1) {
          \silent
        } {
          \charleston
        }
      }
    };

    compEvents = compEvents
    ++ compRhythm[compStyle].value(cVoicing);
  };

  compEvents = compEvents
  ++ compRhythm[\single].value(fVoicing);

  totalBeats = (specs.size + 1) * 2;

  // Verify synchronization before playback.
  [
    "Version", version,
    "Expected beats", totalBeats,
    "Lead", leadEvents.sum { |e| e[\dur] },
    "Bass", bassEvents.sum { |e| e[\dur] },
    "Comp", compEvents.sum { |e| e[\dur] }
  ].postln;

  [leadEvents, bassEvents, compEvents].do { |events|
    if(
      (events.sum { |e| e[\dur] } - totalBeats).abs
      > 0.00001
    ) {
      Error("Ensemble duration mismatch.").throw;
    };
  };

  Server.default.waitForBoot({
    lead[\install].value;
    bass[\install].value;
    comp[\install].value;
    drums[\install].value;

    Server.default.sync;

    clock = TempoClock.new(90 / 60);

    Ppar([
      Pbindf(
        Pseq(leadEvents, 1),
        \instrument, lead[\name],
        \legato, 0.8,
        \amp, 0.06
      ),

      Pbindf(
        Pseq(bassEvents, 1),
        \instrument, bass[\name],
        \legato, 0.8,
        \amp, 0.16
      ),

      Pbindf(
        Pseq(compEvents, 1),
        \instrument, comp[\name]
      ),

      // Keep the ride running, truncated to match
      // the exact audition duration.
      Pfindur(
        totalBeats,
        Pbindf(
          Pseq(ride[\basic].value, inf),
          \instrument, drums[\rideName],
          \amp, Pkey(\amp) * 0.55
        )
      )
    ]).play(clock);
  });

}.value
)
(
{
    var tonic;

    tonic = thisProcess.interpreter.executeFile(
        "tonic-figures.scd".resolveRelative
    );

    tonic[\make].value(60, \exploreLink).postln;
}.value
)
