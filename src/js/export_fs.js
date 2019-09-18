// Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
// Licensed under CC0 1.0 Universal

if (Module['postRun'] instanceof Array) {
  Module['postRun'].push(export_fs);
} else {
  Module['postRun'] = [export_fs];
}

function export_fs() {
  Module.FS_mkdir       = function(a) { return Module.FS.mkdir(a) };
  Module.FS_readFile    = function(a) { return Module.FS.readFile(a); };
  Module.FS_writeFile   = function(a,b,c) { return Module.FS.writeFile(a,b,c) };
  Module.FS_unlink      = function(a) { return Module.FS.unlink(a) };
  Module.FS_mount       = function(a,b) { return Module.FS.mount(a,b) };
}
