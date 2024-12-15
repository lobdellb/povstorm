
# 


## Todo

- Add a container for combining the videos.
- Figure out a way to fail if one frame fails. Figure out a way to kick-off the stitch phase.
- Figure out how to make sure all frames were processed before combining.
- Surface some error messages and progress logging.
- Write howto / docs
- Write the Makefile
- Add tests, linting, blacking for python




# Pieces

- A container which renders images.
- A container which loads all the images into a single video.
- A terraform module which stands up the GCP infrastructure.
- A driver program (client) to run locally which generates string of images.
- Tests 
- Makefile for building, deploying, testing. 






# povstorm
Render POVRAY SDL to  images, then video in GCP Cloud Run.
