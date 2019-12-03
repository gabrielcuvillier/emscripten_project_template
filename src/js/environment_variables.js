// Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
// Licensed under CC0 1.0 Universal

if (Module['preRun'] instanceof Array) {
  Module['preRun'].push(setup_environment_variables);
} else {
  Module['preRun'] = [setup_environment_variables];
}

function setup_environment_variables() {
  // Setup your custom environment variables:
  // ENV['...'] = '...';

  ENV['NAME'] = 'web_application';
  ENV['OSTYPE'] = 'emscripten';
  ENV['HOSTTYPE'] = 'wasm';
  ENV['MACHTYPE'] = 'wasm-emscripten';
  ENV['UID'] = '1000';

  // NB - Emscripten defaults are:
  // ENV['USER']='web_user';
  // ENV['LOGNAME']='web_user';
  // ENV['PATH']='/';
  // ENV['PWD']='/';
  // ENV['HOME']='/home/web_user';
  // ENV['LANG']=((typeof navigator === 'object' && navigator.languages && navigator.languages[0]) || 'C').replace('-', '_') + '.UTF-8';
  // ENV['_']=thisProgram;
}
