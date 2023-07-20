#!/bin/bash
squeue > ~/bin/analyser/data.txt
python ~/bin/analyser/analyze.py > ~/bin/analyser/output.txt
cat ~/bin/analyser/output.txt
