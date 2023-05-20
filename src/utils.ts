import { Scene, UniversalCamera, Vector3, WebGPUEngine } from "@babylonjs/core";

export const initScene = async () => {
  const canvas = document.getElementById("renderCanvas") as HTMLCanvasElement;
  canvas.onpointerdown = () => {
    canvas.requestPointerLock();
  };

  canvas.onpointerup = () => {
    document.exitPointerLock();
  };

  const engine = new WebGPUEngine(canvas, {
    setMaximumLimits: true,
    enableAllFeatures: true,
  });
  await engine.initAsync();

  const scene = new Scene(engine);
  scene.clearColor.set(0, 0, 0, 1);

  const camera = new UniversalCamera("camera", new Vector3(0, 0, -10), scene);
  camera.mode = UniversalCamera.ORTHOGRAPHIC_CAMERA;

  return { engine, scene, camera };
};

export const randUint = () => {
  return (Math.random() * 4294967296) >>> 0;
};
