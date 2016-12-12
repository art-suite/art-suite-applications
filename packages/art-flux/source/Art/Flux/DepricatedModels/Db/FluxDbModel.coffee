Foundation = require 'art-foundation'
FluxCore = require '../Core'
FluxDbModelBase = require './FluxDbModelBase'

{
  log, BaseObject, decapitalize, pluralize, pureMerge, shallowClone, isString,
  emailRegexp, urlRegexp, isNumber, nextTick, capitalize, inspect, isFunction, merge,
  objectWithout
  isPlainObject
  isPlainArray
  compact
, defineModule, CommunicationStatus} = Foundation

{FluxStore, ModelRegistry, FluxModel}  = FluxCore
{missing, failure, success, pending} = CommunicationStatus

{fluxStore} = FluxStore

idRegExpStr = "[a-z0-9]+"
isId = (v) -> isString(v) && v.match ///^#{idRegExpStr}$///i
isHexColor = (v) -> isString(v) && v.match /^#([a-f0-9]{3})|([a-f0-9]{6})/i


###
FluxDbModel

Adds declarative API:
  @fields - with validation and preprocessing support
  @query - declare/create a model for each query
###
defineModule module, class FluxDbModel extends FluxDbModelBase
  @abstractClass()

  @normalizeUrl: normalizeUrl = (url) ->
    match = url.match urlRegexp
    "#{match[1].toLowerCase()}#{match[2]}#{match[3].toLowerCase()}#{match.slice(4).join ''}"

  ##############################
  # FIELDS
  ##############################

  # fieldTypes are just easy, pre-defined Objects with the right properties:
  # Usage:
  #   This:           @fields webPage: @fieldTypes.id
  #   is the same as: @fields webPage: validate: (v) -> isId v
  @fieldTypes: fieldTypes =
    id:     validate: (v) -> isId v
    color:  validate: (v) -> isHexColor v
    number: validate: (v) -> isNumber v
    date:
      validate:   (v) -> isString(v) || (v instanceof Date)
      preprocess: (v) -> if isString(v) then new Date v else v

    email:
      validate: (v) -> isString(v) && v.trim().match emailRegexp
      preprocess: (v) -> v.trim().toLowerCase()

    url:
      validate: (v) -> isString(v) && v.match urlRegexp
      preprocess: (v) -> normalizeUrl v # downcase protocol and domain name

    boolean:  validate: (v) -> v == true || v == false
    count:    validate: (v) -> isNumber v
    object:   validate: (v) -> isPlainObject v
    string:   validate: (v) -> isString v
    array:    validate: (v) -> isPlainArray v

    trimmedString:
      validate: (v) -> isString v
      preprocess: (v) -> v.trim()


  # declare required* for each of the standard types
  for key in Object.keys @fieldTypes
    requiredKey = "required" + capitalize key
    @fieldTypes[requiredKey] = merge @fieldTypes[key], required: true

  ###
  fieldDeclarationMap is a map from field-names to fieldOptions

  fieldOptions: (all optional)
    validate: ->
    preprocess: ->
    required: t/f
      note: for internal use only, this can also be a string specifying an alternatite field-name
        meaning: 'either this field or the alternate must be set'
    linkTo: "modelName"
  ###

  @fields: (fieldDeclarationMap)->
    @register()
    for field, subOptions of fieldDeclarationMap
      throw new Error "#{@.namespacePath}: @fields declarations using 'type' no longer supported" if subOptions.type
      if linkTo = subOptions.linkTo
        if field.match(/.*Id$/)
          console.warn "FluxDbModel #{@name}: linkTo field '#{field}' should not end in 'Id'"

        # TODO remove _addField with "Id" once we are fully switched over
        # HMM - what to do about "required" ID fields? It is an either-or situation - you can have the field or the fieldID set...
        # maybe there is a preprocess step that copies the ID over if the plainObject is supplied?
        # regardless, only one can be required, so I'll make the "Id" field "required".
        @_addField field + "Id", idFieldOptions = merge @fieldTypes.id, objectWithout subOptions, "linkTo"
        subOptions = merge @fieldTypes.plainObject, subOptions

        if subOptions.required
          delete subOptions.required
          idFieldOptions.required = field

      @_addField field, subOptions

  @getter
    relations: ->
      unless @_relations
        @_relations = {}
        for field, {linkTo} of @fieldProperties when linkTo
          @_relations[field] =
            model: @models[linkTo]
            idField: field + "Id"
        # log _relations:@relations, self:@
        # log relations:relationKeys if (relationKeys = Object.keys(@_relations)).length > 0
      @_relations

  ##############################
  # QUERIES
  ##############################

  ###
  @query defines and registers a new model for returning sets of records.
  Example
    definition:
      class Post extends FluxModel
        @query "feed"

    creates and registers new model class: PostsByFeed

    example use:
      class MyComponent extends RestComponent
        getInitialState: ->
          posts: models.postsByFeed.get "feedId"

    example use:
      class MyComponent extends RestComponent
        @restSubscriptions
          postsByFeed: -> "feedId"

  NOTE: the @queryModel class member MUST be set by an inheriting class before this works.
  options:
    keyFromData: (data) -> key
  ###
  @query: (parameterizedField, options = {})->
    ModelRegistry.register rqm = new @queryModel rm = @register(), parameterizedField, options
    rm.queryModels.push rqm
    rm._queriesToUpdate?.push (fields) ->
      rm._updateQuery rqm, fields[parameterizedField]

  constructor: ->
    super
    @queryModels = []

  ##############################
  # MUTATION METHODS
  ##############################

  put: (id, fields, callback) ->
    if @_presentFieldsValid(fields)
      super id, @_preprocessFields(fields), callback

    else
      # log FluxDbModel_put_FAIL:
      #   model: @name
      #   fields: fields
      #   invalidFields: @_invalidFields fields

      callback && fluxStore.onNextReady => callback
        status: failure
        model: @name
        id: id
        pendingData: fields
        invalidFields: @_invalidFields fields

    null

  post: (fields, callback) ->
    if @_requiredFieldsPresent(fields) && @_presentFieldsValid(fields)
      super @_preprocessFields(fields), callback

    else
      # log FluxDbModel_post_FAIL:
      #   model: @name
      #   fields: fields
      #   missingFields: @_missingFields fields
      #   invalidFields: @_invalidFields fields

      callback && fluxStore.onNextReady => callback
        status: failure
        pendingData: fields
        missingFields: @_missingFields fields
        invalidFields: @_invalidFields fields

    null

  validatePostFields: (fields) ->
    return null if @_requiredFieldsPresent(fields) && @_presentFieldsValid fields
    invalidFields: @_invalidFields fields
    missingFields: @_missingFields fields

  ###################################
  # PRIVATE
  ###################################

  @extendableProperty fieldProperties: {}

  @_addField: (field, options) ->
    @extendFieldProperties field, options

  _missingFields: (fields) ->
    for fieldName, {required} of @fieldProperties when required && !(fields[fieldName]? || fields[required]?)
      fieldName

  _requiredFieldsPresent: (fields) ->
    for fieldName, {required} of @fieldProperties when required && !(fields[fieldName]? || fields[required]?)
      return false
    true

  _preprocessFields: (fields) ->
    processedFields = null
    for fieldName, {preprocess} of @fieldProperties when preprocess && (value = fields[fieldName])?
      if (v = preprocess oldV = fields[fieldName]) != oldV
        processedFields ||= shallowClone fields
        processedFields[fieldName] = v
    processedFields || fields

  _presentFieldsValid: (fields) ->
    for fieldName, {validate} of @fieldProperties when validate && (value = fields[fieldName])? && !validate value
      return false
    true

  _invalidFields: (fields) ->
    for fieldName, {validate} of @fieldProperties when validate && (value = fields[fieldName])? && !validate value
      fieldName
