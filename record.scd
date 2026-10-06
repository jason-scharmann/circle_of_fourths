(
{
  var performance, clock, player;

  var tempo, beatsPerBar, beatDur;
  var fadeIn, fullTime, fadeOut, totalTime;

  var recordBars = 48;
  var fadeBars = 2;
  var fullBars = recordBars - (fadeBars * 2);

  var projectDir = "record.scd".resolveRelative.dirname;
  var recordingsDir = projectDir +/+ "recordings";
  var recordPath;

  if(File.exists(recordingsDir).not) {
    File.mkdir(recordingsDir);
  };

  recordPath = recordingsDir +/+ (
    "circle_of_fourths_"
    ++ Date.getDate.stamp
    ++ ".wav"
  );

  performance = thisProcess.interpreter.executeFile(
    "performance.scd".resolveRelative
  );

  tempo = performance[\tempo];
  beatsPerBar = performance[\beatsPerBar];
  beatDur = tempo.reciprocal;

  fadeIn = fadeBars * beatsPerBar * beatDur;
  fullTime = fullBars * beatsPerBar * beatDur;
  fadeOut = fadeBars * beatsPerBar * beatDur;
  totalTime = recordBars * beatsPerBar * beatDur;

  Server.default.waitForBoot({
    var server = Server.default;

    performance[\install].value;

    // Master fade written into the recording itself.
    SynthDef(\circleSnapshotFade, {
      |out = 0, fadeIn = 3, fullTime = 120, fadeOut = 3|

      var signal, gain;

      signal = In.ar(out, 2);

      gain = EnvGen.ar(
        Env.linen(
          fadeIn,
          fullTime,
          fadeOut,
          1,
          \sin
        )
      );

      ReplaceOut.ar(
        out,
        signal * gain
      );
    }).add;

    server.recHeaderFormat = "wav";
    server.recSampleFormat = "int24";

    server.prepareForRecord(
      recordPath,
      2
    );

    server.sync;

    clock = TempoClock.new(tempo);

    server.bind {
      Synth.tail(
        server.defaultGroup,
        \circleSnapshotFade,
        [
          \out, 0,
          \fadeIn, fadeIn,
          \fullTime, fullTime,
          \fadeOut, fadeOut
        ]
      );

      server.record(
        bus: 0,
        numChannels: 2,
        duration: totalTime
      );
    };

    player = performance[\pattern].play(clock);

    ("Recording: " ++ recordPath).postln;

    SystemClock.sched(
      totalTime + server.latency + 0.5,
      {
        // Stop generating any new musical events.
        player.stop;

        // Leave the TempoClock alive briefly so already-scheduled
        // gate releases can finish. The master fade is already at zero,
        // so this cleanup period is silent.
        SystemClock.sched(
          (2 * beatDur) + server.latency,
          {
            // Safety cleanup for any remaining synths.
            server.defaultGroup.freeAll;

            clock.stop;

            (
              "Recording finished: "
              ++ recordPath
            ).postln;

            nil
          }
        );

        nil
      }
    );

  });

}.value
)
