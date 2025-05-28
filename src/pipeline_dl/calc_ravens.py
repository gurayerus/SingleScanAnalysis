## Import packages
import pandas as pd
import json
import os
import argparse
import nibabel as nib
import numpy as np
import pystrum.pynd.ndutils as nd

def calc_ravens(f_jac, f_seg, label, f_out):
    # Read images
    nii_jac = nib.load(f_jac)
    img_jac = nii_jac.get_fdata()
    
    nii_seg = nib.load(f_seg)
    img_seg = nii_jac.get_fdata()
    
    # Make mask for label
    mask = int(img_seg[img_seg==label])
    
    # Calculate ravens
    ravens = img_jac * mask
    
    # Save image
    nii_out = nib.Nifti1Image(ravens, nii_jac.affine)
    nib.save(nii_out, f_out)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-j", "--in_jac", help="Input jacobian image", required=True
    )
    parser.add_argument(
        "-s", "--in_seg", help="Input segmentation image", required=True
    )
    parser.add_argument(
        "-l", "--label", help="Selected segmentation label", required=True
    )
    parser.add_argument(
        "-o", "--out_img", help="Output image name", required=True
    )
    options = parser.parse_args()

    # Run pipeline
    print(f"Running: .....")
    calc_jacobian(options.in_jac, options.in_seg, options.label, options.out_img)
    print("Pipeline complete!")
