"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "Component", "assert", "TestElement"], [global, require('../StandardImport')], (test, Component, assert, TestElement) => {return test("clone component", function() {let MyComponent, instance, instanceClone; MyComponent = Caf.defClass(class MyComponent extends Component {}, function(MyComponent, classSuper, instanceSuper) {this.prototype.render = function() {return TestElement({key: "normalWrapper"});};}); instance = MyComponent({foo: 123}); instanceClone = instance.clone(); assert.eq(instance.props, instanceClone.props); return assert.eq(instance.class, instanceClone.class);});});});
//# sourceMappingURL=Clone.test.js.map
