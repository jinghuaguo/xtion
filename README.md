Xtion
=====

Working in OSX Yosemite environment, I have not been able to use openframeworks with my Xtion device (ofxKinect does not work wit it, ofxOpenNI does not work with latest openframeworks version).

This repo contains everything you need to capture an Xtion point cloud (or kinect) sequence to an ONI file, with the possibility to extract each frames to PLY file format.
A C++ script is present to convert PLY to PRT files, importable in Krakatoa.

It as been used on OSX using Yosemite.

Requirements
------------

* [Processing 1.5.x](https://processing.org/)
* [OpenNI](https://code.google.com/p/simple-openni/downloads/list?can=1&q=&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount) can be installed through this installer
* [SimpleOpenNI 0.27](https://code.google.com/p/simple-openni/wiki/Installation)

How to
------

When SimpleOpenNI examples work, you can open ```xtion_record.pde``` file.

Recording will save an ONI file while playing will replay a recorded ONI file.

The following keyboard keys are usable :
- a to decrease MAX Z threeshold
- z to increase MAX Z threeshold
- q to decrease MIN Z threeshold
- s to increase MIN Z threeshold
- o to increase the captured number of points (heavily affects performance)
- p to deacrease the captured number of points

Arrows could be used to move viewport.

Press SPACE BAR to finish the record (needed to save the total frame number !).

Using xtion_replay, you will be able to view your record.

If everything looks good, move to xtion_ply folder programm to convert each frame to PLY files (it can take some times depending on captured point number parameter you choosed).

Convert to PRT
--------------

A small C++ script is also present to allow conversion of PLY to PRT files.
First you have to compile the script with the following command (-lz parameters for zlib flag) :
```g++ -lz ply_to_prt.cpp```

Then, execute it with ```./a.out```

If you run out of memory, simply increase CHUNK variable by setting an higher number.
