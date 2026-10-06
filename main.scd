(
{
  var performance, clock;

  performance = thisProcess.interpreter.executeFile(
    "performance.scd".resolveRelative
  );

  Server.default.waitForBoot({
    performance[\install].value;

    Server.default.sync;

    clock = TempoClock.new(
      performance[\tempo]
    );

    performance[\pattern].play(clock);
  });

}.value
)
