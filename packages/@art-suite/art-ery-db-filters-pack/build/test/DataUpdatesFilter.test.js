"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "ArtModelSubscriptionsMixin", "BaseObject", "chainedTest", "assert", "beforeEach", "test", "Object", "Promise", "artModelStore", "randomString", "isArray"], [global, require('./StandardImport')], (describe, ArtModelSubscriptionsMixin, BaseObject, chainedTest, assert, beforeEach, test, Object, Promise, artModelStore, randomString, isArray) => {let preexistingKey, preexistingName, stateField, newUserName, createNewUserName, cleanupInstance, models, dataUpdatesFilterPipeline, registry, pipelines, MyComponent, MyQueryComponent, testSetup; require('art-config').configure(); preexistingKey = "abc123"; preexistingName = "initialAlice"; stateField = "user"; newUserName = "bill"; createNewUserName = "craig"; cleanupInstance = null; models = dataUpdatesFilterPipeline = registry = pipelines = null; MyComponent = null; MyQueryComponent = null; testSetup = function(initialRecords) {let DataUpdatesFilterPipeline; MyComponent = Caf.defClass(class MyComponent extends ArtModelSubscriptionsMixin(BaseObject) {constructor(key = preexistingKey) {super(...arguments); this.subscribe("mySubscriptionKey", "dataUpdatesFilterPipeline", key, {stateField});};}); MyQueryComponent = Caf.defClass(class MyQueryComponent extends ArtModelSubscriptionsMixin(BaseObject) {constructor(key = preexistingKey) {super(...arguments); this.subscribe("mySubscriptionKey", "usersByEmail", key, {stateField});};}); DataUpdatesFilterPipeline = require('./DataUpdatesFilterPipeline')(); pipelines = DataUpdatesFilterPipeline.pipelines; dataUpdatesFilterPipeline = DataUpdatesFilterPipeline.dataUpdatesFilterPipeline; registry = DataUpdatesFilterPipeline.getRegistry(); dataUpdatesFilterPipeline.reset({data: initialRecords || {[preexistingKey]: {name: preexistingName}}}); return models = require('@art-suite/art-pipeline-models').defineModelsForAllPipelines(registry);}; return describe({simpleRequests: function() {return chainedTest(() => testSetup()).thenTest("create", () => pipelines.dataUpdatesFilterPipeline.create({returnResponseObject: true, data: {foo: 123}}).then((response) => {assert.eq(response.responseProps, {data: {id: response.key, foo: 123, createdAt: 123, updatedAt: 123}}); return response.data;})).thenTest("update", (record) => pipelines.dataUpdatesFilterPipeline.update({returnResponseObject: true, key: record.id, data: {foo: 123, bar: 456}}).then((response) => assert.eq(response.responseProps, {data: {id: response.key, foo: 123, bar: 456, createdAt: 123, updatedAt: 321}})));}, subrequests: function() {beforeEach(() => testSetup()); test("sub-create sets dataUpdates", () => pipelines.dataUpdatesFilterPipeline.subrequestTest({returnResponseObject: true, data: {type: "create", data: {name: newUserName}}}).then(({props}) => {let id; ([id] = Object.keys(props.dataUpdates.dataUpdatesFilterPipeline)); return assert.eq({dataUpdates: {dataUpdatesFilterPipeline: {[`${Caf.toString(id)}`]: {name: newUserName, createdAt: 123, updatedAt: 123, id}}}, data: {name: newUserName, createdAt: 123, updatedAt: 123, id}}, props);})); test("sub-update sets dataUpdates", () => pipelines.dataUpdatesFilterPipeline.subrequestTest({returnResponseObject: true, data: {type: "update", key: preexistingKey, data: {name: newUserName}}}).then(({props}) => {let id; id = preexistingKey; return assert.eq({dataUpdates: {dataUpdatesFilterPipeline: {[`${Caf.toString(id)}`]: {name: newUserName, updatedAt: 321}}}, data: {name: newUserName, updatedAt: 321}}, props);})); test("sub-delete sets dataDeletes", () => pipelines.dataUpdatesFilterPipeline.subrequestTest({returnResponseObject: true, data: {type: "delete", key: preexistingKey}}).then(({props}) => {let id; id = preexistingKey; return assert.eq({dataDeletes: {dataUpdatesFilterPipeline: {[`${Caf.toString(id)}`]: {name: preexistingName}}}, data: {name: preexistingName}}, props);})); return test("sub-get does not get logged", () => pipelines.dataUpdatesFilterPipeline.subrequestTest({returnResponseObject: true, data: {type: "get", key: preexistingKey}}).then(({props}) => {let id; id = preexistingKey; return assert.eq({data: {name: preexistingName}}, props);}));}, ArtModelUpdates: {basicRequests: function() {return chainedTest(testSetup).thenTest("update", () => new Promise((resolve) => {let MyComponentForUpdateTesting; new (MyComponentForUpdateTesting = Caf.defClass(class MyComponentForUpdateTesting extends MyComponent {}, function(MyComponentForUpdateTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? ((Caf.exists(data) && data.name) === newUserName) ? resolve() : undefined : undefined;};})); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.update({key: preexistingKey, data: {name: newUserName}}));})).thenTest("delete", () => new Promise((resolve) => {let MyComponentForDeleteTesting; new (MyComponentForDeleteTesting = Caf.defClass(class MyComponentForDeleteTesting extends MyComponent {}, function(MyComponentForDeleteTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? (((Caf.exists(data) && data.name) != null) ? this._receivedRealData = true : undefined, (!(data != null) && this._receivedRealData) ? resolve() : undefined) : undefined;};})); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.delete({key: preexistingKey}));})).thenTest("create", () => {let newKey; newKey = randomString(8); return new Promise((resolve) => {let MyComponentForCreateTesting; MyComponentForCreateTesting = Caf.defClass(class MyComponentForCreateTesting extends MyComponent {}, function(MyComponentForCreateTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? ((Caf.exists(data) && data.name) === createNewUserName) ? resolve() : undefined : undefined;};}); new MyComponentForCreateTesting(newKey); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.create({key: newKey, data: {name: createNewUserName}}));});});}, subrequests: function() {return chainedTest(testSetup).thenTest("update", () => new Promise((resolve) => {let MyComponentForUpdateTesting; cleanupInstance = new (MyComponentForUpdateTesting = Caf.defClass(class MyComponentForUpdateTesting extends MyComponent {}, function(MyComponentForUpdateTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? ((Caf.exists(data) && data.name) === newUserName) ? resolve() : undefined : undefined;};})); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.subrequestTest({data: {type: "update", key: preexistingKey, data: {name: newUserName}}}));})).thenTest("delete", () => new Promise((resolve) => {let MyComponentForDeleteTesting; cleanupInstance = new (MyComponentForDeleteTesting = Caf.defClass(class MyComponentForDeleteTesting extends MyComponent {}, function(MyComponentForDeleteTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? (((Caf.exists(data) && data.name) != null) ? this._receivedRealData = true : undefined, (!(data != null) && this._receivedRealData) ? resolve() : undefined) : undefined;};})); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.subrequestTest({data: {type: "delete", key: preexistingKey}}));})).thenTest("create", () => {let newKey; newKey = randomString(8); createNewUserName = "craig"; return new Promise((resolve) => {let MyComponentForCreateTesting; MyComponentForCreateTesting = Caf.defClass(class MyComponentForCreateTesting extends MyComponent {}, function(MyComponentForCreateTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? ((Caf.exists(data) && data.name) === createNewUserName) ? resolve() : undefined : undefined;};}); cleanupInstance = new MyComponentForCreateTesting(newKey); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.subrequestTest({data: {type: "create", key: newKey, data: {name: createNewUserName}}}));});});}, queryUpdates: function() {return chainedTest(testSetup).thenTest("create", () => {let newUserEmail; newUserEmail = "bill@imikimi.com"; return new Promise((resolve) => {let MyComponentForQueryCreateTesting; MyComponentForQueryCreateTesting = Caf.defClass(class MyComponentForQueryCreateTesting extends MyQueryComponent {}, function(MyComponentForQueryCreateTesting, classSuper, instanceSuper) {this.prototype.setState = function(_stateField, data) {return (_stateField === stateField) ? ((isArray(data) && data.length === 0) ? this._wasInitiallyEmpty = true : undefined, (this._wasInitiallyEmpty && (Caf.exists(data) && data.length) === 1) ? resolve() : undefined) : undefined;};}); cleanupInstance = new MyComponentForQueryCreateTesting(newUserEmail); return artModelStore.onNextReady(() => pipelines.dataUpdatesFilterPipeline.create({data: {name: newUserName, email: newUserEmail}}));});});}}});});});
//# sourceMappingURL=DataUpdatesFilter.test.js.map