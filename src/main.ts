import {
  MeshBuilder,
  Scalar,
  StorageBuffer,
  UniformBuffer,
  Vector2,
} from "@babylonjs/core";
import "./style.css";
import { initScene, randUint } from "./utils";
import {
  createCellsComputeShader,
  createGenerateCellsComputeShader,
  createQuadMaterial,
} from "./shaders";
import { calculateLifeCPU } from "./cpu";

const { engine, scene, camera } = await initScene();
const aspectRatio = engine.getRenderWidth() / engine.getRenderHeight();

const fpsText = document.getElementById("fpsText") as HTMLElement;
const cellsText = document.getElementById("cellsText") as HTMLElement;
const gpuToggle = document.getElementById("gpuToggle") as HTMLInputElement;
const canvas = document.getElementById("renderCanvas") as HTMLCanvasElement;
let useGpu = gpuToggle.checked;

const targetNumberOfCells = 2000000;
let height = Math.ceil(Math.sqrt(targetNumberOfCells / aspectRatio));

// Round to nearest even
height -= height % 2;
let width = Math.floor(height * aspectRatio);
width -= width % 32;
const gridWidth = width / 32;
const totalCells = width * height;
cellsText.innerText = "Cells: " + totalCells.toLocaleString();

let orthoSize = height / 128;
camera.orthoTop = orthoSize;
camera.orthoBottom = -orthoSize;
camera.orthoLeft = -orthoSize * aspectRatio;
camera.orthoRight = orthoSize * aspectRatio;

let targetZoom = orthoSize;

// Material
const quadMat = createQuadMaterial(scene);

// Compute shaders
const generateCellsComputeShader = createGenerateCellsComputeShader(engine);
const cellsComputeShader = createCellsComputeShader(engine);
const computeGroups = new Vector2(
  Math.ceil(gridWidth / 8),
  Math.ceil(height / 8)
);

// Buffers
const params = new UniformBuffer(engine);
params.addUniform("width", 1);
params.addUniform("gridWidth", 1);
params.addUniform("height", 1);
params.addUniform("zoom", 1);
params.addUniform("rngSeed", 1);
params.updateUInt("width", width);
params.updateUInt("gridWidth", gridWidth);
params.updateUInt("height", height);
params.updateFloat("zoom", orthoSize);
params.updateUInt("rngSeed", randUint());
params.update();

const bufferLength = gridWidth * height * 4;
const cellsBuffer = new StorageBuffer(engine, bufferLength);
const cellsBuffer2 = new StorageBuffer(engine, bufferLength);

// Bind buffers
generateCellsComputeShader.setUniformBuffer("params", params);
generateCellsComputeShader.setStorageBuffer("cells", cellsBuffer);
cellsComputeShader.setUniformBuffer("params", params);
quadMat.setUniformBuffer("params", params);
quadMat.setStorageBuffer("cells", cellsBuffer);

const quad = MeshBuilder.CreatePlane("plane", { size: 1 }, scene);
quad.scaling.x = width / 64;
quad.scaling.y = height / 64;
quad.material = quadMat;

// Generate cells
const cellsCpu1 = new Uint32Array(bufferLength);
const cellsCpu2 = new Uint32Array(bufferLength);
generateCellsComputeShader.dispatch(computeGroups.x, computeGroups.y, 1);

gpuToggle.onchange = async () => {
  if (!gpuToggle.checked) {
    const cellsIn = swap ? cellsCpu1 : cellsCpu2;
    const buffer = swap ? await cellsBuffer2.read() : await cellsBuffer.read();
    cellsIn.set(new Uint32Array(buffer.buffer));
  }
  useGpu = gpuToggle.checked;
};

canvas.onwheel = (e) => {
  const zoomDelta = e.deltaY * orthoSize * 0.001;
  if (targetZoom + zoomDelta > 0.2) {
    targetZoom += zoomDelta;
  }
};

canvas.onpointermove = (e) => {
  if (e.buttons) {
    camera.position.x -= e.movementX * 0.002 * orthoSize;
    camera.position.y += e.movementY * 0.002 * orthoSize;
  }
};

let swap = false;
engine.runRenderLoop(() => {
  fpsText.innerText = "FPS: " + engine.getFps().toFixed(2);
  smoothZoom();

  const cellBufferIn = swap ? cellsBuffer2 : cellsBuffer;
  const cellBufferOut = swap ? cellsBuffer : cellsBuffer2;
  if (useGpu) {
    cellsComputeShader.setStorageBuffer("cellsIn", cellBufferIn);
    cellsComputeShader.setStorageBuffer("cellsOut", cellBufferOut);
    cellsComputeShader.dispatch(computeGroups.x, computeGroups.y, 1);
  } else {
    const cellsIn = swap ? cellsCpu2 : cellsCpu1;
    const cellsOut = swap ? cellsCpu1 : cellsCpu2;
    calculateLifeCPU(cellsIn, cellsOut, totalCells, gridWidth);
    cellBufferOut.update(cellsOut);
  }

  quadMat.setStorageBuffer("cells", cellBufferOut);
  swap = !swap;
  scene.render();
});

const smoothZoom = () => {
  if (Math.abs(orthoSize - targetZoom) > 0.01) {
    const aspectRatio = engine.getAspectRatio(camera);
    orthoSize = Scalar.Lerp(orthoSize, targetZoom, 0.1);
    params.updateFloat("zoom", orthoSize);
    params.update();
    camera.orthoBottom = -orthoSize;
    camera.orthoTop = orthoSize;
    camera.orthoLeft = -orthoSize * aspectRatio;
    camera.orthoRight = orthoSize * aspectRatio;
  }
};
