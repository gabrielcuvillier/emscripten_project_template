// Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
// Licensed under CC0 1.0 Universal

if (Module['preRun'] instanceof Array) {
  Module['preRun'].push(environment_variables);
} else {
  Module['preRun'] = [environment_variables];
}

function environment_variables() {
  // Setup environment variables
  // ENV.<...> = <...>
}
