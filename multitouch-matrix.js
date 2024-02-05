// DEMO CODE FOR CARRIE on LECOLEAI

// a1 and b1 are the two starting touch points
// a2 and b2 are where the two starting touches moved to
const multiTouchTransform = function (a1, a2, b1, b2) {
  // starting center point
  let c1x = (b1.x + a1.x) / 2;
  let c1y = (b1.y + a1.y) / 2;
  let v1 = b1.sub(a1); // vector from starting touchpoint a to touchpoint b (.sub is vector subtraction)
  let v1m = v1.magnitude; // magnitude of v1

  // ending center point
  let c2x = (b2.x + a2.x) / 2;
  let c2y = (b2.y + a2.y) / 2;
  let v2 = b2.sub(a2);
  let v2m = v2.magnitude;

  // start with a blank matrix
  // and translate the center of the starting touches to [0,0]
  // this centers the scaling and rotation around the center of the two touches
  let m = Matrix.translateXY(-c1x, -c1y);

  if (!float32Eq0(v1m) && !float32Eq0(v2m)) {
    // float32Eq0 just tests if v1m and v2m are very-very close to 0; this avoids divide by 0 edge cases
    let angle = v2.angle - v1.angle; // calculate the difference in angles of the two vectors
    let scale = v2m / v1m;

    // if there is rotation, apply it
    if (!float32Eq0(angle)) {
      m = m.rotate(angle);
    }

    // if there is scaling, apply it
    if (!float32Eq(scale, 1)) {
      m = m.scale(scale);
    }
  }

  // translate to the center of the end touches
  return m.translateXY(c2x, c2y);
};

// a1 and b1 are the two starting touch points
// a2 and b2 are where the two starting touches moved to
const multitouchParts = function (a1, a2, b1, b2) {
  let v1 = b1.sub(a1); // vector between the two starting touch points
  let v2 = b2.sub(a2); // vector between the two ending touch points
  return {
    rotate: v2.angle - v1.angle, // difference in angles of the two fectors
    scale: v2.magnitude / v1.magnitude,
    translate: {
      x: (b2.x + a2.x) / 2 - (b1.x + a1.x) / 2, // distance traveled on the x-axis of the center point of each pair of touch-points
      y: (b2.y + a2.y) / 2 - (b1.y + a1.y) / 2, // distance traveled on the y-axis of the center point of each pair of touch-points
    },
  };
};
