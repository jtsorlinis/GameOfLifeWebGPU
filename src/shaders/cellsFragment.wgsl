struct Params {
  width : u32,
  gridWidth : u32,
  height : u32,
  zoom : f32,
  rngSeed : u32,
}

var<uniform> params: Params;
var<storage,read> cells : array<u32>;

const lineThickness : f32 = 0.1;

varying vUV : vec2<f32>;

fn getBit(input : u32, pos : u32) -> u32 {
  return (input >> pos) & 1;
}

@fragment
fn main(input : FragmentInputs) -> FragmentOutputs {
  let uv = input.vUV;

  // Draw grid
  if (params.zoom < 0.5 && (fract(uv.x * f32(params.width)) < lineThickness || fract(uv.y * f32(params.height)) < lineThickness)) {
    let opacity = 0.5 - params.zoom;
    fragmentOutputs.color = vec4<f32>(opacity,opacity,opacity,1);
    return fragmentOutputs;
  }

  let xpos = u32(uv.x * f32(params.width));
  let gridxpos = u32(uv.x * f32(params.gridWidth));
  let ypos = u32(uv.y * f32(params.height));
  let index = ypos * params.width + xpos;
  let gridIndex = ypos * params.gridWidth + gridxpos;
  let cellVal = f32(getBit(cells[gridIndex],index % 32));

  // Dont draw cells on the edge
  if(gridxpos == 0 || gridxpos == params.gridWidth - 1 || ypos == 0 || ypos == params.height - 1) {
    fragmentOutputs.color = vec4<f32>(0,0,0,1);
    return fragmentOutputs;
  }
  fragmentOutputs.color = vec4<f32>(cellVal,cellVal,cellVal,1);
}