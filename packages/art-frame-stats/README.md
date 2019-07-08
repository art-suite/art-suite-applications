# Art.Frame.Stats

An easy, extensible tool for logging where your time was spent in each frame. It is targeted to be used in the Epoched frame-update world of ArtSuite (ArtEpochedState based), however, it should work well even beyond that. One of the cool features is the ability to for sub-timers to get accounted for correctly when run within a parent-timer.

The main output is a nice graph - as a bitmap. That means you need the ArtDomConsole to really get full advantage. If there is interest (and help), I'd love to find other easy outputs.

This tool really is awesome for introspection of performance. Much more effective than Chrome's overly general, and overwhelming performance tools.

### Install

```coffeescript
npm install art-frame-stats
```