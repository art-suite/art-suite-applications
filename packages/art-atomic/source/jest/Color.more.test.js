"use strict";
let Caf = require("caffeine-script-runtime");
Caf.defMod(module, () => {
  return Caf.importInvoke(
    ["describe", "test", "assert", "rgbColor"],
    [global, require("./StandardImport")],
    (describe, test, assert, rgbColor) => {
      return describe({
        with: function () {
          test("withHue", () =>
            assert.eq(rgbColor("#f00"), rgbColor("#0f0").withHue(0)));
          return test("withSimilarHue", () => {
            assert.eq(rgbColor("#f00"), rgbColor("#0f1").withHue(0));
            return assert.eq(
              rgbColor("#f10").hexString,
              rgbColor("#0f1").withSimilarHue(0).hexString
            );
          });
        },
      });
    }
  );
});
