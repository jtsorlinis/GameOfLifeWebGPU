struct Params {
  width : u32,
  gridWidth : u32,
  height : u32,
  zoom : f32,
  rngSeed : u32,
}

@binding(0) @group(0) var<uniform> params: Params;
@binding(1) @group(0) var<storage,read_write> cells : array<u32>;

fn rand_pcg(input: u32) -> u32 {
  var state = input * 747796405u + 2891336453u;
  var word: u32 = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
  return (word >> 22u) ^ word;
}

@compute @workgroup_size(8, 8, 1)
fn main(@builtin(global_invocation_id) id : vec3<u32>) {
   // Leave 1 pixel border
  if (id.x == 0 || id.x >= params.gridWidth - 1 || id.y == 0 || id.y >= params.height - 1) {
    return;
  }

  let index = id.y * params.gridWidth + id.x;
  
  cells[index] = rand_pcg(params.rngSeed + index);
}

