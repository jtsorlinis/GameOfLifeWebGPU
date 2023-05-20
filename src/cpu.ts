const getBit = (n: number, pos: number) => {
  return (n >> pos) & 1;
};

const setBit = (n: number, pos: number) => {
  return n | (1 << pos);
};

const clearBit = (n: number, pos: number) => {
  return n & ~(1 << pos);
};

export const calculateLifeCPU = (
  cellsIn: Uint32Array,
  cellsOut: Uint32Array,
  totalCells: number,
  gridWidth: number
) => {
  for (let i = 0; i < totalCells; i++) {
    // Get neighbouring indexes
    let topLeft = cellsIn[i - gridWidth - 1];
    let top = cellsIn[i - gridWidth];
    let topRight = cellsIn[i - gridWidth + 1];
    let left = cellsIn[i - 1];
    let cell = cellsIn[i];
    let right = cellsIn[i + 1];
    let bottomLeft = cellsIn[i + gridWidth - 1];
    let bottom = cellsIn[i + gridWidth];
    let bottomRight = cellsIn[i + gridWidth + 1];

    let output = 0;

    // Leftmost cell (Bit 0)
    let neighbours = getBit(topLeft, 31);
    neighbours += getBit(top, 0);
    neighbours += getBit(top, 1);
    neighbours += getBit(left, 31);
    neighbours += getBit(cell, 1);
    neighbours += getBit(bottomLeft, 31);
    neighbours += getBit(bottom, 0);
    neighbours += getBit(bottom, 1);

    let alive = getBit(cell, 0);
    if ((alive && neighbours == 2) || neighbours == 3) {
      output = setBit(output, 0);
    } else {
      output = clearBit(output, 0);
    }

    // All middle cells (Bits 1-30)
    for (let i = 1; i < 31; i++) {
      neighbours = getBit(top, i - 1);
      neighbours += getBit(top, i);
      neighbours += getBit(top, i + 1);
      neighbours += getBit(cell, i - 1);
      neighbours += getBit(cell, i + 1);
      neighbours += getBit(bottom, i - 1);
      neighbours += getBit(bottom, i);
      neighbours += getBit(bottom, i + 1);

      alive = getBit(cell, i);
      if ((alive && neighbours == 2) || neighbours == 3) {
        output = setBit(output, i);
      } else {
        output = clearBit(output, i);
      }
    }

    // Rightmost cell (Bit 31)
    neighbours = getBit(top, 30);
    neighbours += getBit(top, 31);
    neighbours += getBit(topRight, 0);
    neighbours += getBit(cell, 30);
    neighbours += getBit(right, 0);
    neighbours += getBit(bottom, 30);
    neighbours += getBit(bottom, 31);
    neighbours += getBit(bottomRight, 0);

    alive = getBit(cell, 31);
    if ((alive && neighbours == 2) || neighbours == 3) {
      output = setBit(output, 31);
    } else {
      output = clearBit(output, 31);
    }

    cellsOut[i] = output;
  }
};
