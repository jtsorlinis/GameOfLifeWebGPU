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
const bigToggle = document.getElementById("bigToggle") as HTMLInputElement;
const zoomOutText = document.getElementById("zoomOut") as HTMLElement;
const canvas = document.getElementById("renderCanvas") as HTMLCanvasElement;
let useGpu = gpuToggle.checked;

const cpuCells = 1000000;
const gpuCells = 4000000000;

let totalCells: number;
let gridWidth: number;
let cellsCpu1: Uint32Array;
let cellsCpu2: Uint32Array;
let cellsBuffer: StorageBuffer;
let cellsBuffer2: StorageBuffer;
let computeGroups: Vector2;
let orthoSize: number;
let targetZoom: number;
let swap: boolean;
let targetNumberOfCells = cpuCells;

// params
const params = new UniformBuffer(engine);
params.addUniform("width", 1);
params.addUniform("gridWidth", 1);
params.addUniform("height", 1);
params.addUniform("zoom", 1);
params.addUniform("rngSeed", 1);

// Compute shaders
const generateCellsComputeShader = createGenerateCellsComputeShader(engine);
generateCellsComputeShader.setUniformBuffer("params", params);
const cellsComputeShader = createCellsComputeShader(engine);
cellsComputeShader.setUniformBuffer("params", params);

// Material
const quadMat = createQuadMaterial(scene);
quadMat.setUniformBuffer("params", params);

// Mesh
const quad = MeshBuilder.CreatePlane("plane", { size: 1 }, scene);
quad.material = quadMat;

// Setup camera
camera.position.x = 0;
camera.position.y = 0;
orthoSize = Math.floor(Math.sqrt(cpuCells / aspectRatio)) / 128 + 0.25;
targetZoom = orthoSize;
camera.orthoTop = orthoSize;
camera.orthoBottom = -orthoSize;
camera.orthoLeft = -orthoSize * aspectRatio;
camera.orthoRight = orthoSize * aspectRatio;
const maxZoom = Math.floor(Math.sqrt(gpuCells / aspectRatio)) / 128;

const setup = () => {
  // Calculate cell count based on target number of cells
  let height = Math.floor(Math.sqrt(targetNumberOfCells / aspectRatio));

  // Round up to nearest even number
  height -= (height % 2) - 2;
  let width = Math.floor(height * aspectRatio);
  // Round up to nearest multiple of 32
  width -= (width % 32) - 32;
  gridWidth = width / 32;
  totalCells = width * height;
  cellsText.innerText = "Cells: " + totalCells.toLocaleString();

  // Scale quad to fit cells
  quad.scaling.x = width / 64;
  quad.scaling.y = height / 64;

  // Calculate compute dispatches
  computeGroups = new Vector2(Math.ceil(gridWidth / 8), Math.ceil(height / 8));

  // Update params
  params.updateUInt("width", width);
  params.updateUInt("gridWidth", gridWidth);
  params.updateUInt("height", height);
  params.updateFloat("zoom", orthoSize);
  params.updateUInt("rngSeed", randUint());
  params.update();

  // Create arrays and buffers
  const bufferLength = gridWidth * height * 4;
  if (targetNumberOfCells === cpuCells) {
    cellsCpu1 = new Uint32Array(bufferLength);
    cellsCpu2 = new Uint32Array(bufferLength);
  }
  cellsBuffer = new StorageBuffer(engine, bufferLength);
  cellsBuffer2 = new StorageBuffer(engine, bufferLength);

  // Bind buffers
  generateCellsComputeShader.setStorageBuffer("cells", cellsBuffer);
  quadMat.setStorageBuffer("cells", cellsBuffer);

  // Generate cells
  generateCellsComputeShader.dispatch(computeGroups.x, computeGroups.y, 1);
  swap = false;
};

setup();

gpuToggle.onchange = async () => {
  if (!gpuToggle.checked) {
    const cellsIn = swap ? cellsCpu1 : cellsCpu2;
    const buffer = swap ? await cellsBuffer2.read() : await cellsBuffer.read();
    cellsIn.set(new Uint32Array(buffer.buffer));
  }
  useGpu = gpuToggle.checked;
  bigToggle.disabled = !useGpu;
};

bigToggle.onchange = () => {
  cellsBuffer.dispose();
  cellsBuffer2.dispose();
  targetNumberOfCells = bigToggle.checked ? gpuCells : cpuCells;
  gpuToggle.disabled = bigToggle.checked;
  if (bigToggle.checked) {
    zoomOutText.style.display = "block";
    setTimeout(() => {
      zoomOutText.style.opacity = "0";
    }, 2000);
  }
  setup();
};

canvas.onwheel = (e) => {
  const zoomDelta = e.deltaY * orthoSize * 0.001;
  targetZoom += zoomDelta;
  targetZoom = Math.min(Math.max(targetZoom, 0.2), maxZoom + 20);
};

canvas.onpointermove = (e) => {
  if (e.buttons) {
    camera.position.x -= e.movementX * 0.002 * orthoSize;
    camera.position.y += e.movementY * 0.002 * orthoSize;
  }
};

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
