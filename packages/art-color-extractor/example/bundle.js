(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var PromisedImage = require('../../promised-image');
var ColorExtractor = require('../');
var Q = require('q');
Parse.initialize("ctx4wuLBn7UYYuMM8DZwvjk0sf2fDCY1D13elTDf", "xYETZaIoHBbJ9Y6uePM195gYdI4om0Y6qws7fFeI");

var IMAGE_WIDTH = 100,
    IMAGE_HEIGHT = 100,
    MAX_MEDIAS = 10;


var toCSSColor = function(colors) {
  return 'rgb' + (colors.length == 4 ? 'a' : '') + '(' + colors.join(', ') + ')';
};
var MediaItem = React.createClass({displayName: "MediaItem",
  getInitialState: function() {
    return {
      blobLoaded: false,
      imageLoaded: false,
      imageUrl: undefined
    };
  },

  _imageUrl: function() {
    if (this.props.photoUrl) {
      return this.props.photoUrl
        .replace('oz-dev-media.s3.amazonaws.com', 'imikimi-oz-dev-media.imgix.net')
        .replace(/https?:/,'http:') + '?w=' + IMAGE_WIDTH + '&h=' + IMAGE_HEIGHT + '&q=100&fit=scale';
    }
  },

  _getImageBlob: function() {
    var imageUrl = this._imageUrl()
    if (imageUrl) {
      return PromisedImage.fetchBlob(imageUrl);
    }
    else {
      return Q.reject('No mediaPhotoUrl');
    }
  },

  componentWillUpdate: function() {
    if (!this.state.blobLoaded) {
      this._getImageBlob().then(function(blob) {
        // console.log('blobLoaded');
        this.setState({imageUrl: window.URL.createObjectURL(blob)});
        this.setState({blobLoaded: true});
      }.bind(this));
    }
    else if (!this.state.imageLoaded) {
      var domImage = this.refs.image.getDOMNode()
      var onload = function() {
        this.props.onImageLoad.call(this, this.props.id, domImage);
        this.setState({imageLoaded: true});
      }.bind(this);

      if (domImage.complete) {
        onload()
      }
      else {
        domImage.onload = onload;
      }
    }
  },

  renderImage: function() {
    if (this.state.imageUrl) {
      return (React.createElement("img", {src: this.state.imageUrl, ref: "image"}));
    }
    else {
      return false;
    }
  },


  renderVibrant: function(colorInfo) {
    var vibrant = colorInfo.vibrant;
    if (vibrant) {
      return (
        React.createElement("figure", {className: "vibrant"}, 
          React.createElement("div", null, 
            Object.keys(vibrant).map(function(colorLabel) {
              return (React.createElement("div", null, React.createElement("span", {className: "vibrant-color", style: { backgroundColor: 'rgb(' + vibrant[colorLabel].join(',') + ')'}}), colorLabel));
            }.bind(this))
          ), 
          React.createElement("figcaption", null, "Vibrant labeled colors")
        )
      );
    }
    else {
      return false;
    }
  },


  renderThiefColor: function(colorInfo) {
    if (colorInfo && colorInfo.colorThief && colorInfo.colorThief.dominantColor) {
      return (
        React.createElement("figure", null, 
          React.createElement("span", {className: "thief-single-color", style: {backgroundColor: toCSSColor(colorInfo.colorThief.dominantColor)}}), 
          React.createElement("figcaption", null, "ColorThief single color")
        )
      );
    }
    else { return false; }
  },

  renderThiefPalette: function(colorInfo) {
    if (colorInfo && colorInfo.colorThief && colorInfo.colorThief.palette) {
      console.log('rendering colorthiefpalette');
      return (
        React.createElement("figure", {className: "thief-palette"}, 
          React.createElement("div", null, 
            colorInfo.colorThief.palette.map(function(color) {
              return (React.createElement("span", {className: "thief-palette-color", style: { backgroundColor: toCSSColor(color)}}));
            })
          ), 
          React.createElement("figcaption", null, "ColorThief palette")
        )
      );
    }
    else { return false; }
  },

  renderGradifyDominantColor: function(colorInfo) {
    if (colorInfo && colorInfo.gradify && colorInfo.gradify.dominantColor) {
      var dominantCSSColor = toCSSColor(colorInfo.gradify.dominantColor)
      return (
        React.createElement("figure", null, 
          React.createElement("span", {className: "gradify-dominant-color", style: {backgroundColor: dominantCSSColor}}), 
          React.createElement("figcaption", null, "Gradify dominant color")
        )
      );
    }
    else {
      return null;
    }
  },

  renderGradifyGradients: function(colorInfo) {
    if (colorInfo && colorInfo.gradify && colorInfo.gradify.gradients) {
      var cssGradientsValue = colorInfo.gradify.gradients.map(function(gradient) {
        var gv = 'linear-gradient(' + gradient[0] + 'deg, ' + toCSSColor(gradient[1]) + ' 0%, ' + toCSSColor(gradient[2]) + ' 100%)';
        console.log('gv', gv);
        return gv;
      }).join(',');
      // var cssGradientsValue = '';
      return (
        React.createElement("figure", null, 
          React.createElement("span", {className: "gradify-gradients", style: {backgroundImage: cssGradientsValue}}), 
          React.createElement("figcaption", null, "Gradify gradients")
        )
      );
    }
    else {
      return null;
    }
  },


  renderColorInfo: function() {
    // var toCSSColor = function(colors) {
    //   return 'rgb(' + colors.join(', ') + ')';
    // };

    if (this.props.colorInfo) {
      return (React.createElement("span", null, 
        this.renderThiefColor(this.props.colorInfo), 
        this.renderThiefPalette(this.props.colorInfo), 
        this.renderVibrant(this.props.colorInfo), 
        this.renderGradifyDominantColor(this.props.colorInfo), 
        this.renderGradifyGradients(this.props.colorInfo)
      ));
    }
    else {
      return false;
    }
  },

  render: function() {
    return (
      React.createElement("div", {className: "media-item"}, 
        React.createElement("header", null, this.props.id), 
        this.renderImage(), 
        this.renderColorInfo()
      )
    );
  }
});


var App = React.createClass({displayName: "App",
  getInitialState: function() {
    return {
      colorInfo: {},
      extractions: {},
      extractor: new ColorExtractor('worker.js', 4),
      medias: [],
      totalMediaCount: undefined,
      loaded: false,
    };
  },

  componentDidMount: function() {
    // Figure out how many medias there are
    this._getMediaCount()
      .then(function(count) {
        this.setState({totalMediaCount: count});
        return this._getMedias()
      }.bind(this));
  },

  componentWillUpdate: function(props, state) {
    // var unfetchedImageMedias = state.medias.filter(function(media) {
    //   return (typeof media.image === 'undefined');
    // });

  },

  _getMedias: function(offset) {
    var offset = offset || 0;
    var query = this._baseMediaQuery().skip(offset);
    return query.find().then(function(res) {
      if (res.length > 0 && this.state.medias.length < MAX_MEDIAS) {
        this.setState({medias: this.state.medias.concat(res)});
        return this._getMedias(offset+res.length);
      }
      else {
        this.setState({loaded: true});
        for (var i=0, il = this.state.medias.length; i < il; i++) {
          // if (typeof this.state.medias[i].get('colorInfo') === 'undefined') {
          //   // Start an extraction for this media
          //
          // }
          // else {
          //
          // }
        }
        return this.state.medias;
      }
    }.bind(this));
  },

  _getMediaCount: function() {
    return this._baseMediaQuery().count();
  },

  _baseMediaQuery: function() {
    return new Parse.Query('Media')
      .exists("mediaPhotoUrl")
      .startsWith('mediaPhotoUrl', 'https://oz-dev-media.s3.amazonaws.com/')
      .limit(MAX_MEDIAS).descending('createdAt');
  },

  imageLoaded: function(id, imageEle) {
    // Start extraction
    if (!this.state.extractions[id]) {
      console.log('beginning extraction of', id)
      this.state.extractions[id] =
        this.state.extractor.extract(imageEle)
        .then(function(colorInfo) {
          this.state.colorInfo[id] = colorInfo;
          this.forceUpdate();
          console.log(colorInfo);
        }.bind(this), function(err) {
          console.error(err);
        });
    }
  },

  render: function() {
    var mediaCountLoaded = (typeof this.state.totalMediaCount !== 'undefined');
    var loadedCount = this.state.medias.length;
    var totalCount = this.state.totalMediaCount;
    return (
      React.createElement("div", null, 
        React.createElement("header", null, React.createElement("h1", null, "ColorInfo Demo")), 
        React.createElement("dl", null, 
          React.createElement("dt", null, "Media Records"), 
          React.createElement("dd", null, 
            React.createElement("progress", {value: loadedCount, max: totalCount})
          ), 
          React.createElement("dd", null, 
            mediaCountLoaded ? (loadedCount + ' / ' + totalCount) : ''
          )
        ), 
        React.createElement("div", null, 
           this.state.medias.map(function(media) {
              return (React.createElement(MediaItem, {colorInfo: this.state.colorInfo[media.id], onImageLoad: this.imageLoaded, photoUrl: media.get('mediaPhotoUrl'), id: media.id, key: media.id}));
            }.bind(this))
          
        )
      )
    );
  }
});

React.render(
  React.createElement(App, null),
  document.body
);

},{"../":2,"../../promised-image":9,"q":6}],2:[function(require,module,exports){
module.exports = require('./src');

},{"./src":8}],3:[function(require,module,exports){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

function EventEmitter() {
  this._events = this._events || {};
  this._maxListeners = this._maxListeners || undefined;
}
module.exports = EventEmitter;

// Backwards-compat with node 0.10.x
EventEmitter.EventEmitter = EventEmitter;

EventEmitter.prototype._events = undefined;
EventEmitter.prototype._maxListeners = undefined;

// By default EventEmitters will print a warning if more than 10 listeners are
// added to it. This is a useful default which helps finding memory leaks.
EventEmitter.defaultMaxListeners = 10;

// Obviously not all Emitters should be limited to 10. This function allows
// that to be increased. Set to zero for unlimited.
EventEmitter.prototype.setMaxListeners = function(n) {
  if (!isNumber(n) || n < 0 || isNaN(n))
    throw TypeError('n must be a positive number');
  this._maxListeners = n;
  return this;
};

EventEmitter.prototype.emit = function(type) {
  var er, handler, len, args, i, listeners;

  if (!this._events)
    this._events = {};

  // If there is no 'error' event listener then throw.
  if (type === 'error') {
    if (!this._events.error ||
        (isObject(this._events.error) && !this._events.error.length)) {
      er = arguments[1];
      if (er instanceof Error) {
        throw er; // Unhandled 'error' event
      }
      throw TypeError('Uncaught, unspecified "error" event.');
    }
  }

  handler = this._events[type];

  if (isUndefined(handler))
    return false;

  if (isFunction(handler)) {
    switch (arguments.length) {
      // fast cases
      case 1:
        handler.call(this);
        break;
      case 2:
        handler.call(this, arguments[1]);
        break;
      case 3:
        handler.call(this, arguments[1], arguments[2]);
        break;
      // slower
      default:
        len = arguments.length;
        args = new Array(len - 1);
        for (i = 1; i < len; i++)
          args[i - 1] = arguments[i];
        handler.apply(this, args);
    }
  } else if (isObject(handler)) {
    len = arguments.length;
    args = new Array(len - 1);
    for (i = 1; i < len; i++)
      args[i - 1] = arguments[i];

    listeners = handler.slice();
    len = listeners.length;
    for (i = 0; i < len; i++)
      listeners[i].apply(this, args);
  }

  return true;
};

EventEmitter.prototype.addListener = function(type, listener) {
  var m;

  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  if (!this._events)
    this._events = {};

  // To avoid recursion in the case that type === "newListener"! Before
  // adding it to the listeners, first emit "newListener".
  if (this._events.newListener)
    this.emit('newListener', type,
              isFunction(listener.listener) ?
              listener.listener : listener);

  if (!this._events[type])
    // Optimize the case of one listener. Don't need the extra array object.
    this._events[type] = listener;
  else if (isObject(this._events[type]))
    // If we've already got an array, just append.
    this._events[type].push(listener);
  else
    // Adding the second element, need to change to array.
    this._events[type] = [this._events[type], listener];

  // Check for listener leak
  if (isObject(this._events[type]) && !this._events[type].warned) {
    var m;
    if (!isUndefined(this._maxListeners)) {
      m = this._maxListeners;
    } else {
      m = EventEmitter.defaultMaxListeners;
    }

    if (m && m > 0 && this._events[type].length > m) {
      this._events[type].warned = true;
      console.error('(node) warning: possible EventEmitter memory ' +
                    'leak detected. %d listeners added. ' +
                    'Use emitter.setMaxListeners() to increase limit.',
                    this._events[type].length);
      if (typeof console.trace === 'function') {
        // not supported in IE 10
        console.trace();
      }
    }
  }

  return this;
};

EventEmitter.prototype.on = EventEmitter.prototype.addListener;

EventEmitter.prototype.once = function(type, listener) {
  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  var fired = false;

  function g() {
    this.removeListener(type, g);

    if (!fired) {
      fired = true;
      listener.apply(this, arguments);
    }
  }

  g.listener = listener;
  this.on(type, g);

  return this;
};

// emits a 'removeListener' event iff the listener was removed
EventEmitter.prototype.removeListener = function(type, listener) {
  var list, position, length, i;

  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  if (!this._events || !this._events[type])
    return this;

  list = this._events[type];
  length = list.length;
  position = -1;

  if (list === listener ||
      (isFunction(list.listener) && list.listener === listener)) {
    delete this._events[type];
    if (this._events.removeListener)
      this.emit('removeListener', type, listener);

  } else if (isObject(list)) {
    for (i = length; i-- > 0;) {
      if (list[i] === listener ||
          (list[i].listener && list[i].listener === listener)) {
        position = i;
        break;
      }
    }

    if (position < 0)
      return this;

    if (list.length === 1) {
      list.length = 0;
      delete this._events[type];
    } else {
      list.splice(position, 1);
    }

    if (this._events.removeListener)
      this.emit('removeListener', type, listener);
  }

  return this;
};

EventEmitter.prototype.removeAllListeners = function(type) {
  var key, listeners;

  if (!this._events)
    return this;

  // not listening for removeListener, no need to emit
  if (!this._events.removeListener) {
    if (arguments.length === 0)
      this._events = {};
    else if (this._events[type])
      delete this._events[type];
    return this;
  }

  // emit removeListener for all listeners on all events
  if (arguments.length === 0) {
    for (key in this._events) {
      if (key === 'removeListener') continue;
      this.removeAllListeners(key);
    }
    this.removeAllListeners('removeListener');
    this._events = {};
    return this;
  }

  listeners = this._events[type];

  if (isFunction(listeners)) {
    this.removeListener(type, listeners);
  } else {
    // LIFO order
    while (listeners.length)
      this.removeListener(type, listeners[listeners.length - 1]);
  }
  delete this._events[type];

  return this;
};

EventEmitter.prototype.listeners = function(type) {
  var ret;
  if (!this._events || !this._events[type])
    ret = [];
  else if (isFunction(this._events[type]))
    ret = [this._events[type]];
  else
    ret = this._events[type].slice();
  return ret;
};

EventEmitter.listenerCount = function(emitter, type) {
  var ret;
  if (!emitter._events || !emitter._events[type])
    ret = 0;
  else if (isFunction(emitter._events[type]))
    ret = 1;
  else
    ret = emitter._events[type].length;
  return ret;
};

function isFunction(arg) {
  return typeof arg === 'function';
}

function isNumber(arg) {
  return typeof arg === 'number';
}

function isObject(arg) {
  return typeof arg === 'object' && arg !== null;
}

function isUndefined(arg) {
  return arg === void 0;
}

},{}],4:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = setTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            currentQueue[queueIndex].run();
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    clearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        setTimeout(drainQueue, 0);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

// TODO(shtylman)
process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],5:[function(require,module,exports){
(function (process){
/*!
 * Copyright 2013 Robert Katić
 * Released under the MIT license
 * https://github.com/rkatic/p/blob/master/LICENSE
 *
 * High-priority-tasks code-portion based on https://github.com/kriskowal/asap
 * Long-Stack-Support code-portion based on https://github.com/kriskowal/q
 */
;(function( factory ){
	// CommonJS
	if ( typeof module !== "undefined" && module && module.exports ) {
		module.exports = factory();

	// RequireJS
	} else if ( typeof define === "function" && define.amd ) {
		define( factory );

	// global
	} else {
		P = factory();
	}
})(function() {
	"use strict";

	var withStack = withStackThrowing,
		pStartingLine = captureLine(),
		pFileName,
		currentTrace = null;

	function withStackThrowing( error ) {
		if ( !error.stack ) {
			try {
				throw error;
			} catch ( e ) {}
		}
		return error;
	}

	if ( new Error().stack ) {
		withStack = function( error ) {
			return error;
		};
	}

	function getTrace() {
		var stack = withStack( new Error() ).stack;
		if ( !stack ) {
			return null;
		}

		var stacks = [ filterStackString( stack, 1 ) ];

		if ( currentTrace ) {
			stacks = stacks.concat( currentTrace );

			if ( stacks.length === 128 ) {
				stacks.pop();
			}
		}

		return stacks;
	}

	function getFileNameAndLineNumber( stackLine ) {
		var m =
			/at .+ \((.+):(\d+):(?:\d+)\)$/.exec( stackLine ) ||
			/at ([^ ]+):(\d+):(?:\d+)$/.exec( stackLine ) ||
			/@(.+):(\d+):(?:\d+)$/.exec( stackLine );

		return m ? { fileName: m[1], lineNumber: Number(m[2]) } : null;
	}

	function captureLine() {
		var stack = withStack( new Error() ).stack;
		if ( !stack ) {
			return 0;
		}

		var lines = stack.split("\n");
		var firstLine = lines[0].indexOf("@") > 0 ? lines[1] : lines[2];
		var pos = getFileNameAndLineNumber( firstLine );
		if ( !pos ) {
			return 0;
		}

		pFileName = pos.fileName;
		return pos.lineNumber;
	}

	function filterStackString( stack, ignoreFirstLines ) {
		var lines = stack.split("\n");
		var goodLines = [];

		for ( var i = ignoreFirstLines|0, l = lines.length; i < l; ++i ) {
			var line = lines[i];

			if ( line && !isNodeFrame(line) && !isInternalFrame(line) ) {
				goodLines.push( line );
			}
		}

		return goodLines.join("\n");
	}

	function isNodeFrame( stackLine ) {
		return stackLine.indexOf("(module.js:") !== -1 ||
			   stackLine.indexOf("(node.js:") !== -1;
	}

	function isInternalFrame( stackLine ) {
		var pos = getFileNameAndLineNumber( stackLine );
		return !!pos &&
			pos.fileName === pFileName &&
			pos.lineNumber >= pStartingLine &&
			pos.lineNumber <= pEndingLine;
	}

	var STACK_JUMP_SEPARATOR = "\nFrom previous event:\n";

	function makeStackTraceLong( error ) {
		if ( error instanceof Error ) {
			var stack = error.stack;

			if ( !stack ) {
				stack = withStack( error ).stack;

			} else if ( ~stack.indexOf(STACK_JUMP_SEPARATOR) ) {
				return;
			}

			if ( stack ) {
				error.stack = [ filterStackString( stack, 0 ) ]
					.concat( currentTrace || [] )
					.join(STACK_JUMP_SEPARATOR);
			}
		}
	}

	//__________________________________________________________________________

	var
		isNodeJS = ot(typeof process) && process != null &&
			({}).toString.call(process) === "[object process]",

		hasSetImmediate = typeof setImmediate === "function",

		gMutationObserver =
			ot(typeof MutationObserver) && MutationObserver ||
			ot(typeof WebKitMutationObserver) && WebKitMutationObserver,

		head = new TaskNode(),
		tail = head,
		flushing = false,
		nFreeTaskNodes = 0,

		requestFlush =
			isNodeJS ? requestFlushForNodeJS :
			gMutationObserver ? makeRequestCallFromMutationObserver( flush ) :
			makeRequestCallFromTimer( flush ),

		pendingErrors = [],
		requestErrorThrow = makeRequestCallFromTimer( throwFirstError ),

		handleError,

		domain,

		call = ot.call,
		apply = ot.apply;

	tail.next = head;

	function TaskNode() {
		this.f = null;
		this.a = null;
		this.b = null;
		this.next = null;
	}

	function ot( type ) {
		return type === "object" || type === "function";
	}

	function throwFirstError() {
		if ( pendingErrors.length ) {
			throw pendingErrors.shift();
		}
	}

	function flush() {
		while ( head !== tail ) {
			var h = head = head.next;

			if ( nFreeTaskNodes >= 1024 ) {
				tail.next = tail.next.next;
			} else {
				++nFreeTaskNodes;
			}

			var f = h.f;
			var a = h.a;
			var b = h.b;
			h.f = null;
			h.a = null;
			h.b = null;

			f( a, b );
		}

		flushing = false;
		currentTrace = null;
	}

	function schedule( f, a, b ) {
		var node = tail.next;

		if ( node === head ) {
			tail.next = node = new TaskNode();
			node.next = head;
		} else {
			--nFreeTaskNodes;
		}

		tail = node;

		node.f = f;
		node.a = a;
		node.b = b;

		if ( !flushing ) {
			flushing = true;
			requestFlush();
		}
	}

	function requestFlushForNodeJS() {
		var currentDomain = process.domain;

		if ( currentDomain ) {
			if ( !domain ) domain = (1,require)("domain");
			domain.active = process.domain = null;
		}

		if ( flushing && hasSetImmediate ) {
			setImmediate( flush );

		} else {
			process.nextTick( flush );
		}

		if ( currentDomain ) {
			domain.active = process.domain = currentDomain;
		}
	}

	function makeRequestCallFromMutationObserver( callback ) {
		var toggle = 1;
		var node = document.createTextNode("");
		var observer = new gMutationObserver( callback );
		observer.observe( node, {characterData: true} );

		return function() {
			toggle = -toggle;
			node.data = toggle;
		};
	}

	function makeRequestCallFromTimer( callback ) {
		return function() {
			var timeoutHandle = setTimeout( handleTimer, 0 );
			var intervalHandle = setInterval( handleTimer, 50 );

			function handleTimer() {
				clearTimeout( timeoutHandle );
				clearInterval( intervalHandle );
				callback();
			}
		};
	}

	if ( isNodeJS ) {
		handleError = function( e ) {
			currentTrace = null;
			requestFlush();
			throw e;
		};

	} else {
		handleError = function( e ) {
			pendingErrors.push( e );
			requestErrorThrow();
		}
	}

	//__________________________________________________________________________

	var FULFILLED = 1;
	var REJECTED = 2;

	var OP_CALL = -1;
	var OP_THEN = -2;
	var OP_MULTIPLE = -3;
	var OP_END = -4;

	var VOID = P(void 0);

	function DoneEb( e ) {
		if ( P.onerror ) {
			(1,P.onerror)( e );

		} else {
			throw e;
		}
	}

	function P( x ) {
		return x instanceof Promise ?
			x :
			Resolve( new Promise(), x );
	}

	P.longStackSupport = false;

	function Fulfill( p, value ) {
		if ( p._state > 0 ) {
			return;
		}

		p._state = FULFILLED;
		p._value = value;
		p._domain = null;

		HandleSettled( p );
	}

	function Reject( p, reason ) {
		if ( p._state > 0 ) {
			return;
		}

		if ( currentTrace ) {
			makeStackTraceLong( reason );
		}

		p._state = REJECTED;
		p._value = reason;

		if ( isNodeJS ) {
			p._domain = process.domain;
		}

		if ( p._op === OP_END ) {
			handleError( reason );

		} else {
			HandleSettled( p );
		}
	}

	function Propagate( parent, p ) {
		if ( p._state > 0 ) {
			return;
		}

		p._state = parent._state;
		p._value = parent._value;
		p._domain = parent._domain;

		HandleSettled( p );
	}

	function Resolve( p, x ) {
		if ( p._state > 0 ) {
			return p;
		}

		if ( x instanceof Promise ) {
			ResolveWithPromise( p, x );

		} else {
			var type = typeof x;

			if ( type === "object" && x !== null || type === "function" ) {
				ResolveWithObject( p, x )

			} else {
				Fulfill( p, x );
			}
		}

		return p;
	}

	function ResolveWithPromise( p, x ) {
		if ( x === p ) {
			Reject( p, new TypeError("You can't resolve a promise with itself") );

		} else if ( x._state > 0 ) {
			Propagate( x, p );

		} else {
			OnSettled( x, OP_THEN, p );
		}
	}

	function ResolveWithObject( p, x ) {
		var then = GetThen( p, x );

		if ( typeof then === "function" ) {
			TryResolver( resolverFor(p, false), then, x );

		} else {
			Fulfill( p, x );
		}
	}

	function GetThen( p, x ) {
		try {
			return x.then;

		} catch ( e ) {
			Reject( p, e );
			return null;
		}
	}

	function TryResolver( d, resolver, x ) {
		try {
			call.call( resolver, x, d.resolve, d.reject );

		} catch ( e ) {
			d.reject( e );
		}
	}

	function HandleSettled( p ) {
		if ( p._pending !== null ) {
			HandlePending( p, p._op, p._pending );
			p._pending = null;
		}
	}

	function HandlePending( p, op, pending ) {
		if ( op >= 0 ) {
			pending._cb( p, op );

		} else if ( op === OP_CALL ) {
			pending( p );

		} else if ( op === OP_THEN ) {
			schedule( Then, p, pending );

		} else {
			for ( var i = 0, l = pending.length; i < l; i += 2 ) {
				HandlePending( p, pending[i], pending[i + 1] );
			}
		}
	}

	function OnSettled( p, op, pending ) {
		if ( p._state > 0 ) {
			HandlePending( p, op, pending );

		} else if ( p._pending === null ) {
			p._pending = pending;
			p._op = op;

		} else if ( p._op === OP_MULTIPLE ) {
			p._pending.push( op, pending );

		} else {
			p._pending = [ p._op, p._pending, op, pending ];
			p._op = OP_MULTIPLE;
		}
	}

	function Then( parent, p ) {
		var cb = parent._state === FULFILLED ? p._cb : p._eb;
		p._cb = null;
		p._eb = null;

		if ( p._trace ) {
			currentTrace = p._trace;
			p._trace = null;
		}

		if ( cb === null ) {
			Propagate( parent, p );

		} else {
			HandleCallback( p, cb, parent._value, parent._domain || p._domain );
		}
	}

	function HandleCallback( p, cb, value, domain ) {
		if ( domain ) {
			if ( domain._disposed ) return;
			domain.enter();
		}

		try {
			value = cb( value );

		} catch ( e ) {
			Reject( p, e );
			p = null;
		}

		if ( p ) Resolve( p, value );
		if ( domain ) domain.exit();
	}

	function resolverFor( promise, nodelike ) {
		var trace = P.longStackSupport ? getTrace() : null;

		function resolve( error, y ) {
			if ( promise ) {
				var p = promise;
				promise = null;

				if ( trace ) {
					if ( currentTrace ) {
						trace = null;

					} else {
						currentTrace = trace;
					}
				}

				if ( error ) {
					Reject( p, nodelike ? error : y );

				} else {
					Resolve( p, y );
				}

				if ( trace ) {
					currentTrace = trace = null;
				}
			}
		}

		return nodelike ? resolve : {
			promise: promise,

			resolve: function( y ) {
				resolve( false, y );
			},

			reject: function( reason ) {
				resolve( true, reason );
			}
		};
	}

	P.defer = defer;
	function defer() {
		return resolverFor( new Promise(), false );
	}

	P.reject = reject;
	function reject( reason ) {
		var promise = new Promise();
		Reject( promise, reason );
		return promise;
	}

	function Promise() {
		this._state = 0;
		this._value = void 0;
		this._domain = null;
		this._cb = null;
		this._eb = null;
		this._op = 0;
		this._pending = null;
		this._trace = null;
	}

	Promise.prototype.then = function( onFulfilled, onRejected ) {
		var promise = new Promise();

		promise._cb = typeof onFulfilled === "function" ? onFulfilled : null;
		promise._eb = typeof onRejected === "function" ? onRejected : null;

		if ( P.longStackSupport ) {
			promise._trace = getTrace();
		}

		if ( isNodeJS ) {
			promise._domain = process.domain;
		}

		if ( this._state > 0 ) {
			schedule( Then, this, promise );

		} else {
			OnSettled( this, OP_THEN, promise );
		}

		return promise;
	};

	Promise.prototype.done = function( cb, eb ) {
		var p = this;

		if ( cb || eb ) {
			p = p.then( cb, eb );
		}

		p.then( null, DoneEb )._op = OP_END;
	};

	Promise.prototype.fail = function( eb ) {
		return this.then( null, eb );
	};

	Promise.prototype.fin = function( finback ) {
		var self = this;

		function fb() {
			return finback();
		}

		return self.then( fb, fb ).then(function() {
			return self;
		});
	};

	Promise.prototype.spread = function( cb, eb ) {
		return this.then( all ).then(function( args ) {
			return apply.call( cb, void 0, args );
		}, eb);
	};

	Promise.prototype.timeout = function( ms, msg ) {
		var promise = new Promise();

		if ( this._state > 0 ) {
			Propagate( this, promise );

		} else {
			var timedout = false;
			var trace = P.longStackSupport ? getTrace() : null;

			var timeoutId = setTimeout(function() {
				timedout = true;
				currentTrace = trace;
				Reject( promise, new Error(msg || "Timed out after " + ms + " ms") );
				currentTrace = null;
			}, ms);

			OnSettled(this, OP_CALL, function( p ) {
				if ( !timedout ) {
					schedule( Propagate, p, promise );
					clearTimeout( timeoutId );
				}
			});
		}

		return promise;
	};

	Promise.prototype.delay = function( ms ) {
		var promise = new Promise();

		OnSettled(this, OP_CALL, function( p ) {
			if ( p._state === FULFILLED ) {
				setTimeout(function() {
					Propagate( p, promise );
				}, ms);

			} else {
				schedule( Propagate, p, promise );
			}
		});

		return promise;
	};

	Promise.prototype.all = function() {
		return this.then( all );
	};

	Promise.prototype.allSettled = function() {
		return this.then( allSettled );
	};

	Promise.prototype.inspect = function() {
		switch ( this._state ) {
			case FULFILLED: return { state: "fulfilled", value: this._value };
			case REJECTED:  return { state: "rejected", reason: this._value };
			default:		return { state: "pending" };
		}
	};

	Promise.prototype.nodeify = function( nodeback ) {
		if ( nodeback ) {
			this.done(function( value ) {
				nodeback( null, value );
			}, nodeback);
			return void 0;

		} else {
			return this;
		}
	};

	function _allSettled_cb( p, i ) {
		this._value[ i ] = p.inspect();
		if ( ++this._state === 0 ) {
			if ( this._pending === null ) {
				this._state = FULFILLED;
			} else {
				schedule( Fulfill, this, this._value );
			}
		}
	}

	function _all_cb( p, i ) {
		if ( this._state < 0 ) {
			if ( p._state === REJECTED ) {
				this._state = 0;
				if ( this._pending === null ) {
					Propagate( p, this );
				} else {
					schedule( Propagate, p, this );
				}

			} else {
				this._value[ i ] = p._value;
				if ( ++this._state === 0 ) {
					if ( this._pending === null ) {
						this._state = FULFILLED;
					} else {
						schedule( Fulfill, this, this._value );
					}
				}
			}
		}
	}

	var nextIsAllSettled = false;

	P.all = all;
	function all( input ) {
		var promise = new Promise();
		promise._cb = nextIsAllSettled ? _allSettled_cb : _all_cb;
		nextIsAllSettled = false;

		var len = input.length|0;

		promise._state = len ? -len : FULFILLED;
		promise._value = new Array( len );

		for ( var i = 0; i < len && promise._state < 0; ++i ) {
			OnSettled( P(input[i]), i, promise );
		}

		return promise;
	}

	P.allSettled = allSettled;
	function allSettled( input ) {
		nextIsAllSettled = true;
		return all( input );
	}

	P.spread = spread;
	function spread( values, cb, eb ) {
		return all( values ).then(function( args ) {
			return apply.call( cb, void 0, args );
		}, eb);
	}

	P.promised = promised;
	function promised( f ) {
		function onFulfilled( thisAndArgs ) {
			return call.apply( f, thisAndArgs );
		}

		return function() {
			var len = arguments.length;
			var thisAndArgs = new Array( len + 1 );
			thisAndArgs[0] = this;
			for ( var i = 0; i < len; ++i ) {
				thisAndArgs[ i + 1 ] = arguments[ i ];
			}
			return all( thisAndArgs ).then( onFulfilled );
		};
	}

	P.denodeify = denodeify;
	function denodeify( f ) {
		return function() {
			var promise = new Promise();

			var i = arguments.length;
			var args = new Array( i + 1 );
			args[i] = resolverFor( promise, true );
			while ( i-- ) {
				args[i] = arguments[i];
			}

			TryApply( promise, f, this, args );

			return promise;
		};
	}

	function TryApply( p, f, that, args ) {
		try {
			apply.call( f, that, args );

		} catch ( e ) {
			Reject( p, e );
		}
	}

	P.onerror = null;

	P.nextTick = function nextTick( task ) {
		// We don't use .done to avoid P.onerror.
		VOID.then(function() {
			task.call();
		})._op = OP_END;
	};

	var pEndingLine = captureLine();

	return P;
});

}).call(this,require('_process'))
},{"_process":4}],6:[function(require,module,exports){
(function (process){
// vim:ts=4:sts=4:sw=4:
/*!
 *
 * Copyright 2009-2012 Kris Kowal under the terms of the MIT
 * license found at http://github.com/kriskowal/q/raw/master/LICENSE
 *
 * With parts by Tyler Close
 * Copyright 2007-2009 Tyler Close under the terms of the MIT X license found
 * at http://www.opensource.org/licenses/mit-license.html
 * Forked at ref_send.js version: 2009-05-11
 *
 * With parts by Mark Miller
 * Copyright (C) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

(function (definition) {
    "use strict";

    // This file will function properly as a <script> tag, or a module
    // using CommonJS and NodeJS or RequireJS module formats.  In
    // Common/Node/RequireJS, the module exports the Q API and when
    // executed as a simple <script>, it creates a Q global instead.

    // Montage Require
    if (typeof bootstrap === "function") {
        bootstrap("promise", definition);

    // CommonJS
    } else if (typeof exports === "object" && typeof module === "object") {
        module.exports = definition();

    // RequireJS
    } else if (typeof define === "function" && define.amd) {
        define(definition);

    // SES (Secure EcmaScript)
    } else if (typeof ses !== "undefined") {
        if (!ses.ok()) {
            return;
        } else {
            ses.makeQ = definition;
        }

    // <script>
    } else if (typeof window !== "undefined" || typeof self !== "undefined") {
        // Prefer window over self for add-on scripts. Use self for
        // non-windowed contexts.
        var global = typeof window !== "undefined" ? window : self;

        // Get the `window` object, save the previous Q global
        // and initialize Q as a global.
        var previousQ = global.Q;
        global.Q = definition();

        // Add a noConflict function so Q can be removed from the
        // global namespace.
        global.Q.noConflict = function () {
            global.Q = previousQ;
            return this;
        };

    } else {
        throw new Error("This environment was not anticipated by Q. Please file a bug.");
    }

})(function () {
"use strict";

var hasStacks = false;
try {
    throw new Error();
} catch (e) {
    hasStacks = !!e.stack;
}

// All code after this point will be filtered from stack traces reported
// by Q.
var qStartingLine = captureLine();
var qFileName;

// shims

// used for fallback in "allResolved"
var noop = function () {};

// Use the fastest possible means to execute a task in a future turn
// of the event loop.
var nextTick =(function () {
    // linked list of tasks (single, with head node)
    var head = {task: void 0, next: null};
    var tail = head;
    var flushing = false;
    var requestTick = void 0;
    var isNodeJS = false;
    // queue for late tasks, used by unhandled rejection tracking
    var laterQueue = [];

    function flush() {
        /* jshint loopfunc: true */
        var task, domain;

        while (head.next) {
            head = head.next;
            task = head.task;
            head.task = void 0;
            domain = head.domain;

            if (domain) {
                head.domain = void 0;
                domain.enter();
            }
            runSingle(task, domain);

        }
        while (laterQueue.length) {
            task = laterQueue.pop();
            runSingle(task);
        }
        flushing = false;
    }
    // runs a single function in the async queue
    function runSingle(task, domain) {
        try {
            task();

        } catch (e) {
            if (isNodeJS) {
                // In node, uncaught exceptions are considered fatal errors.
                // Re-throw them synchronously to interrupt flushing!

                // Ensure continuation if the uncaught exception is suppressed
                // listening "uncaughtException" events (as domains does).
                // Continue in next event to avoid tick recursion.
                if (domain) {
                    domain.exit();
                }
                setTimeout(flush, 0);
                if (domain) {
                    domain.enter();
                }

                throw e;

            } else {
                // In browsers, uncaught exceptions are not fatal.
                // Re-throw them asynchronously to avoid slow-downs.
                setTimeout(function () {
                    throw e;
                }, 0);
            }
        }

        if (domain) {
            domain.exit();
        }
    }

    nextTick = function (task) {
        tail = tail.next = {
            task: task,
            domain: isNodeJS && process.domain,
            next: null
        };

        if (!flushing) {
            flushing = true;
            requestTick();
        }
    };

    if (typeof process === "object" &&
        process.toString() === "[object process]" && process.nextTick) {
        // Ensure Q is in a real Node environment, with a `process.nextTick`.
        // To see through fake Node environments:
        // * Mocha test runner - exposes a `process` global without a `nextTick`
        // * Browserify - exposes a `process.nexTick` function that uses
        //   `setTimeout`. In this case `setImmediate` is preferred because
        //    it is faster. Browserify's `process.toString()` yields
        //   "[object Object]", while in a real Node environment
        //   `process.nextTick()` yields "[object process]".
        isNodeJS = true;

        requestTick = function () {
            process.nextTick(flush);
        };

    } else if (typeof setImmediate === "function") {
        // In IE10, Node.js 0.9+, or https://github.com/NobleJS/setImmediate
        if (typeof window !== "undefined") {
            requestTick = setImmediate.bind(window, flush);
        } else {
            requestTick = function () {
                setImmediate(flush);
            };
        }

    } else if (typeof MessageChannel !== "undefined") {
        // modern browsers
        // http://www.nonblocking.io/2011/06/windownexttick.html
        var channel = new MessageChannel();
        // At least Safari Version 6.0.5 (8536.30.1) intermittently cannot create
        // working message ports the first time a page loads.
        channel.port1.onmessage = function () {
            requestTick = requestPortTick;
            channel.port1.onmessage = flush;
            flush();
        };
        var requestPortTick = function () {
            // Opera requires us to provide a message payload, regardless of
            // whether we use it.
            channel.port2.postMessage(0);
        };
        requestTick = function () {
            setTimeout(flush, 0);
            requestPortTick();
        };

    } else {
        // old browsers
        requestTick = function () {
            setTimeout(flush, 0);
        };
    }
    // runs a task after all other tasks have been run
    // this is useful for unhandled rejection tracking that needs to happen
    // after all `then`d tasks have been run.
    nextTick.runAfter = function (task) {
        laterQueue.push(task);
        if (!flushing) {
            flushing = true;
            requestTick();
        }
    };
    return nextTick;
})();

// Attempt to make generics safe in the face of downstream
// modifications.
// There is no situation where this is necessary.
// If you need a security guarantee, these primordials need to be
// deeply frozen anyway, and if you don’t need a security guarantee,
// this is just plain paranoid.
// However, this **might** have the nice side-effect of reducing the size of
// the minified code by reducing x.call() to merely x()
// See Mark Miller’s explanation of what this does.
// http://wiki.ecmascript.org/doku.php?id=conventions:safe_meta_programming
var call = Function.call;
function uncurryThis(f) {
    return function () {
        return call.apply(f, arguments);
    };
}
// This is equivalent, but slower:
// uncurryThis = Function_bind.bind(Function_bind.call);
// http://jsperf.com/uncurrythis

var array_slice = uncurryThis(Array.prototype.slice);

var array_reduce = uncurryThis(
    Array.prototype.reduce || function (callback, basis) {
        var index = 0,
            length = this.length;
        // concerning the initial value, if one is not provided
        if (arguments.length === 1) {
            // seek to the first value in the array, accounting
            // for the possibility that is is a sparse array
            do {
                if (index in this) {
                    basis = this[index++];
                    break;
                }
                if (++index >= length) {
                    throw new TypeError();
                }
            } while (1);
        }
        // reduce
        for (; index < length; index++) {
            // account for the possibility that the array is sparse
            if (index in this) {
                basis = callback(basis, this[index], index);
            }
        }
        return basis;
    }
);

var array_indexOf = uncurryThis(
    Array.prototype.indexOf || function (value) {
        // not a very good shim, but good enough for our one use of it
        for (var i = 0; i < this.length; i++) {
            if (this[i] === value) {
                return i;
            }
        }
        return -1;
    }
);

var array_map = uncurryThis(
    Array.prototype.map || function (callback, thisp) {
        var self = this;
        var collect = [];
        array_reduce(self, function (undefined, value, index) {
            collect.push(callback.call(thisp, value, index, self));
        }, void 0);
        return collect;
    }
);

var object_create = Object.create || function (prototype) {
    function Type() { }
    Type.prototype = prototype;
    return new Type();
};

var object_hasOwnProperty = uncurryThis(Object.prototype.hasOwnProperty);

var object_keys = Object.keys || function (object) {
    var keys = [];
    for (var key in object) {
        if (object_hasOwnProperty(object, key)) {
            keys.push(key);
        }
    }
    return keys;
};

var object_toString = uncurryThis(Object.prototype.toString);

function isObject(value) {
    return value === Object(value);
}

// generator related shims

// FIXME: Remove this function once ES6 generators are in SpiderMonkey.
function isStopIteration(exception) {
    return (
        object_toString(exception) === "[object StopIteration]" ||
        exception instanceof QReturnValue
    );
}

// FIXME: Remove this helper and Q.return once ES6 generators are in
// SpiderMonkey.
var QReturnValue;
if (typeof ReturnValue !== "undefined") {
    QReturnValue = ReturnValue;
} else {
    QReturnValue = function (value) {
        this.value = value;
    };
}

// long stack traces

var STACK_JUMP_SEPARATOR = "From previous event:";

function makeStackTraceLong(error, promise) {
    // If possible, transform the error stack trace by removing Node and Q
    // cruft, then concatenating with the stack trace of `promise`. See #57.
    if (hasStacks &&
        promise.stack &&
        typeof error === "object" &&
        error !== null &&
        error.stack &&
        error.stack.indexOf(STACK_JUMP_SEPARATOR) === -1
    ) {
        var stacks = [];
        for (var p = promise; !!p; p = p.source) {
            if (p.stack) {
                stacks.unshift(p.stack);
            }
        }
        stacks.unshift(error.stack);

        var concatedStacks = stacks.join("\n" + STACK_JUMP_SEPARATOR + "\n");
        error.stack = filterStackString(concatedStacks);
    }
}

function filterStackString(stackString) {
    var lines = stackString.split("\n");
    var desiredLines = [];
    for (var i = 0; i < lines.length; ++i) {
        var line = lines[i];

        if (!isInternalFrame(line) && !isNodeFrame(line) && line) {
            desiredLines.push(line);
        }
    }
    return desiredLines.join("\n");
}

function isNodeFrame(stackLine) {
    return stackLine.indexOf("(module.js:") !== -1 ||
           stackLine.indexOf("(node.js:") !== -1;
}

function getFileNameAndLineNumber(stackLine) {
    // Named functions: "at functionName (filename:lineNumber:columnNumber)"
    // In IE10 function name can have spaces ("Anonymous function") O_o
    var attempt1 = /at .+ \((.+):(\d+):(?:\d+)\)$/.exec(stackLine);
    if (attempt1) {
        return [attempt1[1], Number(attempt1[2])];
    }

    // Anonymous functions: "at filename:lineNumber:columnNumber"
    var attempt2 = /at ([^ ]+):(\d+):(?:\d+)$/.exec(stackLine);
    if (attempt2) {
        return [attempt2[1], Number(attempt2[2])];
    }

    // Firefox style: "function@filename:lineNumber or @filename:lineNumber"
    var attempt3 = /.*@(.+):(\d+)$/.exec(stackLine);
    if (attempt3) {
        return [attempt3[1], Number(attempt3[2])];
    }
}

function isInternalFrame(stackLine) {
    var fileNameAndLineNumber = getFileNameAndLineNumber(stackLine);

    if (!fileNameAndLineNumber) {
        return false;
    }

    var fileName = fileNameAndLineNumber[0];
    var lineNumber = fileNameAndLineNumber[1];

    return fileName === qFileName &&
        lineNumber >= qStartingLine &&
        lineNumber <= qEndingLine;
}

// discover own file name and line number range for filtering stack
// traces
function captureLine() {
    if (!hasStacks) {
        return;
    }

    try {
        throw new Error();
    } catch (e) {
        var lines = e.stack.split("\n");
        var firstLine = lines[0].indexOf("@") > 0 ? lines[1] : lines[2];
        var fileNameAndLineNumber = getFileNameAndLineNumber(firstLine);
        if (!fileNameAndLineNumber) {
            return;
        }

        qFileName = fileNameAndLineNumber[0];
        return fileNameAndLineNumber[1];
    }
}

function deprecate(callback, name, alternative) {
    return function () {
        if (typeof console !== "undefined" &&
            typeof console.warn === "function") {
            console.warn(name + " is deprecated, use " + alternative +
                         " instead.", new Error("").stack);
        }
        return callback.apply(callback, arguments);
    };
}

// end of shims
// beginning of real work

/**
 * Constructs a promise for an immediate reference, passes promises through, or
 * coerces promises from different systems.
 * @param value immediate reference or promise
 */
function Q(value) {
    // If the object is already a Promise, return it directly.  This enables
    // the resolve function to both be used to created references from objects,
    // but to tolerably coerce non-promises to promises.
    if (value instanceof Promise) {
        return value;
    }

    // assimilate thenables
    if (isPromiseAlike(value)) {
        return coerce(value);
    } else {
        return fulfill(value);
    }
}
Q.resolve = Q;

/**
 * Performs a task in a future turn of the event loop.
 * @param {Function} task
 */
Q.nextTick = nextTick;

/**
 * Controls whether or not long stack traces will be on
 */
Q.longStackSupport = false;

// enable long stacks if Q_DEBUG is set
if (typeof process === "object" && process && process.env && process.env.Q_DEBUG) {
    Q.longStackSupport = true;
}

/**
 * Constructs a {promise, resolve, reject} object.
 *
 * `resolve` is a callback to invoke with a more resolved value for the
 * promise. To fulfill the promise, invoke `resolve` with any value that is
 * not a thenable. To reject the promise, invoke `resolve` with a rejected
 * thenable, or invoke `reject` with the reason directly. To resolve the
 * promise to another thenable, thus putting it in the same state, invoke
 * `resolve` with that other thenable.
 */
Q.defer = defer;
function defer() {
    // if "messages" is an "Array", that indicates that the promise has not yet
    // been resolved.  If it is "undefined", it has been resolved.  Each
    // element of the messages array is itself an array of complete arguments to
    // forward to the resolved promise.  We coerce the resolution value to a
    // promise using the `resolve` function because it handles both fully
    // non-thenable values and other thenables gracefully.
    var messages = [], progressListeners = [], resolvedPromise;

    var deferred = object_create(defer.prototype);
    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, operands) {
        var args = array_slice(arguments);
        if (messages) {
            messages.push(args);
            if (op === "when" && operands[1]) { // progress operand
                progressListeners.push(operands[1]);
            }
        } else {
            Q.nextTick(function () {
                resolvedPromise.promiseDispatch.apply(resolvedPromise, args);
            });
        }
    };

    // XXX deprecated
    promise.valueOf = function () {
        if (messages) {
            return promise;
        }
        var nearerValue = nearer(resolvedPromise);
        if (isPromise(nearerValue)) {
            resolvedPromise = nearerValue; // shorten chain
        }
        return nearerValue;
    };

    promise.inspect = function () {
        if (!resolvedPromise) {
            return { state: "pending" };
        }
        return resolvedPromise.inspect();
    };

    if (Q.longStackSupport && hasStacks) {
        try {
            throw new Error();
        } catch (e) {
            // NOTE: don't try to use `Error.captureStackTrace` or transfer the
            // accessor around; that causes memory leaks as per GH-111. Just
            // reify the stack trace as a string ASAP.
            //
            // At the same time, cut off the first line; it's always just
            // "[object Promise]\n", as per the `toString`.
            promise.stack = e.stack.substring(e.stack.indexOf("\n") + 1);
        }
    }

    // NOTE: we do the checks for `resolvedPromise` in each method, instead of
    // consolidating them into `become`, since otherwise we'd create new
    // promises with the lines `become(whatever(value))`. See e.g. GH-252.

    function become(newPromise) {
        resolvedPromise = newPromise;
        promise.source = newPromise;

        array_reduce(messages, function (undefined, message) {
            Q.nextTick(function () {
                newPromise.promiseDispatch.apply(newPromise, message);
            });
        }, void 0);

        messages = void 0;
        progressListeners = void 0;
    }

    deferred.promise = promise;
    deferred.resolve = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(Q(value));
    };

    deferred.fulfill = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(fulfill(value));
    };
    deferred.reject = function (reason) {
        if (resolvedPromise) {
            return;
        }

        become(reject(reason));
    };
    deferred.notify = function (progress) {
        if (resolvedPromise) {
            return;
        }

        array_reduce(progressListeners, function (undefined, progressListener) {
            Q.nextTick(function () {
                progressListener(progress);
            });
        }, void 0);
    };

    return deferred;
}

/**
 * Creates a Node-style callback that will resolve or reject the deferred
 * promise.
 * @returns a nodeback
 */
defer.prototype.makeNodeResolver = function () {
    var self = this;
    return function (error, value) {
        if (error) {
            self.reject(error);
        } else if (arguments.length > 2) {
            self.resolve(array_slice(arguments, 1));
        } else {
            self.resolve(value);
        }
    };
};

/**
 * @param resolver {Function} a function that returns nothing and accepts
 * the resolve, reject, and notify functions for a deferred.
 * @returns a promise that may be resolved with the given resolve and reject
 * functions, or rejected by a thrown exception in resolver
 */
Q.Promise = promise; // ES6
Q.promise = promise;
function promise(resolver) {
    if (typeof resolver !== "function") {
        throw new TypeError("resolver must be a function.");
    }
    var deferred = defer();
    try {
        resolver(deferred.resolve, deferred.reject, deferred.notify);
    } catch (reason) {
        deferred.reject(reason);
    }
    return deferred.promise;
}

promise.race = race; // ES6
promise.all = all; // ES6
promise.reject = reject; // ES6
promise.resolve = Q; // ES6

// XXX experimental.  This method is a way to denote that a local value is
// serializable and should be immediately dispatched to a remote upon request,
// instead of passing a reference.
Q.passByCopy = function (object) {
    //freeze(object);
    //passByCopies.set(object, true);
    return object;
};

Promise.prototype.passByCopy = function () {
    //freeze(object);
    //passByCopies.set(object, true);
    return this;
};

/**
 * If two promises eventually fulfill to the same value, promises that value,
 * but otherwise rejects.
 * @param x {Any*}
 * @param y {Any*}
 * @returns {Any*} a promise for x and y if they are the same, but a rejection
 * otherwise.
 *
 */
Q.join = function (x, y) {
    return Q(x).join(y);
};

Promise.prototype.join = function (that) {
    return Q([this, that]).spread(function (x, y) {
        if (x === y) {
            // TODO: "===" should be Object.is or equiv
            return x;
        } else {
            throw new Error("Can't join: not the same: " + x + " " + y);
        }
    });
};

/**
 * Returns a promise for the first of an array of promises to become settled.
 * @param answers {Array[Any*]} promises to race
 * @returns {Any*} the first promise to be settled
 */
Q.race = race;
function race(answerPs) {
    return promise(function (resolve, reject) {
        // Switch to this once we can assume at least ES5
        // answerPs.forEach(function (answerP) {
        //     Q(answerP).then(resolve, reject);
        // });
        // Use this in the meantime
        for (var i = 0, len = answerPs.length; i < len; i++) {
            Q(answerPs[i]).then(resolve, reject);
        }
    });
}

Promise.prototype.race = function () {
    return this.then(Q.race);
};

/**
 * Constructs a Promise with a promise descriptor object and optional fallback
 * function.  The descriptor contains methods like when(rejected), get(name),
 * set(name, value), post(name, args), and delete(name), which all
 * return either a value, a promise for a value, or a rejection.  The fallback
 * accepts the operation name, a resolver, and any further arguments that would
 * have been forwarded to the appropriate method above had a method been
 * provided with the proper name.  The API makes no guarantees about the nature
 * of the returned object, apart from that it is usable whereever promises are
 * bought and sold.
 */
Q.makePromise = Promise;
function Promise(descriptor, fallback, inspect) {
    if (fallback === void 0) {
        fallback = function (op) {
            return reject(new Error(
                "Promise does not support operation: " + op
            ));
        };
    }
    if (inspect === void 0) {
        inspect = function () {
            return {state: "unknown"};
        };
    }

    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, args) {
        var result;
        try {
            if (descriptor[op]) {
                result = descriptor[op].apply(promise, args);
            } else {
                result = fallback.call(promise, op, args);
            }
        } catch (exception) {
            result = reject(exception);
        }
        if (resolve) {
            resolve(result);
        }
    };

    promise.inspect = inspect;

    // XXX deprecated `valueOf` and `exception` support
    if (inspect) {
        var inspected = inspect();
        if (inspected.state === "rejected") {
            promise.exception = inspected.reason;
        }

        promise.valueOf = function () {
            var inspected = inspect();
            if (inspected.state === "pending" ||
                inspected.state === "rejected") {
                return promise;
            }
            return inspected.value;
        };
    }

    return promise;
}

Promise.prototype.toString = function () {
    return "[object Promise]";
};

Promise.prototype.then = function (fulfilled, rejected, progressed) {
    var self = this;
    var deferred = defer();
    var done = false;   // ensure the untrusted promise makes at most a
                        // single call to one of the callbacks

    function _fulfilled(value) {
        try {
            return typeof fulfilled === "function" ? fulfilled(value) : value;
        } catch (exception) {
            return reject(exception);
        }
    }

    function _rejected(exception) {
        if (typeof rejected === "function") {
            makeStackTraceLong(exception, self);
            try {
                return rejected(exception);
            } catch (newException) {
                return reject(newException);
            }
        }
        return reject(exception);
    }

    function _progressed(value) {
        return typeof progressed === "function" ? progressed(value) : value;
    }

    Q.nextTick(function () {
        self.promiseDispatch(function (value) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_fulfilled(value));
        }, "when", [function (exception) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_rejected(exception));
        }]);
    });

    // Progress propagator need to be attached in the current tick.
    self.promiseDispatch(void 0, "when", [void 0, function (value) {
        var newValue;
        var threw = false;
        try {
            newValue = _progressed(value);
        } catch (e) {
            threw = true;
            if (Q.onerror) {
                Q.onerror(e);
            } else {
                throw e;
            }
        }

        if (!threw) {
            deferred.notify(newValue);
        }
    }]);

    return deferred.promise;
};

Q.tap = function (promise, callback) {
    return Q(promise).tap(callback);
};

/**
 * Works almost like "finally", but not called for rejections.
 * Original resolution value is passed through callback unaffected.
 * Callback may return a promise that will be awaited for.
 * @param {Function} callback
 * @returns {Q.Promise}
 * @example
 * doSomething()
 *   .then(...)
 *   .tap(console.log)
 *   .then(...);
 */
Promise.prototype.tap = function (callback) {
    callback = Q(callback);

    return this.then(function (value) {
        return callback.fcall(value).thenResolve(value);
    });
};

/**
 * Registers an observer on a promise.
 *
 * Guarantees:
 *
 * 1. that fulfilled and rejected will be called only once.
 * 2. that either the fulfilled callback or the rejected callback will be
 *    called, but not both.
 * 3. that fulfilled and rejected will not be called in this turn.
 *
 * @param value      promise or immediate reference to observe
 * @param fulfilled  function to be called with the fulfilled value
 * @param rejected   function to be called with the rejection exception
 * @param progressed function to be called on any progress notifications
 * @return promise for the return value from the invoked callback
 */
Q.when = when;
function when(value, fulfilled, rejected, progressed) {
    return Q(value).then(fulfilled, rejected, progressed);
}

Promise.prototype.thenResolve = function (value) {
    return this.then(function () { return value; });
};

Q.thenResolve = function (promise, value) {
    return Q(promise).thenResolve(value);
};

Promise.prototype.thenReject = function (reason) {
    return this.then(function () { throw reason; });
};

Q.thenReject = function (promise, reason) {
    return Q(promise).thenReject(reason);
};

/**
 * If an object is not a promise, it is as "near" as possible.
 * If a promise is rejected, it is as "near" as possible too.
 * If it’s a fulfilled promise, the fulfillment value is nearer.
 * If it’s a deferred promise and the deferred has been resolved, the
 * resolution is "nearer".
 * @param object
 * @returns most resolved (nearest) form of the object
 */

// XXX should we re-do this?
Q.nearer = nearer;
function nearer(value) {
    if (isPromise(value)) {
        var inspected = value.inspect();
        if (inspected.state === "fulfilled") {
            return inspected.value;
        }
    }
    return value;
}

/**
 * @returns whether the given object is a promise.
 * Otherwise it is a fulfilled value.
 */
Q.isPromise = isPromise;
function isPromise(object) {
    return object instanceof Promise;
}

Q.isPromiseAlike = isPromiseAlike;
function isPromiseAlike(object) {
    return isObject(object) && typeof object.then === "function";
}

/**
 * @returns whether the given object is a pending promise, meaning not
 * fulfilled or rejected.
 */
Q.isPending = isPending;
function isPending(object) {
    return isPromise(object) && object.inspect().state === "pending";
}

Promise.prototype.isPending = function () {
    return this.inspect().state === "pending";
};

/**
 * @returns whether the given object is a value or fulfilled
 * promise.
 */
Q.isFulfilled = isFulfilled;
function isFulfilled(object) {
    return !isPromise(object) || object.inspect().state === "fulfilled";
}

Promise.prototype.isFulfilled = function () {
    return this.inspect().state === "fulfilled";
};

/**
 * @returns whether the given object is a rejected promise.
 */
Q.isRejected = isRejected;
function isRejected(object) {
    return isPromise(object) && object.inspect().state === "rejected";
}

Promise.prototype.isRejected = function () {
    return this.inspect().state === "rejected";
};

//// BEGIN UNHANDLED REJECTION TRACKING

// This promise library consumes exceptions thrown in handlers so they can be
// handled by a subsequent promise.  The exceptions get added to this array when
// they are created, and removed when they are handled.  Note that in ES6 or
// shimmed environments, this would naturally be a `Set`.
var unhandledReasons = [];
var unhandledRejections = [];
var reportedUnhandledRejections = [];
var trackUnhandledRejections = true;

function resetUnhandledRejections() {
    unhandledReasons.length = 0;
    unhandledRejections.length = 0;

    if (!trackUnhandledRejections) {
        trackUnhandledRejections = true;
    }
}

function trackRejection(promise, reason) {
    if (!trackUnhandledRejections) {
        return;
    }
    if (typeof process === "object" && typeof process.emit === "function") {
        Q.nextTick.runAfter(function () {
            if (array_indexOf(unhandledRejections, promise) !== -1) {
                process.emit("unhandledRejection", reason, promise);
                reportedUnhandledRejections.push(promise);
            }
        });
    }

    unhandledRejections.push(promise);
    if (reason && typeof reason.stack !== "undefined") {
        unhandledReasons.push(reason.stack);
    } else {
        unhandledReasons.push("(no stack) " + reason);
    }
}

function untrackRejection(promise) {
    if (!trackUnhandledRejections) {
        return;
    }

    var at = array_indexOf(unhandledRejections, promise);
    if (at !== -1) {
        if (typeof process === "object" && typeof process.emit === "function") {
            Q.nextTick.runAfter(function () {
                var atReport = array_indexOf(reportedUnhandledRejections, promise);
                if (atReport !== -1) {
                    process.emit("rejectionHandled", unhandledReasons[at], promise);
                    reportedUnhandledRejections.splice(atReport, 1);
                }
            });
        }
        unhandledRejections.splice(at, 1);
        unhandledReasons.splice(at, 1);
    }
}

Q.resetUnhandledRejections = resetUnhandledRejections;

Q.getUnhandledReasons = function () {
    // Make a copy so that consumers can't interfere with our internal state.
    return unhandledReasons.slice();
};

Q.stopUnhandledRejectionTracking = function () {
    resetUnhandledRejections();
    trackUnhandledRejections = false;
};

resetUnhandledRejections();

//// END UNHANDLED REJECTION TRACKING

/**
 * Constructs a rejected promise.
 * @param reason value describing the failure
 */
Q.reject = reject;
function reject(reason) {
    var rejection = Promise({
        "when": function (rejected) {
            // note that the error has been handled
            if (rejected) {
                untrackRejection(this);
            }
            return rejected ? rejected(reason) : this;
        }
    }, function fallback() {
        return this;
    }, function inspect() {
        return { state: "rejected", reason: reason };
    });

    // Note that the reason has not been handled.
    trackRejection(rejection, reason);

    return rejection;
}

/**
 * Constructs a fulfilled promise for an immediate reference.
 * @param value immediate reference
 */
Q.fulfill = fulfill;
function fulfill(value) {
    return Promise({
        "when": function () {
            return value;
        },
        "get": function (name) {
            return value[name];
        },
        "set": function (name, rhs) {
            value[name] = rhs;
        },
        "delete": function (name) {
            delete value[name];
        },
        "post": function (name, args) {
            // Mark Miller proposes that post with no name should apply a
            // promised function.
            if (name === null || name === void 0) {
                return value.apply(void 0, args);
            } else {
                return value[name].apply(value, args);
            }
        },
        "apply": function (thisp, args) {
            return value.apply(thisp, args);
        },
        "keys": function () {
            return object_keys(value);
        }
    }, void 0, function inspect() {
        return { state: "fulfilled", value: value };
    });
}

/**
 * Converts thenables to Q promises.
 * @param promise thenable promise
 * @returns a Q promise
 */
function coerce(promise) {
    var deferred = defer();
    Q.nextTick(function () {
        try {
            promise.then(deferred.resolve, deferred.reject, deferred.notify);
        } catch (exception) {
            deferred.reject(exception);
        }
    });
    return deferred.promise;
}

/**
 * Annotates an object such that it will never be
 * transferred away from this process over any promise
 * communication channel.
 * @param object
 * @returns promise a wrapping of that object that
 * additionally responds to the "isDef" message
 * without a rejection.
 */
Q.master = master;
function master(object) {
    return Promise({
        "isDef": function () {}
    }, function fallback(op, args) {
        return dispatch(object, op, args);
    }, function () {
        return Q(object).inspect();
    });
}

/**
 * Spreads the values of a promised array of arguments into the
 * fulfillment callback.
 * @param fulfilled callback that receives variadic arguments from the
 * promised array
 * @param rejected callback that receives the exception if the promise
 * is rejected.
 * @returns a promise for the return value or thrown exception of
 * either callback.
 */
Q.spread = spread;
function spread(value, fulfilled, rejected) {
    return Q(value).spread(fulfilled, rejected);
}

Promise.prototype.spread = function (fulfilled, rejected) {
    return this.all().then(function (array) {
        return fulfilled.apply(void 0, array);
    }, rejected);
};

/**
 * The async function is a decorator for generator functions, turning
 * them into asynchronous generators.  Although generators are only part
 * of the newest ECMAScript 6 drafts, this code does not cause syntax
 * errors in older engines.  This code should continue to work and will
 * in fact improve over time as the language improves.
 *
 * ES6 generators are currently part of V8 version 3.19 with the
 * --harmony-generators runtime flag enabled.  SpiderMonkey has had them
 * for longer, but under an older Python-inspired form.  This function
 * works on both kinds of generators.
 *
 * Decorates a generator function such that:
 *  - it may yield promises
 *  - execution will continue when that promise is fulfilled
 *  - the value of the yield expression will be the fulfilled value
 *  - it returns a promise for the return value (when the generator
 *    stops iterating)
 *  - the decorated function returns a promise for the return value
 *    of the generator or the first rejected promise among those
 *    yielded.
 *  - if an error is thrown in the generator, it propagates through
 *    every following yield until it is caught, or until it escapes
 *    the generator function altogether, and is translated into a
 *    rejection for the promise returned by the decorated generator.
 */
Q.async = async;
function async(makeGenerator) {
    return function () {
        // when verb is "send", arg is a value
        // when verb is "throw", arg is an exception
        function continuer(verb, arg) {
            var result;

            // Until V8 3.19 / Chromium 29 is released, SpiderMonkey is the only
            // engine that has a deployed base of browsers that support generators.
            // However, SM's generators use the Python-inspired semantics of
            // outdated ES6 drafts.  We would like to support ES6, but we'd also
            // like to make it possible to use generators in deployed browsers, so
            // we also support Python-style generators.  At some point we can remove
            // this block.

            if (typeof StopIteration === "undefined") {
                // ES6 Generators
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    return reject(exception);
                }
                if (result.done) {
                    return Q(result.value);
                } else {
                    return when(result.value, callback, errback);
                }
            } else {
                // SpiderMonkey Generators
                // FIXME: Remove this case when SM does ES6 generators.
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    if (isStopIteration(exception)) {
                        return Q(exception.value);
                    } else {
                        return reject(exception);
                    }
                }
                return when(result, callback, errback);
            }
        }
        var generator = makeGenerator.apply(this, arguments);
        var callback = continuer.bind(continuer, "next");
        var errback = continuer.bind(continuer, "throw");
        return callback();
    };
}

/**
 * The spawn function is a small wrapper around async that immediately
 * calls the generator and also ends the promise chain, so that any
 * unhandled errors are thrown instead of forwarded to the error
 * handler. This is useful because it's extremely common to run
 * generators at the top-level to work with libraries.
 */
Q.spawn = spawn;
function spawn(makeGenerator) {
    Q.done(Q.async(makeGenerator)());
}

// FIXME: Remove this interface once ES6 generators are in SpiderMonkey.
/**
 * Throws a ReturnValue exception to stop an asynchronous generator.
 *
 * This interface is a stop-gap measure to support generator return
 * values in older Firefox/SpiderMonkey.  In browsers that support ES6
 * generators like Chromium 29, just use "return" in your generator
 * functions.
 *
 * @param value the return value for the surrounding generator
 * @throws ReturnValue exception with the value.
 * @example
 * // ES6 style
 * Q.async(function* () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      return foo + bar;
 * })
 * // Older SpiderMonkey style
 * Q.async(function () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      Q.return(foo + bar);
 * })
 */
Q["return"] = _return;
function _return(value) {
    throw new QReturnValue(value);
}

/**
 * The promised function decorator ensures that any promise arguments
 * are settled and passed as values (`this` is also settled and passed
 * as a value).  It will also ensure that the result of a function is
 * always a promise.
 *
 * @example
 * var add = Q.promised(function (a, b) {
 *     return a + b;
 * });
 * add(Q(a), Q(B));
 *
 * @param {function} callback The function to decorate
 * @returns {function} a function that has been decorated.
 */
Q.promised = promised;
function promised(callback) {
    return function () {
        return spread([this, all(arguments)], function (self, args) {
            return callback.apply(self, args);
        });
    };
}

/**
 * sends a message to a value in a future turn
 * @param object* the recipient
 * @param op the name of the message operation, e.g., "when",
 * @param args further arguments to be forwarded to the operation
 * @returns result {Promise} a promise for the result of the operation
 */
Q.dispatch = dispatch;
function dispatch(object, op, args) {
    return Q(object).dispatch(op, args);
}

Promise.prototype.dispatch = function (op, args) {
    var self = this;
    var deferred = defer();
    Q.nextTick(function () {
        self.promiseDispatch(deferred.resolve, op, args);
    });
    return deferred.promise;
};

/**
 * Gets the value of a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to get
 * @return promise for the property value
 */
Q.get = function (object, key) {
    return Q(object).dispatch("get", [key]);
};

Promise.prototype.get = function (key) {
    return this.dispatch("get", [key]);
};

/**
 * Sets the value of a property in a future turn.
 * @param object    promise or immediate reference for object object
 * @param name      name of property to set
 * @param value     new value of property
 * @return promise for the return value
 */
Q.set = function (object, key, value) {
    return Q(object).dispatch("set", [key, value]);
};

Promise.prototype.set = function (key, value) {
    return this.dispatch("set", [key, value]);
};

/**
 * Deletes a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to delete
 * @return promise for the return value
 */
Q.del = // XXX legacy
Q["delete"] = function (object, key) {
    return Q(object).dispatch("delete", [key]);
};

Promise.prototype.del = // XXX legacy
Promise.prototype["delete"] = function (key) {
    return this.dispatch("delete", [key]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param value     a value to post, typically an array of
 *                  invocation arguments for promises that
 *                  are ultimately backed with `resolve` values,
 *                  as opposed to those backed with URLs
 *                  wherein the posted value can be any
 *                  JSON serializable object.
 * @return promise for the return value
 */
// bound locally because it is used by other methods
Q.mapply = // XXX As proposed by "Redsandro"
Q.post = function (object, name, args) {
    return Q(object).dispatch("post", [name, args]);
};

Promise.prototype.mapply = // XXX As proposed by "Redsandro"
Promise.prototype.post = function (name, args) {
    return this.dispatch("post", [name, args]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param ...args   array of invocation arguments
 * @return promise for the return value
 */
Q.send = // XXX Mark Miller's proposed parlance
Q.mcall = // XXX As proposed by "Redsandro"
Q.invoke = function (object, name /*...args*/) {
    return Q(object).dispatch("post", [name, array_slice(arguments, 2)]);
};

Promise.prototype.send = // XXX Mark Miller's proposed parlance
Promise.prototype.mcall = // XXX As proposed by "Redsandro"
Promise.prototype.invoke = function (name /*...args*/) {
    return this.dispatch("post", [name, array_slice(arguments, 1)]);
};

/**
 * Applies the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param args      array of application arguments
 */
Q.fapply = function (object, args) {
    return Q(object).dispatch("apply", [void 0, args]);
};

Promise.prototype.fapply = function (args) {
    return this.dispatch("apply", [void 0, args]);
};

/**
 * Calls the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q["try"] =
Q.fcall = function (object /* ...args*/) {
    return Q(object).dispatch("apply", [void 0, array_slice(arguments, 1)]);
};

Promise.prototype.fcall = function (/*...args*/) {
    return this.dispatch("apply", [void 0, array_slice(arguments)]);
};

/**
 * Binds the promised function, transforming return values into a fulfilled
 * promise and thrown errors into a rejected one.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q.fbind = function (object /*...args*/) {
    var promise = Q(object);
    var args = array_slice(arguments, 1);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};
Promise.prototype.fbind = function (/*...args*/) {
    var promise = this;
    var args = array_slice(arguments);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};

/**
 * Requests the names of the owned properties of a promised
 * object in a future turn.
 * @param object    promise or immediate reference for target object
 * @return promise for the keys of the eventually settled object
 */
Q.keys = function (object) {
    return Q(object).dispatch("keys", []);
};

Promise.prototype.keys = function () {
    return this.dispatch("keys", []);
};

/**
 * Turns an array of promises into a promise for an array.  If any of
 * the promises gets rejected, the whole array is rejected immediately.
 * @param {Array*} an array (or promise for an array) of values (or
 * promises for values)
 * @returns a promise for an array of the corresponding values
 */
// By Mark Miller
// http://wiki.ecmascript.org/doku.php?id=strawman:concurrency&rev=1308776521#allfulfilled
Q.all = all;
function all(promises) {
    return when(promises, function (promises) {
        var pendingCount = 0;
        var deferred = defer();
        array_reduce(promises, function (undefined, promise, index) {
            var snapshot;
            if (
                isPromise(promise) &&
                (snapshot = promise.inspect()).state === "fulfilled"
            ) {
                promises[index] = snapshot.value;
            } else {
                ++pendingCount;
                when(
                    promise,
                    function (value) {
                        promises[index] = value;
                        if (--pendingCount === 0) {
                            deferred.resolve(promises);
                        }
                    },
                    deferred.reject,
                    function (progress) {
                        deferred.notify({ index: index, value: progress });
                    }
                );
            }
        }, void 0);
        if (pendingCount === 0) {
            deferred.resolve(promises);
        }
        return deferred.promise;
    });
}

Promise.prototype.all = function () {
    return all(this);
};

/**
 * Returns the first resolved promise of an array. Prior rejected promises are
 * ignored.  Rejects only if all promises are rejected.
 * @param {Array*} an array containing values or promises for values
 * @returns a promise fulfilled with the value of the first resolved promise,
 * or a rejected promise if all promises are rejected.
 */
Q.any = any;

function any(promises) {
    if (promises.length === 0) {
        return Q.resolve();
    }

    var deferred = Q.defer();
    var pendingCount = 0;
    array_reduce(promises, function (prev, current, index) {
        var promise = promises[index];

        pendingCount++;

        when(promise, onFulfilled, onRejected, onProgress);
        function onFulfilled(result) {
            deferred.resolve(result);
        }
        function onRejected() {
            pendingCount--;
            if (pendingCount === 0) {
                deferred.reject(new Error(
                    "Can't get fulfillment value from any promise, all " +
                    "promises were rejected."
                ));
            }
        }
        function onProgress(progress) {
            deferred.notify({
                index: index,
                value: progress
            });
        }
    }, undefined);

    return deferred.promise;
}

Promise.prototype.any = function () {
    return any(this);
};

/**
 * Waits for all promises to be settled, either fulfilled or
 * rejected.  This is distinct from `all` since that would stop
 * waiting at the first rejection.  The promise returned by
 * `allResolved` will never be rejected.
 * @param promises a promise for an array (or an array) of promises
 * (or values)
 * @return a promise for an array of promises
 */
Q.allResolved = deprecate(allResolved, "allResolved", "allSettled");
function allResolved(promises) {
    return when(promises, function (promises) {
        promises = array_map(promises, Q);
        return when(all(array_map(promises, function (promise) {
            return when(promise, noop, noop);
        })), function () {
            return promises;
        });
    });
}

Promise.prototype.allResolved = function () {
    return allResolved(this);
};

/**
 * @see Promise#allSettled
 */
Q.allSettled = allSettled;
function allSettled(promises) {
    return Q(promises).allSettled();
}

/**
 * Turns an array of promises into a promise for an array of their states (as
 * returned by `inspect`) when they have all settled.
 * @param {Array[Any*]} values an array (or promise for an array) of values (or
 * promises for values)
 * @returns {Array[State]} an array of states for the respective values.
 */
Promise.prototype.allSettled = function () {
    return this.then(function (promises) {
        return all(array_map(promises, function (promise) {
            promise = Q(promise);
            function regardless() {
                return promise.inspect();
            }
            return promise.then(regardless, regardless);
        }));
    });
};

/**
 * Captures the failure of a promise, giving an oportunity to recover
 * with a callback.  If the given promise is fulfilled, the returned
 * promise is fulfilled.
 * @param {Any*} promise for something
 * @param {Function} callback to fulfill the returned promise if the
 * given promise is rejected
 * @returns a promise for the return value of the callback
 */
Q.fail = // XXX legacy
Q["catch"] = function (object, rejected) {
    return Q(object).then(void 0, rejected);
};

Promise.prototype.fail = // XXX legacy
Promise.prototype["catch"] = function (rejected) {
    return this.then(void 0, rejected);
};

/**
 * Attaches a listener that can respond to progress notifications from a
 * promise's originating deferred. This listener receives the exact arguments
 * passed to ``deferred.notify``.
 * @param {Any*} promise for something
 * @param {Function} callback to receive any progress notifications
 * @returns the given promise, unchanged
 */
Q.progress = progress;
function progress(object, progressed) {
    return Q(object).then(void 0, void 0, progressed);
}

Promise.prototype.progress = function (progressed) {
    return this.then(void 0, void 0, progressed);
};

/**
 * Provides an opportunity to observe the settling of a promise,
 * regardless of whether the promise is fulfilled or rejected.  Forwards
 * the resolution to the returned promise when the callback is done.
 * The callback can return a promise to defer completion.
 * @param {Any*} promise
 * @param {Function} callback to observe the resolution of the given
 * promise, takes no arguments.
 * @returns a promise for the resolution of the given promise when
 * ``fin`` is done.
 */
Q.fin = // XXX legacy
Q["finally"] = function (object, callback) {
    return Q(object)["finally"](callback);
};

Promise.prototype.fin = // XXX legacy
Promise.prototype["finally"] = function (callback) {
    callback = Q(callback);
    return this.then(function (value) {
        return callback.fcall().then(function () {
            return value;
        });
    }, function (reason) {
        // TODO attempt to recycle the rejection with "this".
        return callback.fcall().then(function () {
            throw reason;
        });
    });
};

/**
 * Terminates a chain of promises, forcing rejections to be
 * thrown as exceptions.
 * @param {Any*} promise at the end of a chain of promises
 * @returns nothing
 */
Q.done = function (object, fulfilled, rejected, progress) {
    return Q(object).done(fulfilled, rejected, progress);
};

Promise.prototype.done = function (fulfilled, rejected, progress) {
    var onUnhandledError = function (error) {
        // forward to a future turn so that ``when``
        // does not catch it and turn it into a rejection.
        Q.nextTick(function () {
            makeStackTraceLong(error, promise);
            if (Q.onerror) {
                Q.onerror(error);
            } else {
                throw error;
            }
        });
    };

    // Avoid unnecessary `nextTick`ing via an unnecessary `when`.
    var promise = fulfilled || rejected || progress ?
        this.then(fulfilled, rejected, progress) :
        this;

    if (typeof process === "object" && process && process.domain) {
        onUnhandledError = process.domain.bind(onUnhandledError);
    }

    promise.then(void 0, onUnhandledError);
};

/**
 * Causes a promise to be rejected if it does not get fulfilled before
 * some milliseconds time out.
 * @param {Any*} promise
 * @param {Number} milliseconds timeout
 * @param {Any*} custom error message or Error object (optional)
 * @returns a promise for the resolution of the given promise if it is
 * fulfilled before the timeout, otherwise rejected.
 */
Q.timeout = function (object, ms, error) {
    return Q(object).timeout(ms, error);
};

Promise.prototype.timeout = function (ms, error) {
    var deferred = defer();
    var timeoutId = setTimeout(function () {
        if (!error || "string" === typeof error) {
            error = new Error(error || "Timed out after " + ms + " ms");
            error.code = "ETIMEDOUT";
        }
        deferred.reject(error);
    }, ms);

    this.then(function (value) {
        clearTimeout(timeoutId);
        deferred.resolve(value);
    }, function (exception) {
        clearTimeout(timeoutId);
        deferred.reject(exception);
    }, deferred.notify);

    return deferred.promise;
};

/**
 * Returns a promise for the given value (or promised value), some
 * milliseconds after it resolved. Passes rejections immediately.
 * @param {Any*} promise
 * @param {Number} milliseconds
 * @returns a promise for the resolution of the given promise after milliseconds
 * time has elapsed since the resolution of the given promise.
 * If the given promise rejects, that is passed immediately.
 */
Q.delay = function (object, timeout) {
    if (timeout === void 0) {
        timeout = object;
        object = void 0;
    }
    return Q(object).delay(timeout);
};

Promise.prototype.delay = function (timeout) {
    return this.then(function (value) {
        var deferred = defer();
        setTimeout(function () {
            deferred.resolve(value);
        }, timeout);
        return deferred.promise;
    });
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided as an array, and returns a promise.
 *
 *      Q.nfapply(FS.readFile, [__filename])
 *      .then(function (content) {
 *      })
 *
 */
Q.nfapply = function (callback, args) {
    return Q(callback).nfapply(args);
};

Promise.prototype.nfapply = function (args) {
    var deferred = defer();
    var nodeArgs = array_slice(args);
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided individually, and returns a promise.
 * @example
 * Q.nfcall(FS.readFile, __filename)
 * .then(function (content) {
 * })
 *
 */
Q.nfcall = function (callback /*...args*/) {
    var args = array_slice(arguments, 1);
    return Q(callback).nfapply(args);
};

Promise.prototype.nfcall = function (/*...args*/) {
    var nodeArgs = array_slice(arguments);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Wraps a NodeJS continuation passing function and returns an equivalent
 * version that returns a promise.
 * @example
 * Q.nfbind(FS.readFile, __filename)("utf-8")
 * .then(console.log)
 * .done()
 */
Q.nfbind =
Q.denodeify = function (callback /*...args*/) {
    var baseArgs = array_slice(arguments, 1);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        Q(callback).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nfbind =
Promise.prototype.denodeify = function (/*...args*/) {
    var args = array_slice(arguments);
    args.unshift(this);
    return Q.denodeify.apply(void 0, args);
};

Q.nbind = function (callback, thisp /*...args*/) {
    var baseArgs = array_slice(arguments, 2);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        function bound() {
            return callback.apply(thisp, arguments);
        }
        Q(bound).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nbind = function (/*thisp, ...args*/) {
    var args = array_slice(arguments, 0);
    args.unshift(this);
    return Q.nbind.apply(void 0, args);
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback with a given array of arguments, plus a provided callback.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param {Array} args arguments to pass to the method; the callback
 * will be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nmapply = // XXX As proposed by "Redsandro"
Q.npost = function (object, name, args) {
    return Q(object).npost(name, args);
};

Promise.prototype.nmapply = // XXX As proposed by "Redsandro"
Promise.prototype.npost = function (name, args) {
    var nodeArgs = array_slice(args || []);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback, forwarding the given variadic arguments, plus a provided
 * callback argument.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param ...args arguments to pass to the method; the callback will
 * be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nsend = // XXX Based on Mark Miller's proposed "send"
Q.nmcall = // XXX Based on "Redsandro's" proposal
Q.ninvoke = function (object, name /*...args*/) {
    var nodeArgs = array_slice(arguments, 2);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    Q(object).dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

Promise.prototype.nsend = // XXX Based on Mark Miller's proposed "send"
Promise.prototype.nmcall = // XXX Based on "Redsandro's" proposal
Promise.prototype.ninvoke = function (name /*...args*/) {
    var nodeArgs = array_slice(arguments, 1);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * If a function would like to support both Node continuation-passing-style and
 * promise-returning-style, it can end its internal promise chain with
 * `nodeify(nodeback)`, forwarding the optional nodeback argument.  If the user
 * elects to use a nodeback, the result will be sent there.  If they do not
 * pass a nodeback, they will receive the result promise.
 * @param object a result (or a promise for a result)
 * @param {Function} nodeback a Node.js-style callback
 * @returns either the promise or nothing
 */
Q.nodeify = nodeify;
function nodeify(object, nodeback) {
    return Q(object).nodeify(nodeback);
}

Promise.prototype.nodeify = function (nodeback) {
    if (nodeback) {
        this.then(function (value) {
            Q.nextTick(function () {
                nodeback(null, value);
            });
        }, function (error) {
            Q.nextTick(function () {
                nodeback(error);
            });
        });
    } else {
        return this;
    }
};

Q.noConflict = function() {
    throw new Error("Q.noConflict only works when Q is used as a global");
};

// All code before this point will be filtered from stack traces.
var qEndingLine = captureLine();

return Q;

});

}).call(this,require('_process'))
},{"_process":4}],7:[function(require,module,exports){
/*
  CanvasImage Class
  Class that wraps the html image element and canvas.
  It also simplifies some of the canvas context manipulation
  with a set of helper functions.
*/
var CanvasImage = function (image,width,height) {
    this.canvas  = document.createElement('canvas');
    this.context = this.canvas.getContext('2d');

    // document.body.appendChild(this.canvas);
    // console.log(image.src, image.complete);

    this.width  = this.canvas.width  = width || image.width;
    this.height = this.canvas.height = height || image.height;

    this.context.drawImage(image, 0, 0, this.width, this.height);
};

CanvasImage.prototype.clear = function () {
    this.context.clearRect(0, 0, this.width, this.height);
};

CanvasImage.prototype.update = function (imageData) {
    this.context.putImageData(imageData, 0, 0);
};

CanvasImage.prototype.getPixelCount = function () {
    return this.width * this.height;
};

CanvasImage.prototype.getImageData = function () {
    return this.context.getImageData(0, 0, this.width, this.height);
};

CanvasImage.prototype.removeCanvas = function () {
    this.canvas.parentNode.removeChild(this.canvas);
};

module.exports = CanvasImage;

},{}],8:[function(require,module,exports){
/* @flow weak */
var events = require('events'),
    defer = require('p-promise').defer
    CanvasImage = require('./canvas_image');


function ColorExtractor(workerPath, maxWorkers) {
  this.workerPath = workerPath || 'worker.js';
  this.maxWorkers = maxWorkers || 4;
  events.EventEmitter.call(this);
  this.idleWorkers = [];
  this.activeWorkers = [];
  this.workerRequests = [];
}

ColorExtractor.prototype.checkOutWorker = function() {
  var worker = this.idleWorkers.shift();
  if (!worker && this.activeWorkers.length < this.maxWorkers) {
    // Make a new worker
    worker = new Worker(this.workerPath);
    this.activeWorkers.push(worker);
    return Promise.resolve(worker);
  }
  else {
    var deferred = defer();
    this.workerRequests.push(deferred);
    return deferred.promise;
  }
}

ColorExtractor.prototype.checkInWorker = function(worker) {
  // Remove worker from active workers list
  this.activeWorkers = this.activeWorkers.filter(function(w) {
    return w !== worker;
  });

  // If a worker request is queued, dispatch
  var deferred = this.workerRequests.shift();
  if (deferred) {
    deferred.resolve(worker);
  }
  // Otherwise move this worker to idle
  else {
    this.idleWorkers.push(worker);
  }
}

/**
 * @param imageSource - Any CanvasImageSource - https://developer.mozilla.org/en-US/docs/Web/API/CanvasImageSource
 */
ColorExtractor.prototype.extract = function(imageSource) {
  return this.checkOutWorker().then(function(worker) {
    var imageDataBuffer = new CanvasImage(imageSource, 100, 100).getImageData().data.buffer;

    var deferredExtraction = defer();
    worker.postMessage({command: 'extract', imageDataBuffer: imageDataBuffer}, [imageDataBuffer]);
    worker.onmessage = function(e) {
      this.checkInWorker(worker);
      deferredExtraction.resolve(e.data);
    }.bind(this);
    return deferredExtraction.promise;
  }.bind(this));
}



if (typeof exports === "object" && typeof module === "object") {
  module.exports = ColorExtractor;
}
else if (typeof window !== "undefined") {
  window.ColorExtractor = ColorExtractor;
}

},{"./canvas_image":7,"events":3,"p-promise":5}],9:[function(require,module,exports){
module.exports = require('./src/index.js');

},{"./src/index.js":11}],10:[function(require,module,exports){
arguments[4][6][0].apply(exports,arguments)
},{"_process":4,"dup":6}],11:[function(require,module,exports){
var Q = require('q');

function fetchBlob(src) {
  var deferred = Q.defer();
  var xhr = new XMLHttpRequest();

  xhr.open('GET', src, true);
  xhr.responseType = 'blob';

  xhr.addEventListener('load', function(evt) {
    if (this.status == 200) {
      var blob = new Blob([this.response], {type: 'image/png'});
      deferred.resolve(blob);
    }
    else {
      deferred.reject(this.status);
    }
  });
  xhr.addEventListener('error', function(err) {
    deferred.reject(err);
  });
  xhr.addEventListener('abort', function(err) {
    deferred.reject(err);
  });
  xhr.addEventListener('progress', function(evt) {
    deferred.notify({ loaded: evt.loaded, total: evt.total});
  });

  xhr.send();

  return deferred.promise;
}

function fetch(src) {
  return fetchBlob(src)
    .then(function(blob) {
      var img = document.createElement('img');
      img.onload = function(e) {
        window.URL.revokeObjectURL(img.src); // Clean up after yourself.
      };
      img.src = window.URL.createObjectURL(blob);
      return img;
    });
}

module.exports = {
  fetch: fetch,
  fetchBlob: fetchBlob
};

},{"q":10}]},{},[1]);
