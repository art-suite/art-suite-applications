"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["compactFlattenFast", "String", "Object", "Error", "upperCamelCase", "isBoolean"], [global, require('./StandardImport')], (compactFlattenFast, String, Object, Error, upperCamelCase, isBoolean) => {return function(superClass) {let StateFieldsMixin; return StateFieldsMixin = Caf.defClass(class StateFieldsMixin extends superClass {}, function(StateFieldsMixin, classSuper, instanceSuper) {let stateFields; this.extendableProperty({stateFields: this.emptyStateFields = {}}); this._normalizeAndValidateObjectDeclarations = function(f) {return function(...args) {return Caf.each2(compactFlattenFast(args), (arg) => (() => {switch (false) {case !(Caf.is(arg, String)): return f.call(this, {[arg]: null}); case !(Caf.is(arg, Object)): return f.call(this, arg); default: return (() => {throw new Error("invalid argument");})();};})());};}; this.stateFields = stateFields = this._normalizeAndValidateObjectDeclarations(function(fields) {let from, into, temp; this.extendStateFields(fields); return (from = fields, into = from, (from != null) ? (() => {for (let k in from) {let initialValue, field, defaultSetValue, clearValue, upperCamelCaseFieldName; initialValue = from[k]; field = k; temp = (defaultSetValue = initialValue, clearValue = null, upperCamelCaseFieldName = upperCamelCase(field), this.addGetter(field, function() {return this.state[field];}), this.prototype["clear" + upperCamelCaseFieldName] = function() {return this.setState(field, clearValue);}, isBoolean(initialValue) ? (clearValue = false, defaultSetValue = true, this.addSetter(field, function(v) {return this.setState(field, !!v);}), this.prototype["trigger" + upperCamelCaseFieldName] = function() {return this.setState(field, true);}, this.prototype["toggle" + upperCamelCaseFieldName] = function() {return this.setState(field, !this.state[field]);}) : this.addSetter(field, function(v) {return this.setState(field, v);}));}; return temp;})() : undefined, into);}); this.stateField = stateFields;});};});});
//# sourceMappingURL=StateFieldsMixin.js.map