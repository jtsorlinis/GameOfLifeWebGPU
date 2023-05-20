struct Params {
  width : u32,
  gridWidth : u32,
  height : u32,
  zoom : f32,
  rngSeed : u32,
}

@binding(0) @group(0) var<uniform> params: Params;
@binding(1) @group(0) var<storage, read> cellsIn : array<u32>;
@binding(2) @group(0) var<storage, read_write> cellsOut : array<u32>;

fn getBit(input : u32, pos : u32) -> u32 {
  return (input >> pos) & 1;
}

fn setBit(input: ptr<function, u32>, position: u32) {
    *input = *input | (1u << position);
}

fn clearBit(input: ptr<function, u32>, position: u32) {
    *input = *input & (~(1u << position));
}

@compute @workgroup_size(8, 8, 1)
fn main(@builtin(global_invocation_id) id : vec3<u32>) {
  let gridWidth = params.gridWidth;
  // Leave 1 pixel border
  if (id.x == 0 || id.x >= params.gridWidth - 1 || id.y == 0 || id.y >= params.height - 1) {
    return;
  }

  let index = id.y * params.gridWidth + id.x;

  // Get neighbouring indexes
  let topLeft = cellsIn[index - gridWidth - 1];
  let top = cellsIn[index - gridWidth];
  let topRight = cellsIn[index - gridWidth + 1];
  let left = cellsIn[index - 1];
  let cell = cellsIn[index];
  let right = cellsIn[index + 1];
  let bottomLeft = cellsIn[index + gridWidth - 1];
  let bottom = cellsIn[index + gridWidth];
  let bottomRight = cellsIn[index + gridWidth + 1];
  
  var output = 0u;

  // Leftmost cell (Bit 0)
  var neighbours = getBit(topLeft, 31);
  neighbours += getBit(top, 0);
  neighbours += getBit(top, 1);
  neighbours += getBit(left, 31);
  neighbours += getBit(cell, 1);
  neighbours += getBit(bottomLeft, 31);
  neighbours += getBit(bottom, 0);
  neighbours += getBit(bottom, 1);
  
  var alive = getBit(cell, 0);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, 0);
  } else {
    clearBit(&output, 0);
  }

  // Manually unroll the loop for the middle cells because WGSL doesn't seem to want to unroll this for us
  // Unrolling in this case doubles performance
  
  var i = 1u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 2u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 3u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 4u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 5u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 6u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 7u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 8u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 9u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 10u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 11u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 12u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 13u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 14u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 15u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 16u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 17u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 18u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 19u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 20u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 21u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 22u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 23u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 24u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 25u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 26u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 27u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 28u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 29u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
  }

  i = 30u;
  neighbours = getBit(top, i - 1);
  neighbours += getBit(top, i);
  neighbours += getBit(top, i + 1);
  neighbours += getBit(cell, i - 1);
  neighbours += getBit(cell, i + 1);
  neighbours += getBit(bottom, i - 1);
  neighbours += getBit(bottom, i);
  neighbours += getBit(bottom, i + 1);

  alive = getBit(cell, i);
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, i);
  } else {
    clearBit(&output, i);
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
  if ((bool(alive) && neighbours == 2) || neighbours == 3) {
    setBit(&output, 31);
  } else {
    clearBit(&output, 31);
  }

  cellsOut[index] = output;
}

