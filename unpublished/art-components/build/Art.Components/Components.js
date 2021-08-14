"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Component"], [global, require('./StandardImport'), {Component: require('./Component')}], (Component) => {let createAndInstantiateTopComponent, createComponentFactory, mountRootComponent, unmountRootComponent, rerenderAllComponents; return [({createAndInstantiateTopComponent, createComponentFactory} = Component, {createAndInstantiateTopComponent, createComponentFactory}), require('./Init'), ({mountRootComponent, unmountRootComponent, rerenderAllComponents} = require('./RootComponents'), {mountRootComponent, unmountRootComponent, rerenderAllComponents})];});});
//# sourceMappingURL=Components.js.map
