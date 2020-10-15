"use strict";
let Caf = require("caffeine-script-runtime");
Caf.defMod(module, () => {
  return Caf.importInvoke(
    ["describe", "test", "perimeter", "assert", "rect", "point"],
    [global, require("./StandardImport")],
    (describe, test, perimeter, assert, rect, point) => {
      return describe({
        new: function() {
          test("0", () => {
            let p;
            p = perimeter(0);
            assert.equal(0, p.left);
            assert.equal(0, p.right);
            assert.equal(0, p.top);
            return assert.equal(0, p.bottom);
          });
          test("null", () => {
            let p;
            p = perimeter(null);
            assert.equal(0, p.left);
            assert.equal(0, p.right);
            assert.equal(0, p.top);
            return assert.equal(0, p.bottom);
          });
          test("undefined", () => {
            let p;
            p = perimeter(undefined);
            assert.equal(0, p.left);
            assert.equal(0, p.right);
            assert.equal(0, p.top);
            return assert.equal(0, p.bottom);
          });
          test("1, 2, 3, 4", () => {
            let p;
            p = perimeter(1, 2, 3, 4);
            assert.equal(1, p.left);
            assert.equal(2, p.right);
            assert.equal(3, p.top);
            return assert.equal(4, p.bottom);
          });
          test("1, 2", () => {
            let p;
            p = perimeter(1, 2);
            assert.equal(1, p.left);
            assert.equal(1, p.right);
            assert.equal(2, p.top);
            return assert.equal(2, p.bottom);
          });
          test("h:1, v:2", () => {
            let p;
            p = perimeter({ h: 1, v: 2 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 1,
              top: 2,
              bottom: 2
            });
          });
          test("horizontal:1, vertical:2", () => {
            let p;
            p = perimeter({ horizontal: 1, vertical: 2 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 1,
              top: 2,
              bottom: 2
            });
          });
          test("left: 1, right: 2, top: 3, bottom: 4", () => {
            let p;
            p = perimeter({ left: 1, right: 2, top: 3, bottom: 4 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 2,
              top: 3,
              bottom: 4
            });
          });
          test("l: 1, r: 2, t: 3, b: 4", () => {
            let p;
            p = perimeter({ l: 1, r: 2, t: 3, b: 4 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 2,
              top: 3,
              bottom: 4
            });
          });
          test("l: 1, r: 2, v: 3", () => {
            let p;
            p = perimeter({ l: 1, r: 2, v: 3 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 2,
              top: 3,
              bottom: 3
            });
          });
          test("l: 1, t: 2", () => {
            let p;
            p = perimeter({ l: 1, t: 2 });
            return assert.eq(p.toObject(), {
              left: 1,
              right: 0,
              top: 2,
              bottom: 0
            });
          });
          return test("l: 1, r: 2, t: 3, b: 4, h: 10, v: 100", () => {
            let p;
            p = perimeter({ l: 1, r: 2, t: 3, b: 4, h: 10, v: 100 });
            return assert.eq(p.toObject(), {
              left: 11,
              right: 12,
              top: 103,
              bottom: 104
            });
          });
        },
        computedProperties: function() {
          test("width", () => {
            let p;
            p = perimeter({ l: 1, r: 2, t: 3, b: 4 });
            return assert.eq(p.width, 3);
          });
          return test("height", () => {
            let p;
            p = perimeter({ l: 1, r: 2, t: 3, b: 4 });
            return assert.eq(p.height, 7);
          });
        },
        pad: function() {
          test("top bottom", () => {
            let p;
            p = perimeter({ top: 5, bottom: 10 });
            return assert.eq(p.pad(rect(100)), rect(0, 5, 100, 85));
          });
          test("point2d", () => {
            let p;
            p = perimeter({ top: 5, bottom: 10 });
            return assert.eq(p.pad(point(100)), rect(0, 5, 100, 85));
          });
          return test("left right", () => {
            let p;
            p = perimeter({ left: 5, right: 10 });
            return assert.eq(p.pad(rect(100)), rect(5, 0, 85, 100));
          });
        },
        interpolate: function() {
          return test("height", () => {
            let a, b, c;
            a = perimeter({ l: 1.0, r: 2.0, t: 3.0, b: 4.0 });
            b = perimeter({ l: 2.0, r: 3.0, t: 4.0, b: 5.0 });
            c = perimeter({ l: 1.5, r: 2.5, t: 3.5, b: 4.5 });
            a.eq(b);
            return assert.eq(c, a.interpolate(b, 0.5));
          });
        },
        eq: function() {
          test("eq 0 0 0 0", () =>
            assert.true(perimeter(0, 0, 0, 0).eq(0, 0, 0, 0)));
          return test("eq 1 2 3 4", () =>
            assert.true(perimeter(1, 2, 3, 4).eq(1, 2, 3, 4)));
        }
      });
    }
  );
});
