#diffpng

Compare two .png image files based on Hector Yee's PerceptualDiff algorithm

Based on his paper "Perceptual Metric for Production Testing", 2004/1/1, Journal of Graphics Tools

###hows it work?

Consider these two images. One has green inner walls, the other does not. 
Percpetually, to the human eye, they are different. 

![OpenSCAD Color example](/test/basic/ossphere_color2.png "OpenSCAD Color")
![OpenSCAD Monotone example](/test/basic/ossphere_mono.png "OpenSCAD Monotone")

We can compare these two images using diffpng as follows:

    diffpng img1.png img2.png --output diff.png

The program will print a text message indicating the images are 
different. 

    FAIL: Images are visibly different

(If they had been similar, it would say "PASS: Images are roughly the same")

The program will also produce an image highlighting the differences. 
The resulting diff.png looks like this: (black=same, red=difference)

![diffpng result](/test/basic/diffpng_example.png "diffpng example")

###build & install

diffpng consists of a single file, diffpng.cpp. It can be used by
itself to generate an executable, or it can be used as a header file
in another program.

Executable:

    # Get Cmake (http://www.cmake.org)
    mkdir bin && cd bin && cmake ..
    ctest # run regression tests
    cp ./diffpng /wherever/you/want

As header:

Imagine you have a program 'myprogram.cpp'. Put these two lines at the top.

    #define DIFFPNG_HEADERONLY
    #include "diffpng.cpp"

Now call diffpng using the same method used in main() at the bottom of the file.
(Note your program will also need lodepng)

###usage

    diffpng image1.png image2.png --output diff.png

    for other options, run diffpng --help

###license

* Copyright (C) 2006-2011 Yangli Hector Yee (PerceptualDiff)
* Copyright (C) 2011-2014 Steven Myint (PerceptualDiff)
* Copyright (C) 2014 Don Bright

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details in the
file LICENSE

###design philosophy

1. simple
2. portable
3. no dependencies
4. small
5. regression tests

practical effects of philosophy:

1. use very plain C++, in the style of python or Go. 
   avoid exceptions, pointers, stdc++0, 'auto', etc.
2. as few files as possible (one, plus two for lodepng)
3. make default settings so it 'just works' for most ordinary situations
4. regression test images take up several megabytes (under test/ dir)

###todo

clarify issue with chroma vs luminance. . . do color swatches produce diffs?
can we use colorfactor 0.1 or 0.05? 

should tiny speckled pixels count as 'different'?

clarify the 'default settings' vs what settings user can alter.

windows unicode filenames

###credits

For the original PerceptualDiff (PDiff):

* Hector Yee, author of original PerceptualDiff. http://hectorgon.blogspot.com
* Steven Myint, major fork. https://github.com/myint/perceptualdiff 
* PerceptualDiff contributors: Scott Corley, Tobias Sauerwein, Cairo Team, Jim Tilander, Jeff Terrace
* PDiff's Threshold vs Intensity function, Ward Larson Siggraph 1997
* PDiff's Contrast sensitivity function, Barten SPIE 1989
* PDiff's Visual Masking Function, Daly 1993
* PDiff's Adobe(TM) RGB->XYZ matrix from http://www.brucelindbloom.com/
* PDiff's ABGR format, http://partners.adobe.com/asn/developer/PDFS/TN/TIFF6.pdf

For diffpng:

* Lode Vandevenne's lodepng. http://lodev.org/lodepng/
* OpenSCAD regression test images http://github.com/openscad/openscad/tests
