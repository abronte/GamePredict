#!/bin/bash

ffmpeg -i $1 -f image2 -vf fps=0.5 screens/$2/$1_%d.jpg
