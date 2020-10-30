"use strict";
let Caf = require("caffeine-script-runtime");
Caf.defMod(module, () => {
  return Caf.importInvoke(
    [
      "describe",
      "test",
      "Point",
      "assert",
      "point",
      "Math",
      "point1",
      "floatEq",
      "rect"
    ],
    [global, require("./StandardImport")],
    (describe, test, Point, assert, point, Math, point1, floatEq, rect) => {
      return describe({
        basics: function() {
          test("allocate point", () => {
            let p;
            p = new Point(3, 7);
            assert.equal(3, p.x);
            return assert.equal(7, p.y);
          });
          test("vectorLength", () => {
            let p;
            p = point();
            return assert.eq(p.vectorLength, 2);
          });
          test("vector", () => {
            let p;
            p = point(3, 4);
            return assert.eq(p.vector, [3, 4]);
          });
          test("from vector", () => {
            let p;
            p = point([3, 4]);
            return assert.eq(p, point(3, 4));
          });
          test("toArray", () => {
            let p, a;
            p = point((a = [3, 4]));
            return assert.eq(p.toArray(), a);
          });
          test("withX", () => {
            let p;
            p = point(3, 4);
            return assert.eq(p.withX(5), point(5, 4));
          });
          test("withY", () => {
            let p;
            p = point(3, 4);
            return assert.eq(p.withY(5), point(3, 5));
          });
          test("from object", () => {
            let a;
            a = { x: 10, y: 20 };
            return assert.eq(point(a), point(10, 20));
          });
          test("named point constructor", () => {
            assert.eq(Point.point0, point("point0"));
            assert.eq(Point.point1, point("point1"));
            assert.eq(Point.topLeft, point("topLeft"));
            assert.eq(Point.topCenter, point("topCenter"));
            assert.eq(Point.topRight, point("topRight"));
            assert.eq(Point.centerLeft, point("centerLeft"));
            assert.eq(Point.centerCenter, point("centerCenter"));
            assert.eq(Point.centerRight, point("centerRight"));
            assert.eq(Point.bottomLeft, point("bottomLeft"));
            assert.eq(Point.bottomCenter, point("bottomCenter"));
            return assert.eq(Point.bottomRight, point("bottomRight"));
          });
          test("appendVector", () => {
            let p, v;
            p = point(3, 4);
            v = [123, 456];
            p.appendToVector(v);
            return assert.eq(v, [123, 456, 3, 4]);
          });
          test("allocate point : 1-arg", () => {
            let p;
            p = new Point(3);
            assert.equal(3, p.x);
            return assert.equal(3, p.y);
          });
          test("allocate point : 0-args", () => {
            let p;
            p = new Point();
            assert.equal(0, p.x);
            return assert.equal(0, p.y);
          });
          test("point string parsing", () => {
            assert.eq(point("4,5"), point(4, 5));
            assert.eq(point("(4,5)"), point(4, 5));
            return assert.eq(point("(-234.34,5.234)"), point(-234.34, 5.234));
          });
          test("lt lte", () => {
            let p1, p2, p3;
            p1 = new Point(3, 7);
            p2 = new Point(5, 11);
            p3 = new Point(4, 1);
            assert.ok(p1.lt(p2));
            assert.ok(!p2.lt(p1));
            assert.ok(!p1.lt(p3));
            assert.ok(!p3.lt(p1));
            assert.ok(!p1.lt(p1));
            assert.ok(p1.lte(p2));
            assert.ok(!p2.lte(p1));
            assert.ok(!p1.lte(p3));
            assert.ok(!p3.lte(p1));
            return assert.ok(p1.lte(p1));
          });
          test("gt gte", () => {
            let p1, p2, p3;
            p1 = new Point(3, 7);
            p2 = new Point(5, 11);
            p3 = new Point(4, 1);
            assert.ok(p2.gt(p1));
            assert.ok(!p1.gt(p2));
            assert.ok(p2.gt(p3));
            assert.ok(!p3.gt(p2));
            assert.ok(!p2.gt(p2));
            assert.ok(p2.gte(p1));
            assert.ok(!p1.gte(p2));
            assert.ok(p2.gte(p3));
            assert.ok(!p3.gte(p2));
            return assert.ok(p2.gte(p2));
          });
          test("add", () => {
            let p1, p2;
            p1 = point(3, 7);
            p2 = point(5, 11);
            assert.eq(point(8, 18), p1.add(p2));
            assert.eq(point(8, 18), p1.add(p2.x, p2.y));
            return assert.eq(point(8, 12), p1.add(p2.x));
          });
          test("sub", () => {
            let p1, p2;
            p1 = point(3, 7);
            p2 = point(5, 11);
            assert.eq(point(2, 4), p2.sub(p1));
            assert.eq(point(2, 4), p2.sub(p1.x, p1.y));
            return assert.eq(point(2, 8), p2.sub(p1.x));
          });
          test("mul", () => {
            let p1, p2;
            p1 = point(3, 7);
            p2 = point(5, 11);
            assert.eq(point(15, 77), p1.mul(p2));
            assert.eq(point(15, 77), p1.mul(p2.x, p2.y));
            return assert.eq(point(15, 35), p1.mul(p2.x));
          });
          test("div", () => {
            let p1, p2;
            p1 = point(3, 7);
            p2 = point(6, 21);
            assert.eq(point(2, 3), p2.div(p1));
            assert.eq(point(2, 3), p2.div(p1.x, p1.y));
            return assert.eq(point(2, 7), p2.div(p1.x));
          });
          test("area", () => assert.equal(10, point(2, 5).area));
          test("min null", () => assert.equal(2, point(2, 5).min()));
          test("max null", () => assert.equal(5, point(2, 5).max()));
          test("min", () =>
            assert.deepEqual(point(2, -1), point(2, 5).min(point(3, -1))));
          test("max", () =>
            assert.deepEqual(point(3, 5), point(2, 5).max(point(3, -1))));
          test("bound", () => {
            assert.deepEqual(
              point(2, 3),
              point(1, 1).bound(point(2, 3), point(7, 11))
            );
            assert.deepEqual(
              point(2, 11),
              point(1, 15).bound(point(2, 3), point(7, 11))
            );
            assert.deepEqual(
              point(7, 3),
              point(10, 1).bound(point(2, 3), point(7, 11))
            );
            assert.deepEqual(
              point(7, 11),
              point(10, 15).bound(point(2, 3), point(7, 11))
            );
            assert.deepEqual(
              point(2, 3),
              point(2, 3).bound(point(2, 3), point(7, 11))
            );
            return assert.deepEqual(
              point(2.5, 3.5),
              point(2.5, 3.5).bound(point(2, 3), point(7, 11))
            );
          });
          test("point(a=point()) should return a unaltered", () => {
            let p1, p2, p3;
            p1 = point(1, 2);
            p2 = point(1, 2);
            p3 = point(p1);
            assert.ok(p1 === p3);
            assert.ok(p1 !== p2);
            assert.ok(p2 !== p3);
            return assert.deepEqual(p1, p2);
          });
          test("round(1)", () => {
            assert.eq(point(1.75, 3.25).round(), point(2, 3));
            assert.eq(point(-1.75, -3.25).round(), point(-2, -3));
            assert.eq(point(1.5, -1.5).round(), point(2, -1));
            assert.eq(point(1.4999, -1.4999).round(), point(1, -1));
            return assert.eq(point(1.5001, -1.5001).round(), point(2, -2));
          });
          test("round(not 1)", () => {
            assert.eq(point(15.3, 13.4).round(10), point(20, 10));
            assert.eq(point(15.33, 13.43).round(0.1), point(15.3, 13.4));
            return assert.deepEqual(point(45, 30).round(13), point(39, 26));
          });
          test("floor", () => {
            assert.eq(point(15.9, 14.1).floor(), point(15, 14));
            return assert.eq(point(-15.9, -14.1).floor(), point(-16, -15));
          });
          test("ceil", () => {
            assert.eq(point(15.9, 14.1).ceil(), point(16, 15));
            return assert.eq(point(-15.9, -14.1).ceil(), point(-15, -14));
          });
          test("magnitudeSquared", () => {
            assert.equal(point(5, 5).magnitudeSquared, 50);
            assert.equal(point(3, 4).magnitudeSquared, 25);
            assert.equal(point(0, 5).magnitudeSquared, 25);
            assert.equal(point(5, 0).magnitudeSquared, 25);
            assert.equal(point(-1, 5).magnitudeSquared, 26);
            return assert.equal(point(5, -1).magnitudeSquared, 26);
          });
          test("magnitude", () => {
            assert.equal(point(5, 5).magnitude, Math.sqrt(50));
            assert.equal(point(3, 4).magnitude, 5);
            assert.equal(point(0, 5).magnitude, 5);
            assert.equal(point(5, 0).magnitude, 5);
            assert.equal(point(-1, 5).magnitude, Math.sqrt(26));
            return assert.equal(point(5, -1).magnitude, Math.sqrt(26));
          });
          test("distance", () => {
            assert.equal(point(3, 4).distance(point(0, 0)), 5);
            assert.equal(point(6, 8).distance(point(3, 4)), 5);
            return assert.equal(point(1, 1).distance(point(-2, -3)), 5);
          });
          test("distanceSquared", () => {
            assert.equal(point(3, 4).distanceSquared(point(0, 0)), 25);
            assert.equal(point(6, 8).distanceSquared(point(3, 4)), 25);
            return assert.equal(point(1, 1).distanceSquared(point(-2, -3)), 25);
          });
          test("magnitude", () => {
            assert.equal(point(5, 5).magnitude, Math.sqrt(50));
            assert.equal(point(3, 4).magnitude, 5);
            assert.equal(point(0, 5).magnitude, 5);
            assert.equal(point(5, 0).magnitude, 5);
            assert.equal(point(-1, 5).magnitude, Math.sqrt(26));
            return assert.equal(point(5, -1).magnitude, Math.sqrt(26));
          });
          test("dot", () => {
            assert.eq(point(5, 4).dot(point(2, 4)), 26);
            return assert.eq(point(1, 9).dot(point(3, -2)), -15);
          });
          test("cross", () => {
            assert.eq(point(5, 4).cross(point(2, 4)), 12);
            return assert.eq(point(1, 9).cross(point(3, -2)), -29);
          });
          test("point0", () => assert.eq(Point.point0, point()));
          test("point1", () => assert.eq(Point.point1, point(1)));
          return test("interpolate 0, .5, and 1", () => {
            let p1, p2;
            p1 = point(1, 2);
            p2 = point(3, 6);
            assert.eq(p1.interpolate(p2, 0), p1);
            assert.eq(p1.interpolate(p2, 1), p2);
            return assert.eq(p1.interpolate(p2, 0.5), point(2, 4));
          });
        },
        fitInto: function() {
          let fitIntoTest;
          fitIntoTest = (p, intoPoint) =>
            test(`${Caf.toString(p.inspect())}.fitInto ${Caf.toString(
              intoPoint.inspect()
            )} => ${Caf.toString(
              p.fitInto(intoPoint).inspectedString
            )}`, () => {
              let res;
              res = p.fitInto(intoPoint);
              assert.ok(res.lte(intoPoint));
              assert.ok(res.x === intoPoint.x || res.y === intoPoint.y);
              return assert.eq(res.aspectRatio, p.aspectRatio);
            });
          fitIntoTest(point(1, 2), point(2, 1));
          fitIntoTest(point(2, 1), point(2, 1));
          fitIntoTest(point(2, 1), point(1, 2));
          fitIntoTest(point(1, 1), point(1, 2));
          fitIntoTest(point(1, 1), point(2, 1));
          fitIntoTest(point(100, 100), point(2, 1));
          return fitIntoTest(point(1, 1), point(200, 100));
        },
        withSameAreaAs: function() {
          let withSameAreaAsTest;
          withSameAreaAsTest = (p, p2) =>
            test(`${Caf.toString(p.inspect())}.withSameAreaAs ${Caf.toString(
              p2.inspect()
            )} => ${Caf.toString(
              p.withSameAreaAs(p2).inspectedString
            )}`, () => {
              let res;
              res = p.withSameAreaAs(p2);
              assert.floatEq(res.area, p2.area);
              return assert.floatEq(res.aspectRatio, p.aspectRatio);
            });
          withSameAreaAsTest(point(1, 2), point(2, 1));
          withSameAreaAsTest(point(1, 2), point(4, 2));
          withSameAreaAsTest(point(1, 2), point(4, 4));
          withSameAreaAsTest(point(2, 1), point(2, 1));
          withSameAreaAsTest(point(2, 1), point(1, 2));
          withSameAreaAsTest(point(1, 1), point(1, 2));
          withSameAreaAsTest(point(1, 1), point(2, 1));
          withSameAreaAsTest(point(100, 100), point(2, 1));
          return withSameAreaAsTest(point(1, 1), point(200, 100));
        },
        fill: function() {
          let fillTest;
          fillTest = (p, p2) =>
            test(`${Caf.toString(p.inspect())}.fill ${Caf.toString(
              p2.inspect()
            )} => ${Caf.toString(p.fill(p2).inspectedString)}`, () => {
              let res;
              res = p.fill(p2);
              assert.ok(res.gte(p2));
              assert.ok(res.x === p2.x || res.y === p2.y);
              return assert.eq(res.aspectRatio, p.aspectRatio);
            });
          fillTest(point(1, 2), point(2, 1));
          fillTest(point(2, 1), point(2, 1));
          fillTest(point(2, 1), point(1, 2));
          fillTest(point(1, 1), point(1, 2));
          fillTest(point(1, 1), point(2, 1));
          fillTest(point(100, 100), point(2, 1));
          return fillTest(point(1, 1), point(200, 100));
        },
        withArea: function() {
          let testWithArea;
          testWithArea = (area, ...pointArgs) => {
            let p;
            p = point(...pointArgs);
            return test(`${Caf.toString(p.inspect())}.withArea ${Caf.toString(
              area
            )}`, () => {
              p = p.withArea(area);
              return assert.eq(
                Math.round(p.area),
                Math.round(area),
                `${Caf.toString(p.inspect())}.area == ${Caf.toString(area)}`
              );
            });
          };
          testWithArea(10, point1);
          testWithArea(10, point(2, 1));
          testWithArea(100, point(2, 1));
          return testWithArea(0, point(2, 1));
        },
        "aspectRatio-area": function() {
          let aaTest;
          aaTest = (aspectRatio, area) => {
            let ratioString, testName;
            ratioString =
              aspectRatio < 1
                ? `1:${Caf.toString(1 / aspectRatio)}`
                : `${Caf.toString(aspectRatio)}:1`;
            return test(
              (testName = `${Caf.toString(
                ratioString
              )} with area ${Caf.toString(area)}`),
              () => {
                let p;
                p = point({ aspectRatio, area });
                assert.ok(
                  floatEq(p.aspectRatio, aspectRatio),
                  `${Caf.toString(p.inspect())}.aspectRatio`
                );
                return assert.ok(
                  floatEq(p.area, area),
                  `${Caf.toString(p.inspect())}.area`
                );
              }
            );
          };
          aaTest(1, 100);
          aaTest(1 / 2, 100);
          aaTest(2, 100);
          aaTest(1 / 3, 100);
          aaTest(3, 100);
          aaTest(2, 2);
          aaTest(2, 200);
          aaTest(2, 20000);
          return test("with area 0", () => {
            let p;
            p = point({ aspectRatio: 2, area: 0 });
            assert.eq(p.area, 0, "area");
            assert.eq(p.x, 0, "x");
            return assert.eq(p.y, 0, "y");
          });
        },
        intersection: function() {
          test("intersection with rect", () => {
            let p, r, out;
            p = point(100);
            r = rect(10, -5, 40, 50);
            out = p.intersection(r);
            return assert.eq(out, rect(10, 0, 40, 45));
          });
          test("intersection with point", () =>
            assert.eq(point(100).intersection(point(1, 2)), rect(0, 0, 1, 2)));
          return test("intersection into same", () => {
            let p, r, out;
            p = point(100);
            r = rect(10, -5, 40, 50);
            out = p.intersection(r, r);
            assert.eq(out, rect(10, 0, 40, 45));
            return assert.equal(out, r);
          });
        },
        ratios: function() {
          test("minRatio", () =>
            assert.eq(point(2, 6).minRatio(point(1, 2)), 2));
          return test("maxRatio", () =>
            assert.eq(point(2, 6).maxRatio(point(1, 2)), 3));
        },
        regressions: function() {
          test("point1.neq point -1", () => {
            let p;
            p = new Point(-1, -1);
            assert.false(floatEq(1, -1), "floatEq");
            assert.selectedEq({ x: -1, y: -1 }, p);
            return assert.neq(point1, p);
          });
          test("point -1", () =>
            assert.selectedEq({ x: -1, y: -1 }, point(-1)));
          return test("point 0, -1", () =>
            assert.selectedEq({ x: 0, y: -1 }, point(0, -1)));
        }
      });
    }
  );
});
