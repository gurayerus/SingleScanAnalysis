#! /bin/bash

sid='Img1'
simg='../test/input/Img1_T1.nii.gz'
rid='Img2'
rimg='../test/input/Img2_T1.nii.gz'
out_dir='../test/output/Test2'

python process_scan.py --sid $sid --simg $simg --rid $rid --rimg $rimg --out_dir $out_dir

# >>>>>>>
# ipython
# run process_scan.py -m Sub1 -i ../test/input/Img1_T1.nii.gz  -o ../test/output/test1
