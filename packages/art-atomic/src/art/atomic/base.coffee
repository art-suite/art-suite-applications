{
  inspect, log
  isNumber, isPlainObject, isPlainArray, isString, isFunction
  stringToNumberArray
  BaseObject
  lowerCamelCase
  upperCamelCase
  inspectedObjectLiteral
  floatEq
  wordsArray
  inspect
} = require 'art-foundation'

module.exports = class Base extends BaseObject

  ###
  TODO

  All Atomics follow the same pattern:

    A fixed, ordered set of fields
    with fixed names
    and fixed defaults

  Most functions could be automatically defined given:

    An array of field-names
    An array of default values
    NOTE: I wish we could just use an object to specifiy those, but
      the order is not guaranteed, and we need a fixed order.

  The field-names could be defined with a string.
  Zero (0) can be the default default-value

  Point:      @defineAtomic fieldNames: "x y"
  Matrix:     @defineAtomic fieldNames: "sx shy tx shx sy ty", defaults: [1, 1]
  Rectangle:  @defineAtomic fieldNames: "x y w h"
  Perimeter:  @defineAtomic fieldNames: "left right top bottom"

  nonStandardInitializes
    Initializing with 1 arg or fields.length args is usually the same for all atomics
    But, intializing with a number of args in between tends to vary.
    I suggest overrides:
    _init0: -> defaults
    _init1: (a) -> all fields = a
    _init2:
    _init3:
    _init4:
    _init#{n}: -> each field gets set individually

  @defineAtomicClass: ({fieldNames, defaults, aliases}) ->
    fields = wordsArray fields if isString fields
    @defineSetAll()           # uses fieldNames
    @defineInit0()            # uses fieldNames and defaults
    @defineInit1()            # uses fieldNames
    @defineInterpolate()      # uses fieldNames
    @defineComparisonOperators()  # uses fieldNames, defines: eq, gt, lt, gte, lte
    @defineMathOperators()        # uses fieldNames, defines: add, sub, mul, div
    @defineToArray()          # uses fieldNames
    @defineInitFromObject()   # uses fieldNames and aliases
    @defineToObject()         # uses fieldNames
    @defineGetters()          # uses fieldNames and aliases
    @defineInto()             # uses fieldNames
    @defineToString()
    @defineInspect()
    @defineToInspectedObjects()

  ###
  _initFromString: (string) ->
    @_init stringToNumberArray(string)...

  constructor: (a, b, c, d, e, f, g) ->
    super
    if isPlainArray a       then @_init a...
    else if isString a      then @_initFromString a
    else if isPlainObject a then @_initFromObject a
    else if a? && !isNumber(a) && !(a instanceof Base) && isFunction(a.toString) then @_initFromString a.toString()
    else                    @_init a, b, c, d, e, f, g

  compare: (b) ->
    return 0 if @eq b
    return -1 if @lte b
    return 1 if @gte b
    NaN

  @getConstructorFunctionName: -> @constructorFunctionName ||= lowerCamelCase @getName()

  @getter
    plainObjects: -> @toObject()
    inspectedObjects: -> inspectedObjectLiteral @class.getConstructorFunctionName() + "(#{@toArray().join ', '})"

  toPlainStructure: -> @getPlainObjects()
  toPlainEvalString: -> inspect @getPlainObjects()

  inspect: -> "#{@class.getConstructorFunctionName()}(#{@toArray().join ', '})"
  toJson: -> @toString()
  toString: (precision) ->
    if precision
      "[#{(a.toPrecision precision for a in @toArray()).join ', '}]"
    else
      "[#{@toArray().join ', '}]"

  neq: (b) -> !@eq b
  between: (a, b) -> @gte(a) && @lte(b)
  floatEq: floatEq
  isNumber: isNumber

  ###
  for use by extending children classes
  ###
  @defineAtomicClass: ({@fieldNames, @constructorFunctionName}) ->
    @fieldNames = wordsArray @fieldNames if isString @fieldNames

    @getConstructorFunctionName() # vivifies @constructorFunctionName if not already set

    @_defineCore @fieldNames
    @_defineComparisonOperators @fieldNames
    @_defineMathOperators @fieldNames
    ###
    TODO: more standard methods to add:

    # most init can be standardized
    _init*

    # more math methods
    min max floor ceil average bound round

    # class methods
    @isPoint

    ###

  reservedWords = with: true
  @_definePrototypeMethodViaEval: (name, paramsList, body) ->
    # try
    #   console.log "#{@getName()}##{name}(#{paramsList}) defined:\n#{body}"
      nameInEval = if reservedWords[name] then "" else name
      @::[name] = eval body = """
        (
        function #{nameInEval}(#{paramsList}) {
        #{body}
        }
        )
      """
    # catch e
    #   console.log "error defining function.\nname: #{name}\nparamsList: #{paramsList}\nbody:"
    #   console.log body
    #   console.error e

  ###
  define: eq, lt, gt, lte, gt
  With these signatures:

    # provide numbers for all fields to compare
    myColor.eq r, g, b, a

    # provide another instance of @class to compare against
    myColor.eq myOtherColor

  ###
  letterFieldNames = wordsArray "a b c d e f"
  @_defineComparisonOperators: (fieldNames) ->
    params = letterFieldNames.slice 0, fieldNames.length

    paramsList = params.join(', ')

    @_definePrototypeMethodViaEval "eq", paramsList, """
      if (this === a) return true;
      if (this.isNumber(a)) {
        return
        #{("this.floatEq(this.#{f}, #{params[i]})" for f, i in fieldNames).join " &&\n  "};
      } else {
        return a &&
        #{("this.floatEq(this.#{f}, a.#{f})" for f in fieldNames).join " &&\n  "};
      }
    """

    comparisonOperators =
      lt: "<"
      gt: ">"
      lte: "<="
      gte: ">="

    for functionName, operator of comparisonOperators
      @_definePrototypeMethodViaEval functionName, paramsList, """
      if (this.isNumber(a)) {
        return
        #{("this.#{f} #{operator} #{params[i]}" for f, i in fieldNames).join " &&\n  "};
      } else {
        return a &&
        #{("this.#{f} #{operator} a.#{f}" for f in fieldNames).join " &&\n  "};
      }
      """

  ###
  define: add, sub, mul and div
  With these signatures:

    myColor.add r, g, b, a   # 4 numbers

    myColor.add myOtherColor, into # add by component
    myColor.add v, into            # one number to add to all

    into is optional. if set:
      it should be an instance of @class
      into is what is returned; a new instance of @class is not created
      into's field are set to the result
      NOTE: Atomic classes are designed to be used Pure-Functionally!
        SO, only use this if you created 'into' and you are not using it ANYWHERE else.

  ###
  @_defineMathOperators: (fieldNames) ->

    mathOperators =
      add: "+"
      sub: "-"
      mul: "*"
      div: "/"

    params = letterFieldNames.slice 0, fieldNames.length

    for functionName, operator of mathOperators
      @_definePrototypeMethodViaEval functionName, params.join(', '), """
        if (this.isNumber(b)) {
          return this._into(
          null,
          #{("this.#{f} #{operator} #{params[i]}" for f, i in fieldNames).join ",\n  "}
          );
        } else if (this.isNumber(a)) {
          return this._into(
          b,
          #{("this.#{f} #{operator} a" for f in fieldNames).join ",\n  "}
          );
        } else {
          return this._into(
          b,
          #{("this.#{f} #{operator} a.#{f}" for f in fieldNames).join ",\n  "}
          );
        }
      """

  @_defineCore: (fields) ->
    fieldList = fields.join ', '
    @_definePrototypeMethodViaEval "_into", "into, #{fieldList}", """
      if (into === true)
        into = this;
      else
        into = into || new this.class;
      return into._setAll(#{fieldList});
    """

    @_definePrototypeMethodViaEval "_setAll", fieldList,
      """
      #{("this.#{f} = #{f}" for f in fields).join ";\n"};
      return this;
      """

    @_definePrototypeMethodViaEval "with", fieldList,
      """
      if (this.eq(#{fieldList}))
        return this;
      else
        return new this.class(#{fieldList});
      """

    for field in fields
      @_definePrototypeMethodViaEval "with#{upperCamelCase field}", field,
        """
        return this.with(
          #{((if f == field then "this.#{f}" else f) for f in fields).join ",\n  "}
        );
        """

    @_definePrototypeMethodViaEval "interpolate", "b, p, into", """
      var oneMinusP = 1 - p;
      return this._into(
      into,
      #{("b.#{f} * p + this.#{f} * oneMinusP" for f in fields).join ",\n"}
      );
      """

    @_definePrototypeMethodViaEval "toArray", "", """
      return [#{("this.#{f}" for f in fields).join ", "}];
      """

    @_definePrototypeMethodViaEval "toObject", "", """
      return {#{("#{f}: this.#{f}" for f in fields).join ", "}};
      """
