"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "assert", "process", "log", "Pipeline", "pipelines", "Error"], [global, require('../StandardImport'), require('../PipelineWithRegistry')], (test, assert, process, log, Pipeline, pipelines, Error) => {let indent, testNiceStackTrace; indent = function(str, indentString = "  ", wordWrapIndent = "  ") {return Caf.array(str.split("\n"), (line) => {let __, spaces, lineIndent, base, base1; ([__, spaces, line] = line.match(/^(\s*)(.*)/)); lineIndent = indentString + spaces; return lineIndent + require('ansi-wordwrap')(line, {width: (Caf.exists(base = global.process) && (Caf.exists(base1 = base.stdout) && base1.columns) || 80) - lineIndent.length - wordWrapIndent.length - 1}).replace("\n", "\n" + lineIndent + wordWrapIndent);}).join("\n");}; testNiceStackTrace = function(name, tester) {return test(`${Caf.toString(name)} - set VERBOSE_TESTING=true to log error details`, () => assert.rejects(tester).then((error) => (process.env.VERBOSE_TESTING === true || process.env.VERBOSE_TESTING === "true") ? (log("\n------------------------------\nNiceStackTrace"), log(indent(error.message.red)), log(""), log(indent(error.stack.grey))) : undefined));}; testNiceStackTrace("bad request arguments", function() {let MyPipeline; return (MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.handlers({get: function() {return 1;}});})).singleton.get({originatedOnServer: "invalidValue"});}); testNiceStackTrace("ValidationFilter missing field", function() {let MyRtUser3, MyRt3; MyRtUser3 = Caf.defClass(class MyRtUser3 extends Pipeline {}); return (MyRt3 = Caf.defClass(class MyRt3 extends Pipeline {}, function(MyRt3, classSuper, instanceSuper) {this.publicRequestTypes("create"); this.addDatabaseFiltersV2({linkFilterVersion: 2, fields: {myRtUser2: ["required", "link"], text: "string"}});})).singleton.create({data: {text: "hi"}});}); testNiceStackTrace("ValidationFilter create with unexpected field", function() {let MyPipeline; MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.publicRequestTypes("create"); this.addDatabaseFiltersV2({linkFilterVersion: 2, fields: {text: "string"}});}); return pipelines.myPipeline.create({data: {text: "hi", name: "John"}});}); testNiceStackTrace("originatedOnServer required to issue non-public requests", function() {let MyRtUser3, myRt3, MyRt3; MyRtUser3 = Caf.defClass(class MyRtUser3 extends Pipeline {}); ({myRt3} = MyRt3 = Caf.defClass(class MyRt3 extends Pipeline {}, function(MyRt3, classSuper, instanceSuper) {this.handlers({get: function() {return 123;}});})); return myRt3.get();}); testNiceStackTrace("requirements-not-met-nice-trace", function() {let myRt4, MyRt4; ({myRt4} = MyRt4 = Caf.defClass(class MyRt4 extends Pipeline {}, function(MyRt4, classSuper, instanceSuper) {this.publicHandlers({requireSomething: function(request) {return request.require(1 === 2, "1 must be 2 - what? that doesn't work in your universe?");}});})); return myRt4.requireSomething();}); return testNiceStackTrace("with filters", function() {let myRt4, MyRt4; ({myRt4} = MyRt4 = Caf.defClass(class MyRt4 extends Pipeline {}, function(MyRt4, classSuper, instanceSuper) {this.filter({name: "filterMan", before: {failBig: function(request) {return request.withMergedData({filteredBy: "filterMan"});}}}); this.publicHandlers({failBig: function(request) {return (() => {throw new Error("failed BIG in handler");})();}, outterRequest: function(request) {return request.pipeline.failBig(request);}});})); return myRt4.outterRequest();});});});
//# sourceMappingURL=NiceStackTraces.test.js.map