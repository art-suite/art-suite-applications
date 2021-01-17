{defineModule, log} = require 'art-standard-lib'
{Model} = require "@art-suite/models"
{artFluxDeprecatedWarning} = require "./Lib"

defineModule module, class FluxModel extends Model
  @abstractClass()

  ###
    DEPRECATED
  ###
  storeEntryUpdated:  (entry) -> if @fluxStoreEntryUpdated then artFluxDeprecatedWarning "fluxStoreEntryUpdated", "storeEntryUpdated"; @fluxStoreEntryUpdated entry
  storeEntryAdded:    (entry) -> if @fluxStoreEntryAdded   then artFluxDeprecatedWarning "fluxStoreEntryAdded",   "storeEntryAdded"  ; @fluxStoreEntryAdded   entry
  storeEntryRemoved:  (entry) -> if @fluxStoreEntryRemoved then artFluxDeprecatedWarning "fluxStoreEntryRemoved", "storeEntryRemoved"; @fluxStoreEntryRemoved entry
  loadModelRecord:    (key)               -> if @loadFluxRecord then artFluxDeprecatedWarning "loadFluxRecord", "loadModelRecord"; @loadFluxRecord key

  fluxStoreGet:       (key)               -> artFluxDeprecatedWarning "fluxStoreGet",     "getModelRecord"    ;@getModelRecord      key
  updateFluxStore:    (key, modelRecord)  -> artFluxDeprecatedWarning "updateFluxStore",  "updateModelRecord" ;@updateModelRecord   key, modelRecord
  _localStoreKey:     (id)                -> artFluxDeprecatedWarning "_localStoreKey"; "fluxModel:#{@_name}:#{id}"
  _localStoreGet:     (id)                -> artFluxDeprecatedWarning "_localStoreGet"; if data = localStorage.getItem @_localStoreKey id then JSON.parse data else null
  _localStoreSet:     (id, data)          -> artFluxDeprecatedWarning "_localStoreSet"; localStorage.setItem @_localStoreKey(id), JSON.stringify data
