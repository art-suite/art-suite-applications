"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "Component", "TestElement", "assert"], [global, require('../StandardImport')], (describe, test, Component, TestElement, assert) => {return describe({"child-props": function() {test("children passed to component-factory become @props.children", () => {let Wrapper, MyComponent; Wrapper = Caf.defClass(class Wrapper extends Component {}, function(Wrapper, classSuper, instanceSuper) {this.prototype.render = function() {return TestElement({name: "wrapper"}, TestElement({name: "red"}), TestElement({name: "blue"}));};}); MyComponent = Caf.defClass(class MyComponent extends Component {}, function(MyComponent, classSuper, instanceSuper) {this.prototype.render = function() {return Wrapper(TestElement({name: "red"}), TestElement({name: "blue"}));};}); return MyComponent()._instantiate().onNextReady(({element}) => {assert.eq(element.props.name, "wrapper"); return assert.eq(["red", "blue"], Caf.array(element.children, (child) => child.props.name));});}); return test("baseline", () => {let MyComponent; MyComponent = Caf.defClass(class MyComponent extends Component {}, function(MyComponent, classSuper, instanceSuper) {this.prototype.render = function() {return TestElement(TestElement({name: "red"}), TestElement({name: "blue"}));};}); return MyComponent()._instantiate().onNextReady(({element}) => assert.eq(2, element.children.length));});}});});});
//# sourceMappingURL=ChildrenProp.test.js.map