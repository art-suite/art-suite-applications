"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "chainedTest", "Pipeline", "assert", "normalizeFieldProps", "test", "merge"], [global, require('../StandardImport'), require('art-validation')], (describe, chainedTest, Pipeline, assert, normalizeFieldProps, test, merge) => {return describe({basics: function() {return chainedTest("simple", () => {let requestTypes, myPipeline, MyPipeline; requestTypes = null; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.requestTypes(requestTypes = {getTime: {response: {data: {time: "number"}}}});})); assert.eq(myPipeline.requestTypes, requestTypes); return myPipeline;}).thenTest("simple normalizedRequestTypes", (myPipeline) => assert.eqAfterStringifyingFunctions(myPipeline.normalizedRequestTypes, {getTime: {response: {data: normalizeFieldProps({fields: {time: "number"}})}}}));}, autodefined: function() {test("handlers define request types", () => {let myPipeline, MyPipeline; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.handler({rock: function() {return "roll";}});})); return assert.eq(myPipeline.requestTypes, {rock: {}});}); return test("beforeFilters define request types and afterFilters do not", () => {let myPipeline, MyPipeline; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.filter({name: "myFilter", before: {rock: function() {return "roll";}}}); this.filter({name: "myOtherFilter", after: {roll: function() {return "rap";}}});})); return assert.eq(myPipeline.requestTypes, {rock: {}});});}, normalized: function() {test("singleton data", () => {let myPipeline, MyPipeline; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.requestTypes({getTime: {response: {data: "number"}}});})); return assert.eqAfterStringifyingFunctions(myPipeline.normalizedRequestTypes, {getTime: {response: {data: normalizeFieldProps("number")}}});}); return test(":record data", () => {let requestTypes, myPipeline, MyPipeline; requestTypes = null; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.fields({name: "string"}); this.requestTypes(requestTypes = {getTime: {response: {data: "record"}}});})); assert.eq(myPipeline.requestTypes, requestTypes); return assert.eqAfterStringifyingFunctions(myPipeline.normalizedRequestTypes, {getTime: {response: {data: merge(normalizeFieldProps({fields: myPipeline.fields}), {fieldType: "record"})}}});});}});});});
//# sourceMappingURL=PipelineRequestTypes.test.js.map