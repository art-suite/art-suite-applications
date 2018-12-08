{merge, log, object, mergeInto, isString} = require 'art-standard-lib'
{createObjectTreeFactories} = require 'art-object-tree-factory'
{VirtualElement, objectTreeFactoryOptions} = require '../Core'
{getNextPageIndexes} = require "./PagingScrollElement"

{VirtualNode} = require '../Core'

# Note, this needs to work in the main AND worker threads...
# That's why this doesn't use ArtEngine.ElementFactory.elementClasses.
standardArtEngineElementClassNames = "
  BitmapElement
  BlurElement
  CanvasElement
  ShapeElement
  Element
  FillElement
  OutlineElement
  PagingScrollElement
  RectangleElement
  ShadowElement
  TextElement
  TextInputElement
  ScrollElement
  FilterElement
  "

{postProcessProps} = objectTreeFactoryOptions

ArtEngineMacros = require './ArtEngineMacros'

objectTreeFactoryOptions.preprocessElement = (element, Factory) ->
    if isString element
      if macro = ArtEngineMacros[element]
        macro
      else
        log.warn "ArtReact-ArtEngine: string '#{element.slice 0, 20}' didn't match any macros. Implicit-text children are DEPRICATED. Use text: 'string'. Currently rendering: #{VirtualNode.currentlyRendering?.inspectedName || 'none'}. Factory: #{Factory.inspect()}"
        _textFromString: element

    else
      element


module.exports = class Aim
  @createVirtualElementFactories: (VirtualElementClass, elementClassNames = standardArtEngineElementClassNames) ->
    mergeInto @, createObjectTreeFactories objectTreeFactoryOptions, elementClassNames, (elementClassName) ->
      (props, children) ->
        new VirtualElementClass elementClassName,
          postProcessProps props
          children

    @bindHelperFunctions()
    @

  @bindHelperFunctions: ->
    @PagingScrollElement.getNextPageIndexes = getNextPageIndexes
