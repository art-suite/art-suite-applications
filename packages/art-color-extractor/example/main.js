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
var MediaItem = React.createClass({
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
      return (<img src={this.state.imageUrl} ref="image"></img>);
    }
    else {
      return false;
    }
  },


  renderVibrant: function(colorInfo) {
    var vibrant = colorInfo.vibrant;
    if (vibrant) {
      return (
        <figure className='vibrant'>
          <div>
            {Object.keys(vibrant).map(function(colorLabel) {
              return (<div><span className='vibrant-color' style={{ backgroundColor: 'rgb(' + vibrant[colorLabel].join(',') + ')'}}></span>{colorLabel}</div>);
            }.bind(this))}
          </div>
          <figcaption>Vibrant labeled colors</figcaption>
        </figure>
      );
    }
    else {
      return false;
    }
  },


  renderThiefColor: function(colorInfo) {
    if (colorInfo && colorInfo.colorThief && colorInfo.colorThief.dominantColor) {
      return (
        <figure>
          <span className='thief-single-color' style={{backgroundColor: toCSSColor(colorInfo.colorThief.dominantColor)}}></span>
          <figcaption>ColorThief single color</figcaption>
        </figure>
      );
    }
    else { return false; }
  },

  renderThiefPalette: function(colorInfo) {
    if (colorInfo && colorInfo.colorThief && colorInfo.colorThief.palette) {
      console.log('rendering colorthiefpalette');
      return (
        <figure className='thief-palette'>
          <div>
            {colorInfo.colorThief.palette.map(function(color) {
              return (<span className='thief-palette-color' style={{ backgroundColor: toCSSColor(color)}}></span>);
            })}
          </div>
          <figcaption>ColorThief palette</figcaption>
        </figure>
      );
    }
    else { return false; }
  },

  renderGradifyDominantColor: function(colorInfo) {
    if (colorInfo && colorInfo.gradify && colorInfo.gradify.dominantColor) {
      var dominantCSSColor = toCSSColor(colorInfo.gradify.dominantColor)
      return (
        <figure>
          <span className='gradify-dominant-color' style={{backgroundColor: dominantCSSColor}}></span>
          <figcaption>Gradify dominant color</figcaption>
        </figure>
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
        <figure>
          <span className='gradify-gradients' style={{backgroundImage: cssGradientsValue}}></span>
          <figcaption>Gradify gradients</figcaption>
        </figure>
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
      return (<span>
        {this.renderThiefColor(this.props.colorInfo)}
        {this.renderThiefPalette(this.props.colorInfo)}
        {this.renderVibrant(this.props.colorInfo)}
        {this.renderGradifyDominantColor(this.props.colorInfo)}
        {this.renderGradifyGradients(this.props.colorInfo)}
      </span>);
    }
    else {
      return false;
    }
  },

  render: function() {
    return (
      <div className='media-item'>
        <header>{this.props.id}</header>
        {this.renderImage()}
        {this.renderColorInfo()}
      </div>
    );
  }
});


var App = React.createClass({
  getInitialState: function() {
    return {
      colorInfo: {},
      extractions: {},
      extractor: new ColorExtractor(4),
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
      <div>
        <header><h1>ColorInfo Demo</h1></header>
        <dl>
          <dt>Media Records</dt>
          <dd>
            <progress value={loadedCount} max={totalCount}></progress>
          </dd>
          <dd>
            {mediaCountLoaded ? (loadedCount + ' / ' + totalCount) : ''}
          </dd>
        </dl>
        <div>
          { this.state.medias.map(function(media) {
              return (<MediaItem colorInfo={this.state.colorInfo[media.id]} onImageLoad={this.imageLoaded} photoUrl={media.get('mediaPhotoUrl')} id={media.id} key={media.id}/>);
            }.bind(this))
          }
        </div>
      </div>
    );
  }
});

React.render(
  <App/>,
  document.body
);
