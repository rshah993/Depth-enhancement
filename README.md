# Depth-enhancement
This project is based on the paper "Color-Guided Depth Recovery From RGB-D Data Using an Adaptive Autoregressive Model" by J. Yang, et. al. given in https://ieeexplore.ieee.org/document/6827958/

Cheap equipment like Kinect provides such detailed depth map in real time, which also has a large support community to cooperate with. It uses the principle of active stereo through structured infrared light, while it also provides normal colored pictures. The problem is that when it encounters surfaces that distract infrared light, the projected infrared light cannot be detected which could cause severe depth pixel degradation. It is critical to recover the missing information to improve the quality of depth map.

We use a unified depth recovery framework with a color-guided Autoregressive (AR) model to predict the characteristics of RGBD data. We use an adaptive AR predictor which is a pixel wise operator based on the non-local means of the color image and the depth map.

# How-to
Run the file depth_enhance.m in MATLAB. 
The program generates large .mat files so beware of the large files.
