"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["StateFieldsMixin", "ArtModel", "merge", "log", "timeout", "isFunction", "isPlainObject", "isString", "propsEq", "success", "missing", "getEnv", "Promise", "neq"], [global, require('art-standard-lib'), require('@art-suite/art-models'), require('art-communication-status'), require('@art-suite/state-fields-lib')], (StateFieldsMixin, ArtModel, merge, log, timeout, isFunction, isPlainObject, isString, propsEq, success, missing, getEnv, Promise, neq) => {let JsonStore, jsonStore, ApplicationState; ({JsonStore} = require('@art-suite/art-foundation')); ({jsonStore} = JsonStore); return ApplicationState = Caf.defClass(class ApplicationState extends StateFieldsMixin(ArtModel) {constructor() {super(...arguments); this.state = this._getInitialState();};}, function(ApplicationState, classSuper, instanceSuper) {this.abstractClass(); this.persistant = function() {return this._persistant = true;}; this.postCreateConcreteClass = function({hotReloaded, classModuleState}) {let ret, liveClass, hotUpdatedFromClass, liveInstance, newDefaultState, currentState, mergedState, stateDelta; ret = classSuper.postCreateConcreteClass.apply(this, arguments); if (hotReloaded) {({liveClass, hotUpdatedFromClass} = classModuleState); liveInstance = liveClass.getSingleton(); newDefaultState = (new hotUpdatedFromClass).state; currentState = liveInstance.state; mergedState = merge(newDefaultState, currentState); stateDelta = Caf.object(mergedState, null, (v, k) => currentState[k] !== v); log({"Flux.ApplicationState: model hot-reloaded": {model: liveInstance.name, stateDelta}}); timeout(0, this.prototype(liveInstance.setState(stateDelta)));}; return ret;}; this.prototype.modelRegistered = function() {return this._updateAllState(this.state);}; this.prototype.getInitialState = function() {return {};}; this.prototype.setState = function(key, value) {let stateChanged, map; stateChanged = false; return isFunction(key) ? (stateChanged = true, this.replaceState(key(this.state))) : (isPlainObject(map = key) ? Caf.each2(map, (v, k) => {stateChanged = true; this.state[k] = v; return this.load(k);}, (v, k) => !propsEq(this.state[k], v)) : (isString(key) && !propsEq(this.state[key], value)) ? (stateChanged = true, this.state[key] = value, this.load(key)) : undefined, stateChanged ? (this._updateAllState(), this._saveToLocalStorage()) : undefined, key);}; this.getter({propsToKey: function() {let temp; return ((temp = this._propsToKey) != null ? temp : this._propsToKey = (props) => this.modelName);}}); this.prototype.removeState = function(key) {let ret; this._removeFromModelStore(key); ret = this.state[key]; delete this.state[key]; this._saveToLocalStorage(); return ret;}; this.prototype.clearState = function() {Caf.each2(this.state, (v, k) => this._removeFromModelStore(k)); this.state = {}; return this._saveToLocalStorage();}; this.prototype.resetState = function() {return this.replaceState(this._getInitialState(false));}; this.prototype.replaceState = function(newState) {Caf.each2(this.state, (v, k) => !newState.hasOwnProperty(k) ? (this._removeFromModelStore(k), delete this.state[k]) : undefined); return this.setState(newState);}; this.prototype.load = function(key, callback) {let modelRecord; modelRecord = (key === this.name) ? {status: success, data: this.savableState} : this.state.hasOwnProperty(key) ? {status: success, data: this.state[key]} : {status: missing}; this.updateModelRecord(key, modelRecord); callback && this.onNextReady(() => callback(modelRecord)); return modelRecord;}; this.prototype._removeFromModelStore = function(key) {return this.updateModelRecord(key, {status: missing});}; this.prototype.postProcessLoadedState = function(state) {return state;}; this.prototype._loadFromLocalStorage = function() {let loadedState; return (this.class._persistant && !getEnv().resetAppState) ? Promise.then(this.prototype(jsonStore.getItem(this.localStorageKey))).then(loadedState(this.prototype(loadedState = this.postProcessLoadedState(loadedState), (loadedState && neq(loadedState, this.state)) ? (log(`ApplicationState ${Caf.toString(this.class.name)} loaded`), this.replaceState(merge(this.state, loadedState))) : undefined))) : undefined;}; this.prototype._updateAllState = function() {this.load(this.name); return this.state;}; this.getter({savableState: function() {return merge(this.state);}, localStorageKey: function() {return `ApplicationState:${Caf.toString(this.name)}`;}}); this.prototype._saveToLocalStorage = function(state = this.state) {return this.class._persistant ? Promise.then(this.prototype(jsonStore.setItem(this.localStorageKey, this.savableState))) : undefined;}; this.prototype._getInitialState = function(loadFromLocalStorage = true) {if (loadFromLocalStorage) {this._loadFromLocalStorage();}; return merge(this.getInitialState(), this.getStateFields());};});});});
//# sourceMappingURL=ApplicationState.js.map