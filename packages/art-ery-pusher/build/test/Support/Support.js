"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {require('../../..').Config.PusherClient = require('./MockPusherClient'); require('../../..').Config.PusherServer = require('./MockPusherServer'); require('art-config').configure({artConfig: {Art: {EryExtensions: {Pusher: {verbose: false, verifyConnection: "silent"}}}}}); return {simpleStore: require('./SimpleStore').simpleStore, pipelines: require('./SimpleStore').simpleStore.pipelines, session: require('./SimpleStore').simpleStore.session, pipelineRegistry: require('./SimpleStore').simpleStore.pipelineRegistry};});
//# sourceMappingURL=Support.js.map
