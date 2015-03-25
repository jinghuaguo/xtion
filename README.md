Xtion Record
============

This repo contains everything you need to capture an Xtion point cloud (or kinect) sequence to an ONI file, with the possibility to extract each frames to PLY file format.
A C++ script is also present to convert PLY to PRT files, importable in Krakatoa.

Requirements
------------

* [Processing 2.x](https://processing.org/)
* [OpenNI](https://code.google.com/p/simple-openni/downloads/list?can=1&q=&colspec=Filename+Summary+Uploaded+ReleaseDate+Size+DownloadCount) can be installed through this installer
* [SimpleOpenNI](https://code.google.com/p/simple-openni/wiki/Installation)
* [g++](http://www.cprogramming.com/g++.html) (on windows use CodeBlocks)

How to
------

When SimpleOpenNI examples work, you can open ```xtion_record.pde``` file.

Line 3 you have to choose which mode you want by setting ```IS_RECORDING_MOD``` variable : true for recording or false for playing.

Recording will save an ONI file while playing will replay a recorded ONI file.

When in recording mod, the following keyboard keys are usable :
- a to decrease MAX Z threeshold
- z to increase MAX Z threeshold
- q to decrease MIN Z threeshold
- s to increase MIN Z threeshold
- o to increase the captured number of points (heavily affects performance)
- p to deacrease the captured number of points

Arrows could be used to move viewport.

When everything is correctly parameted, you can press SPACE BAR to finish the record (needed to save the total frame number !).

Then, you have to switch the mod by setting ```IS_RECORDING_MOD``` to false.
You will be able to view your record.

Press SPACE BAR to convert each frame to PLY files (it can take some times depending on captured point number you choosed).

Convert to PRT
--------------

A small C++ script is also present to allow conversion of PLY to PRT files.
First you have to compile the script with the following command (-lz parameters for zlib flag) :
```g++ -lz ply_to_prt.cpp```

Then, execute it with (on OSX) :
```./a.out```

If you run out of memory, simply increase CHUNK variable by setting an higher number.
