# TicTacToe - CaffeineScript vs JSX/JS

CaffeineScript + ArtSuite is over 4 times smaller than JS+CSS.

## TicTacToe with UX styling

This compares the JSX + CSS implementation to the CaffeineScript + ArtSuite implementation.

* 850 tokens: [JSX (738) + CSS (112)](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/.TicTacToe_FacebookReact.jsx)
* 970 tokens: JS (858) + CSS (112)
* **220 tokens: [CaffeineScript + ArtSuite](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/Main.caf)**
<br>*3.7x smaller than JSX + CSS*
<br>*4.4x smaller than JS + CSS*

## The Power of Just CaffeineScript

Even just converting JSX or JS to CaffeineScript has dramatic improvements.

* 738 tokens: [JSX](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/.TTT_source.jsx)
* 858 tokens: [JS](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/.TTT_jsx_to_js.js)
* **306 tokens: [CaffeineScript (isomorphic conversion)](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/.TTT_jsx_to_js_to_caf_isomorphic.caf)**
<br>Structurally identical
<br>*2.4x smaller then JSX*
<br>*2.8x smaller then JS*
* **235 tokens: [CaffeineScript (optimal coversion)](https://github.com/imikimi/art-suite-demos/blob/master/source/Art.SuiteDemos/Demos/TicTacToe/.TTT_jsx_to_js_to_caf_refactor.caf)**
<br>Logically identical but taking advantage of CaffeineScript-specific features
<br>*3.1x smaller than JSX*
<br>*3.7x smaller than JS*
