import {
  ComputeShader,
  Scene,
  ShaderLanguage,
  ShaderMaterial,
  ThinEngine,
} from "@babylonjs/core";
import cellsVertex from "./cellsVertex.wgsl?raw";
import cellsFragment from "./cellsFragment.wgsl?raw";
import cellsCompute from "./compute/cells.wgsl?raw";
import generateCellsCompute from "./compute/generateCells.wgsl?raw";

export const createQuadMaterial = (scene: Scene) => {
  return new ShaderMaterial(
    "quadMat",
    scene,
    { vertexSource: cellsVertex, fragmentSource: cellsFragment },
    {
      attributes: ["position", "uv"],
      uniformBuffers: ["Scene", "Mesh", "params"],
      storageBuffers: ["cells"],
      shaderLanguage: ShaderLanguage.WGSL,
    }
  );
};

export const createGenerateCellsComputeShader = (engine: ThinEngine) => {
  return new ComputeShader(
    "generateCellsCompute",
    engine,
    { computeSource: generateCellsCompute },
    {
      bindingsMapping: {
        params: { group: 0, binding: 0 },
        cells: { group: 0, binding: 1 },
      },
    }
  );
};

export const createCellsComputeShader = (engine: ThinEngine) => {
  return new ComputeShader(
    "cellsCompute",
    engine,
    { computeSource: cellsCompute },
    {
      bindingsMapping: {
        params: { group: 0, binding: 0 },
        cellsIn: { group: 0, binding: 1 },
        cellsOut: { group: 0, binding: 2 },
      },
    }
  );
};
