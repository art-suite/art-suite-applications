"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["getEnv", "VirtualNode", "createObjectTreeFactory", "Counters", "getModuleBeingDefined", "log", "merge", "objectHasKeys", "Function", "arrayWithout", "startFrameTimer", "endFrameTimer"], [global, require('./StandardImport'), require('art-object-tree-factory'), require('./Helpers'), {Counters: require('./Counters'), VirtualNode: require('./VirtualNode')}], (getEnv, VirtualNode, createObjectTreeFactory, Counters, getModuleBeingDefined, log, merge, objectHasKeys, Function, arrayWithout, startFrameTimer, endFrameTimer) => {let componentEpoch, artComponentsDebug, devMode, emptyProps, Component; componentEpoch = require('./ComponentEpoch').componentEpoch; artComponentsDebug = getEnv().artComponentsDebug; devMode = require('./DevMode'); emptyProps = {}; return Component = Caf.defClass(class Component extends require('./EpochedStateMixin')(require('./InstanceFunctionBindingMixin')(VirtualNode)) {constructor(props, children) {let propsChildren, temp, base; Counters.componentCreated(); props = children ? (propsChildren = {children}, (props != null) ? merge(props, propsChildren) : propsChildren) : props != null ? props : emptyProps; super(props); this._componentDepth = (((temp = Caf.exists(base = this._renderedIn) && base._componentDepth) != null ? temp : 0)) + 1; this._refs = this._pendingState = this._pendingUpdates = this._virtualSubtree = null; this._mounted = false;};}, function(Component, classSuper, instanceSuper) {let getModule, emptyPropFields, propFields, defaultPreprocessProps, defaultComponentWillMount, defaultComponentWillUnmount, emptyState; this.abstractClass(); this.nonBindingFunctions = ["componentWillMount", "componentWillUnmount", "render"]; this.rerenderAllComponents = require('./RootComponents').rerenderAllComponents; this.toComponentFactory = function() {let objectTreeFactoryOptions; objectTreeFactoryOptions = require('./Helpers').objectTreeFactoryOptions; return createObjectTreeFactory(objectTreeFactoryOptions, this);}; this.getter({epoch: function() {return componentEpoch;}}); this.prototype.processEpoch = function(newProps) {let oldProps, oldState; if (!(this._epochUpdateQueued || newProps)) {return;}; Counters.componentUpdated(); oldProps = this.props; oldState = this.state; if (newProps) {this.props = this._preprocessProps(this._rawProps = newProps, false);}; instanceSuper.processEpoch.call(this); return this._reRenderAndUpdateComponent();}; this.getModule = getModule = function(spec = this.prototype) {return spec.module || spec.hotModule || getModuleBeingDefined();}; this.getCanHotReload = function() {let base; return Caf.exists(base = this.getModule()) && base.hot;}; this._hotReloadUpdate = function(_moduleState) {let name, hotInstances, from, into, to, i, temp; this._moduleState = _moduleState; name = this.getClassName(); return (hotInstances = this._moduleState.hotInstances) ? (log.warn({[`Art.React.Component ${Caf.toString(this.getName())} HotReload`]: {instanceToRerender: hotInstances.length}}), (from = hotInstances, into = from, (from != null) ? (to = from.length, i = 0, (() => {while (i < to) {let instance; instance = from[i]; instance._componentDidHotReload(); temp = i++;}; return temp;})()) : undefined, into)) : undefined;}; this.postCreateConcreteClass = function({classModuleState, hotReloadEnabled}) {classSuper.postCreateConcreteClass.apply(this, arguments); if (hotReloadEnabled) {this._hotReloadUpdate(classModuleState);}; return this.toComponentFactory();}; this.prototype.clone = function() {return new this.class(this.props);}; this.prototype.release = function() {let base; Caf.exists(base = this._virtualSubtree) && base.release(this); return this._virtualSubtree = null;}; this.prototype.withElement = function(f) {return this._virtualSubtree.withElement(f);}; this.prototype.rerenderAllComponents = function() {this._queueRerender(); this.eachSubcomponent((component) => component.rerenderAllComponents()); return null;}; this.getter({verboseInspectedObjects: function() {return this.getInspectedObjects(true);}, inspectedName: function() {return `${Caf.toString(this.className)}${Caf.toString(this.key ? "-" + this.key : "")}`;}, inspectedObjects: function(verbose) {let inspectedObjects, base; inspectedObjects = {[this.inspectedName]: merge({key: this.key, props: objectHasKeys(this.props) ? merge(this.props) : undefined, state: objectHasKeys(this.state) ? merge(this.state) : undefined, rendered: Caf.exists(base = this._virtualSubtree) && base.inspectedObjects})}; return verbose ? {class: this.class.getNamespacePathWithExtendsInfo(), inspectedPathName: this.inspectedPathName, inspectedObjects} : inspectedObjects;}, mounted: function() {return this._mounted;}, element: function() {let base; return Caf.exists(base = this._virtualSubtree) && base.element;}, subcomponents: function() {let ret; ret = []; this.eachSubcomponent((c) => ret.push(c)); return ret;}, refs: function() {let base; if (!this._refs) {this._refs = {}; Caf.exists(base = this._virtualSubtree) && base._captureRefs(this);}; return this._refs;}}); this.prototype.eachSubcomponent = function(f) {let base; Caf.exists(base = this._virtualSubtree) && base.eachInComponent((node) => (node instanceof Component) ? f(node) : undefined); return null;}; this.prototype.find = function(pattern, options, matches = []) {let findAll, verbose, matchFound; if (Caf.exists(options)) {findAll = options.findAll; verbose = options.verbose;}; if (matchFound = this.testMatchesPattern(pattern)) {matches.push(this);}; if (verbose && (matchFound || verbose === "all")) {log(merge({matchFound, inspectedName: this.inspectedName, functionResult: (Caf.is(pattern, Function)) ? pattern(this) : undefined}));}; if (!matchFound || findAll) {this.eachSubcomponent((child) => child.find(pattern, options, matches));}; return matches;}; this.prototype.findElements = function(pattern, options, matches = []) {if (this._virtualSubtree) {if (Caf.exists(options) && options.verbose) {log(`findElements in ${Caf.toString(this.inspectedName)}`);}; this._virtualSubtree.findElements(pattern, options, matches);}; return matches;}; this.extendableProperty({propFields: emptyPropFields = {}}); this.propFields = propFields = this._normalizeAndValidateObjectDeclarations(function(fields) {let from, into, temp; this.extendPropFields(fields); return (from = fields, into = from, (from != null) ? (() => {for (let k in from) {let defaultValue, field; defaultValue = from[k]; field = k; temp = this.addGetter(field, function() {return this.props[field];});}; return temp;})() : undefined, into);}); this.propField = propFields; this.prototype.preprocessProps = defaultPreprocessProps = function(newProps) {return newProps;}; this.prototype.componentWillMount = defaultComponentWillMount = function() {}; this.prototype.componentWillUnmount = defaultComponentWillUnmount = function() {}; this.prototype.componentDidHotReload = function() {let temp; return this.setState("_hotModuleReloadCount", (((temp = this.state._hotModuleReloadCount) != null ? temp : 0)) + 1);}; this.prototype._captureRefs = function(component) {let key, from, into, to, i; if (component === this.renderedIn) {if (key = this.key) {component._refs[key] = this;}; from = this.props.children; into = from; if (from != null) {to = from.length; i = 0; while (i < to) {let child; child = from[i]; child._captureRefs(component); i++;};}; into;}; return this;}; this.prototype._unmount = function() {let base; this._removeHotInstance(); this._componentWillUnmount(); Caf.exists(base = this._virtualSubtree) && base._unmount(); return this._mounted = false;}; this.prototype._addHotInstance = function() {let moduleState; return (moduleState = this.class._moduleState) ? (moduleState.hotInstances || (moduleState.hotInstances = [])).push(this) : undefined;}; this.prototype._removeHotInstance = function() {let moduleState, hotInstances, index; return (moduleState = this.class._moduleState) ? (({hotInstances} = moduleState), (hotInstances && 0 <= (index = hotInstances.indexOf(this))) ? moduleState.hotInstances = arrayWithout(hotInstances, index) : undefined) : undefined;}; emptyState = this._emptyState; this.prototype._instantiate = function(parentComponent, parentVirtualNode) {if (parentComponent !== this._renderedIn && parentComponent != null && this._renderedIn != null) {return this.clone()._instantiate(parentComponent, parentVirtualNode);}; instanceSuper._instantiate.apply(this, arguments); Counters.componentInstantiated(); this.bindFunctionsToInstance(); this._addHotInstance(); this.props = this._preprocessProps(this.props, true); this._componentWillMount(); this._instantiateState(); this._instantiateVirtualSubtree(); this._mounted = true; return this;}; this.prototype._instantiateVirtualSubtree = function() {return (this._virtualSubtree = this._render()) ? (VirtualNode.currentlyRendering = this, this._virtualSubtree._instantiate(this, this), VirtualNode.currentlyRendering = null) : undefined;}; this.prototype._render = function() {let rendered, error; startFrameTimer("acRender"); Counters.componentRendered(); if (artComponentsDebug) {log(`render component: ${Caf.toString(this.className)}`);}; this._refs = null; VirtualNode.currentlyRendering = this; try {rendered = this.render(); if (!(rendered instanceof VirtualNode)) {this._reportInvalidRenderResult(rendered);};} catch (error1) {error = error1; log.error(`Error rendering ${Caf.toString(this.inspectedPath)}`, error); rendered = null;}; VirtualNode.currentlyRendering = null; endFrameTimer(); return rendered;}; this.prototype._canUpdateFrom = function(b) {return this.class === b.class && this.key === b.key;}; this.prototype._shouldReRenderComponent = function(componentInstance) {return this._propsChanged(componentInstance) || this._pendingState;}; this.prototype._reRenderAndUpdateComponent = function() {let newRenderResult, parentVirtualElement, base; startFrameTimer("acUpdate"); if (!this._virtualSubtree) {this._instantiateVirtualSubtree();} else {if (newRenderResult = this._render()) {if (this._virtualSubtree._canUpdateFrom(newRenderResult)) {VirtualNode.currentlyRendering = this; this._virtualSubtree._updateFrom(newRenderResult); VirtualNode.currentlyRendering = null;} else {if (parentVirtualElement = this.parentVirtualElement) {Caf.exists(base = this._virtualSubtree) && base._unmount(); (this._virtualSubtree = newRenderResult)._instantiate(this); parentVirtualElement._updateConcreteChildren();} else {this._reportInvalidRenderResult(newRenderResult);};};};}; endFrameTimer(); return null;}; this.prototype._reportInvalidRenderResult = function(newRenderResult) {let base, base1; log.error("Art.Components Component Render Error: (render ignored)\n\n" + ((newRenderResult instanceof VirtualNode) ? "The render function's top-level Component/VirtualElement changed\ntoo much: The VirtualNode returned by a component's render function\ncannot change its Type or Key if it is the root node of the entire\nvirtual tree.\n\nSolution: Wrap your changing VirtualNode with a non-changing VirtualElement." : "Invalid render result. Must return a VirtualElement or Component instance.")); return log({invalidRenderDetails: {component: this.getInspectedObjects(true), invalidRenderResult: newRenderResult, keyChanged: (Caf.exists(base = this._virtualSubtree) && base.key) !== (Caf.exists(newRenderResult) && newRenderResult.key), typeChanged: (Caf.exists(base1 = this._virtualSubtree) && base1.class) !== (Caf.exists(newRenderResult) && newRenderResult.class) || this._virtualSubtree.elementClassName !== newRenderResult.elementClassName}});}; this.prototype._updateFrom = function(componentInstance) {if (this._shouldReRenderComponent(componentInstance)) {this.processEpoch(componentInstance.props);}; return this;}; this.prototype._preprocessProps = function(props, firstCall) {let error; if (emptyPropFields !== (propFields = this.getPropFields())) {merge(propFields, props);} else {props;}; if (defaultPreprocessProps === this.preprocessProps) {return props;}; return (() => {try {return this.preprocessProps(props, firstCall);} catch (error1) {error = error1; this._logLifeCycleError(error); return props;};})();}; this.prototype._componentDidHotReload = function() {let error; this.bindFunctionsToInstance(true); try {this.componentDidHotReload();} catch (error1) {error = error1; this._logLifeCycleError(error);}; return null;}; this.prototype._componentWillMount = function() {return this._doCustomLifeCycle(defaultComponentWillMount, this.componentWillMount, null);}; this.prototype._componentWillUnmount = function() {return this._doCustomLifeCycle(defaultComponentWillUnmount, this.componentWillUnmount, null);}; this.prototype._doCustomLifeCycle = function(defaultLifeCycle, customLifeCycle, defaultReturnValue) {let error; return (defaultLifeCycle !== customLifeCycle) ? (() => {try {return customLifeCycle.call(this);} catch (error1) {error = error1; this._logLifeCycleError(error); return defaultReturnValue;};})() : defaultReturnValue;}; this.prototype._logLifeCycleError = function(error) {log.error({ArtComponents_lifeCycle: {error, Component: this}}); return null;}; this.prototype._queueRerender = function() {return this._getPendingState();};});});});
//# sourceMappingURL=Component.js.map