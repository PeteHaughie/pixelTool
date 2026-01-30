# Readme Developer Guide

This document provides guidelines and instructions for developers who wish to contribute to the project. It covers the development environment setup, coding standards, and contribution process.

# Early Decisions

Use of ADRs (Architecture Decision Records) has been adopted to document significant architectural decisions made during the development of this project. ADRs help in maintaining a clear record of the reasoning behind decisions, alternatives considered, and their implications.

Currently the choice of development framework is Processing for its ease of use and rapid prototyping capabilities, especially suited for graphical applications like pixel art editors. However one suspects that we will pivot to openFrameworks for performance and ease of migration and its ability to create standalone applications.

All assets are to be stored in the `data/` directory as per Processing (and oF) conventions.

# Definitions

- **Pixel Art**: A form of digital art where images are created and edited at the pixel level.
- **Layers**: Separate levels within an image that can be edited independently.
- **Onion Skinning**: A technique used in animation to see multiple frames at once, allowing for better frame-to-frame continuity.
- **Canvas**: The area where pixel art is created and edited.
- **Tools**: Various instruments available in the application for creating and editing pixel art (e.g., pencil, eraser, fill).

What is a pixel? A pixel, short for "picture element," is the smallest unit of a digital image or graphic that can be displayed and represented on a digital display device. Pixels are the building blocks of images, and each pixel contains information about its color and brightness. In the context of pixel art, artists manipulate individual pixels to create detailed and stylized images, often with a retro or nostalgic aesthetic. In the context of pixelTool, a pixel is a description of a single square on the canvas that can be assigned a specific color value - or a vector containing an x, y coordinate, and a colour value.