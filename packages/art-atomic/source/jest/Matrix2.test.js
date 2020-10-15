"use strict";
let Caf = require("caffeine-script-runtime");
Caf.defMod(module, () => {
  return Caf.importInvoke(
    [
      "describe",
      "point",
      "Math",
      "test",
      "formattedInspect",
      "Matrix",
      "assert"
    ],
    [global, require("./StandardImport")],
    (describe, point, Math, test, formattedInspect, Matrix, assert) => {
      return describe({
        multitouch: function() {
          let testMultitouch;
          testMultitouch = (testName, from1, to1, from2, to2, options = {}) =>
            test(`${Caf.toString(testName)} ${Caf.toString(
              from1
            )} > ${Caf.toString(to1)} & ${Caf.toString(from2)} > ${Caf.toString(
              to2
            )} >> ${Caf.toString(formattedInspect(options))}`, () => {
              let m, angle, scale, translate;
              m = Matrix.multitouch(from1, to1, from2, to2);
              assert.eq(to1, m.transform(from1));
              assert.eq(to2, m.transform(from2));
              ({ angle, scale, translate } = options);
              return assert.selectedEq(
                {
                  angle,
                  exactScale: scale != null && point(scale),
                  location: translate != null && point(translate)
                },
                m
              );
            });
          testMultitouch(
            "simple translate",
            point(0, 0),
            point(1, 1),
            point(1, 0),
            point(2, 1),
            { angle: 0, scale: 1, translate: 1 }
          );
          testMultitouch(
            "simple scale",
            point(0, 0),
            point(0, 0),
            point(1, 0),
            point(2, 0),
            { angle: 0, scale: 2, translate: 0 }
          );
          return testMultitouch(
            "simple angle",
            point(0, 0),
            point(0, 0),
            point(1, 0),
            point(0, 1),
            { angle: Math.PI / 2, scale: 1, translate: 0 }
          );
        }
      });
    }
  );
});
