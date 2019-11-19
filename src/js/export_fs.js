// Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
// Licensed under CC0 1.0 Universal

if (Module['preRun'] instanceof Array) {
  Module['preRun'].push(export_idbfs);
} else {
  Module['preRun'] = [export_idbfs];
}

function export_idbfs() {
  Module['IDBFS'] = IDBFS;
  Module['MEMFS'] = MEMFS;
  Module['WORKERFS'] = WORKERFS;
}
