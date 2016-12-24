###
TODO:
  In testing, extractColors spends about 90% of its time in Vibrant. I think 'quantize' is the problem:

  a) SPEED: I suspect quantize could be significantly optimized. It uses an array-of-arrays datastructure
    which is generally not the fastest option for JavaScript. Instead, if we wrote it to
    work directly with the Uint8ClampedArray pixel data, I suspect it would be significantly faster.

    We should be able to achieve near-c speeds.

  b) BUGFIX: When running on grayscale images, quantize produces vibrant colors!

  If we rewrite quantize, some notes:

    - https://en.wikipedia.org/wiki/Color_quantization
    - LAB color-space, or at least HSB, is probably better than RGB, but at what cost?
    - Octrees?
    - My Master's Thesis Algorithm!

  SBD Master's Thesis Applied - spacial-color-clustering

    0) convert pixels to LAB or HSB
    1) build a cluster-graph initially with every pixel in its own cluster linked to their left/right/up/down neighbors
    2) repeat until ???
        for all edges, select the one with the minimum distance between clusters
          merge those two clusters:
            color: weighted average of the two clusters' colors
            weight: cluster1.weight + cluster2.weight

    *) ??? - when to stop? Either
      a) when we are down to a certain number of clusters or
      b) when merging two clusters exceeds a certain threshold
      c) most of the image is covered by a few large clusters
        Ex: the 10 largest clusters account for 90% of the image.

    *) There should be an optional, final pass which
      a) elliminates small, unintersting clusters
      b) merges clusters which are very similar even though they are not adjacent

    *) I think we can use a HEAP structure to make this reasonably fast.
      Initially there will be n clusters and m = n * 2 edges where n == number of pixels.
      The heap contains records:
        edge-weight - euclidean-distance-squared betwen cluster's colors
        edge-cluster-a-id
        edge-cluster-b-id
      When we merge clusters, we must update the edge-weights of all their combined edges.
        - and some edges will now be duplicates, so remove them.
      The heap can just be a single floating-point array. It'll be about 32k.

      Cluster Map:
        clusterId:
          weight: int - number of pixels in the cluster
          color:  (LAB) - average color of all pixels in cluster
          centroid: (point) - average location of all pixels in cluster (optional)

      Cluster map could be a float array, too:
        weight (float)
        L, A, B: (floats)
        X, Y: (floats)

###

Vibrant    = require './Vibrant'

{log, object, merge, toPlainObjects} = require 'art-foundation'

{rgb256Color, rgbColor, point, Matrix} = require 'art-atomic'
{Bitmap} = require 'art-canvas'

getColorMap = (bitmap) ->
  b = bitmap.getMipmap s = point 3
  final = bitmap.newBitmap s
  final.drawBitmap Matrix.scale(s.div b.size), b

  for r, i in pd = final.imageData.data by 4
    rgb256Color r, pd[i + 1], pd[i + 2]

[
  previewBitmapScale
  previewBitmapBlur
] = [10, 3] # [7, 2] # is not bad and about 30% faster, but I can see banding on the 8pmSunset image.

module.exports =
  version: version = (require '../../../package.json').version

  getColorMapBitmap: getColorMapBitmap = (colorMap) ->
    {imageData} = colorMapBitmap = new Bitmap 3
    i = 0
    {data} = imageData
    for color in colorMap
      {r256,g256,b256} = rgbColor color
      data[i + 0] = r256
      data[i + 1] = g256
      data[i + 2] = b256
      data[i + 3] = 255
      i += 4

    colorMapBitmap.putImageData imageData

  generatePreviewBitmap: ({colorMap})->
    getColorMapBitmap(colorMap).scale previewBitmapScale
    .blur previewBitmapBlur

  mipmapSize: mipmapSize = 64

  ###
  IN: imageData - a 1D RGBA pixel array

    Example:

    context = canvas.getContext '2d'
    imageData = context.getImageData 0, 0, canvas.width, canvas.height
    imageDataBuffer = imageData.data.buffer

    log extractColors imageDataBuffer
  ###
  extractColors: extractColors = (bitmap) ->
    bitmap = bitmap.getMipmap mipmapSize
    {data} = bitmap.imageData

    merge
      version:    version.split(".")[0] | 0
      colorMap:   getColorMap bitmap
      new Vibrant(data).colors

  extractColorsAsPlainObjects: (bitmap) => toPlainObjects extractColors bitmap