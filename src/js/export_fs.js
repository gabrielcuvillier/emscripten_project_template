// Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
// Licensed under CC0 1.0 Universal

if (Module['preRun'] instanceof Array) {
  Module['preRun'].push(export_fs);
} else {
  Module['preRun'] = [export_fs];
}

function export_fs() {
  // Setup your custom FS types exports:
  // Module['...'] = ...;

  Module['MEMFS'] = MEMFS;

  // Other FS types to expose to JS:
  // Module['IDBFS'] = IDBFS;
  // Module['WORKERFS'] = WORKERFS;
  // ...
}
