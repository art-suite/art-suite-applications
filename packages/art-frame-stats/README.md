# Art.Frame.Stats

An easy, extensible tool for logging where your JavaScript time was spent each frame. It is targeted to be used in the Epoched frame-update world of ArtSuite (ArtEpochedState based), however, it should work well even beyond that.

The primary system is you start an overall frame-timer at the beginning of your frame-update, and end it when you are completely done. That alone will get you a nice bar-graph of performance-per-frame. But, and this is where it gets interesting, you can nest sub-timers, as deep as you want, and it'll "do the right thing" and add a rainbow of information to each bar in the bar-graph (one frame) showing you exactly where you spend your time.

The main output is a nice graph - as a bitmap. That means you need the ArtDomConsole to really get full advantage. If there is interest (and help), I'd love to find other easy outputs.

This tool really is awesome for introspection of frame-update-based performance. Much more effective than Chrome's overly general, and overwhelming performance tools.

### Install

```coffeescript
npm install art-frame-stats
```