"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["getEnv", "test", "SimplePipeline", "assert", "wordsArray", "missing"], [global, require('../StandardImport'), {SimplePipeline: require('./SimplePipeline')}], (getEnv, test, SimplePipeline, assert, wordsArray, missing) => {require('art-config').configure(); getEnv().ART_PIPELINES_ATTACH_RESPONSE_TO_ERRORS = true; test("clientApiMethodList", function() {let simplePipeline; simplePipeline = new SimplePipeline; return assert.eq(simplePipeline.clientApiMethodList, wordsArray("reset get getAll create update delete"));}); test("get -> missing", function() {let simplePipeline; simplePipeline = new SimplePipeline; return assert.rejects(simplePipeline.get("doesn't exist")).then(({info: {response}}) => assert.eq(response.status, missing));}); test("update -> missing", function() {let simplePipeline; simplePipeline = new SimplePipeline; return assert.rejects(simplePipeline.update("doesn't exist")).then(({info: {response}}) => assert.eq(response.status, missing));}); test("delete -> missing", function() {let simplePipeline; simplePipeline = new SimplePipeline; return assert.rejects(simplePipeline.delete("doesn't exist")).then(({info: {response}}) => assert.eq(response.status, missing));}); test("create returns new record", function() {let simplePipeline; simplePipeline = new SimplePipeline; return simplePipeline.create({data: {foo: "bar"}}).then((data) => assert.eq(data, {foo: "bar", id: "0"}));}); test("create -> get string", function() {let simplePipeline; simplePipeline = new SimplePipeline; return simplePipeline.create({data: {foo: "bar"}}).then(({id}) => simplePipeline.get({key: id})).then((data) => assert.eq(data, {foo: "bar", id: "0"}));}); test("create -> get key: string", function() {let simplePipeline; simplePipeline = new SimplePipeline; return simplePipeline.create({data: {foo: "bar"}}).then(({id}) => simplePipeline.get({key: id})).then((data) => assert.eq(data, {foo: "bar", id: "0"}));}); test("create -> update", function() {let simplePipeline; simplePipeline = new SimplePipeline; return simplePipeline.create({data: {foo: "bar"}}).then(({id}) => simplePipeline.update({key: id, data: {fooz: "baz"}})).then((data) => assert.eq(data, {foo: "bar", fooz: "baz", id: "0"}));}); return test("create -> delete", function() {let simplePipeline; simplePipeline = new SimplePipeline; return assert.rejects(simplePipeline.create({data: {foo: "bar"}}).then(({id}) => simplePipeline.delete({key: id})).then(({id}) => simplePipeline.get({key: id}))).then(({info: {response}}) => assert.eq(response.status, missing));});});});
//# sourceMappingURL=SimplePipeline.test.js.map