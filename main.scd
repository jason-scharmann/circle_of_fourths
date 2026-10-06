(
{
  var performance, clock;

  performance = thisProcess.interpreter.executeFile(
    "performance.scd".resolveRelative
  );

  Server.default.waitForBoot({
    performance[\install].value;

    Server.default.sync;

    clock = TempoClock.new(96 / 60);

    performance[\pattern].play(clock);
  });

}.value
)
