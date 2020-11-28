{
  defineModule
  insert
  moveArrayElement
  objectKeyCount
} = require 'art-standard-lib'
{BaseClass} = require 'art-class-system'

maxMipmapCacheSize = 16 * 2 ** 20

defineModule module, class MipmapCache extends BaseClass
  @singletonClass()

  constructor: ->
    @_hitCount = 0
    @_missCount = 0
    @releaseAll()

  @getter "byteSize hitCount missCount",
    count: -> @_mostRecentlyUsed.length
    memoryInfo: ->
      {
        @byteSize
        @hitCount
        @missCount
        activeCount: @count
      }

  getCacheKey = (bitmap, mipmapNumber) ->
    "#{bitmap.objectId}_#{mipmapNumber}"

  get: (bitmap, mipmapNumber, use = true) ->
    if mipmapNumber == 0
      bitmap

    else if found = @_cache[key = getCacheKey(bitmap, mipmapNumber)]
      @_hitCount++

      if use
        @_mostRecentlyUsed = moveArrayElement @_mostRecentlyUsed, @_mostRecentlyUsed.indexOf(key), 0
      found

    else
      @_missCount++
      superMap = @get bitmap, mipmapNumber - 1, false
      {mipmap} = superMap

      # if use
      #   log MipmapCache: get: miss:
      #     in: {bitmap, size: bitmap.size}
      #     out: {mipmap, size: mipmap.size}
      #     mipmapNumber:mipmapNumber

      @_add key, mipmap

  releaseAll: ->
    @_cache = {}
    @_byteSize = 0
    @_mostRecentlyUsed = []

  _add: (key, mipmap) ->
    @_validate "pre _add"
    throw new Error "already in!" if @_cache[key]
    @_reserveSpace mipmap.byteSize
    @_validate "mid _add"
    @_byteSize += mipmap.byteSize
    @_cache[key] = mipmap
    before = (a for a in @_mostRecentlyUsed)
    lenBefore = @_mostRecentlyUsed.length
    @_mostRecentlyUsed = insert @_mostRecentlyUsed, 0, key
    throw new Error "no first" unless 0 == @_mostRecentlyUsed.indexOf key
    # log _add:
    #   key: key
    #   before: before
    #   after: @_mostRecentlyUsed
    @_validate "post _add"
    mipmap

  _reserveSpace: (bytes) ->
    @_validate "pre _reserveSpace"
    while @_mostRecentlyUsed.length > 0 && @_byteSize + bytes > maxMipmapCacheSize
      @_popLru()
    @_validate "post _reserveSpace"
    bytes

  _validate: (context) ->
    validateByteSize = 0
    unless @_mostRecentlyUsed.length == objectKeyCount @_cache
      log.error _validate:
        context: context
        lengthMismatch: {@_mostRecentlyUsed, @_cache}

    for key in @_mostRecentlyUsed
      if bitmap = @_cache[key]
        validateByteSize += bitmap.byteSize
      else
        log.error _validate:
          context: context
          keyNotFound: key

    if validateByteSize != @_byteSize
      log.error _validate:
        context: context
        wrongByteSize: {validateByteSize, @_byteSize}

  _popLru: ->
    @_validate "pre _popLru"
    lruKey = @_mostRecentlyUsed.pop()
    # log "_popLru #{lruKey}"
    throw new Error "no in?!?!" unless @_cache[lruKey]
    @_byteSize -= @_cache[lruKey].byteSize
    # log {@_byteSize, _mostRecentlyUsed: @_mostRecentlyUsed.length}
    throw new Error "already deketed!" unless @_cache[lruKey]
    delete @_cache[lruKey]
    @_validate "post _popLru"
