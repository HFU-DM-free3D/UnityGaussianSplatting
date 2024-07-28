# Gaussian Splatting Integration in Unity with Animated Pointclouds

This repository is forked from [aras-p/UnityGaussianSplatting](https://github.com/aras-p/UnityGaussianSplatting). Check there for further help.

![Screenshot](/docs/Images/shotOverview.jpg?raw=true "Screenshot")

## Usage

Download or clone this repository, open `projects/GaussianExample` as a Unity project (Unity 2022.3, other versions might also work),
and open `GSTestScene` scene in there.

Note that the project requires DX12 or Vulkan on Windows, i.e. **DX11 will not work**. This is **not tested at all on mobile/web**, and probably
does not work there.

<img align="right" src="docs/Images/shotAssetCreator.png" width="250px">

Next up, **create some GaussianSplat assets**: open `Tools -> Gaussian Splats -> Create GaussianSplatAsset` menu within Unity.
In the dialog, point `Input PLY File` to your Gaussian Splat file (note that it has to be a gaussian splat PLY file, not some 
other PLY file).

Pick desired compression options and output folder, and press "Create Asset" button. 

If everything was fine, there should be a GaussianSplat asset that has several data files next to it.

Since the gaussian splat models are quite large, there are none included in this Github repo. The original
[paper github page](https://github.com/graphdeco-inria/gaussian-splatting) has a a link to
[14GB zip](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/datasets/pretrained/models.zip) of their models.


In the game object that has a `GaussianSplatRenderer` script, **point the Asset field to** one of your created assets.

We added a plugin to handle the animated pointclouds.
We also excluded them because of their large file size.

The game object "pcd_vid" has a `Point Cloud Loader` script, **point the Json File to** one of your animated Pointclouds/Json File.
Furthermore you can choose the Animation Mode (Loop/Boomerang).

We prepared multiple [Gaussian Splat Assets](https://bwsyncandshare.kit.edu/s/pR2k8AjnxjQeaeq) and created corresponding Dolly Tracks.
- Choose desired GS Asset and activate the corresponding game object in the hierachy
- Click on Dolly Cam game object in the hierarchy and navigate in the Inspector to `CinemachineVirtualCamera -> Body -> Path`
- Pick the Dolly Track that is named according to your GS Asset
- Open the Unity Recorder `Window -> General -> Recorder -> Recorder Window`
- Add Recorder (Movie)
- Choose desired settings and export your e.g. .mp4 file

## 

_That's it!_


## License and External Code Used

The code [aras-p](https://github.com/aras-p) wrote for this is under MIT license. The project also uses several 3rd party libraries:

- [zanders3/json](https://github.com/zanders3/json), MIT license, (c) 2018 Alex Parker.
- "DeviceRadixSort" GPU sorting code contributed by Thomas Smith ([#82](https://github.com/aras-p/UnityGaussianSplatting/pull/82)).

However, keep in mind that the [license of the original paper implementation](https://github.com/graphdeco-inria/gaussian-splatting/blob/main/LICENSE.md)
says that the official _training_ software for the Gaussian Splats is for educational / academic / non-commercial
purpose; commercial usage requires getting license from INRIA. That is: even if this viewer / integration
into Unity is just "MIT license", you need to separately consider *how* did you get your Gaussian Splat PLY files.
