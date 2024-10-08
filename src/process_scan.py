## Import packages
import pandas as pd
import json
import os
import argparse
import utils_mri as utilmri

suff_lps = '_T1_LPS.nii.gz'
suff_icv = '_T1_DLICV.nii.gz'
suff_seg = '_T1_Seg.nii.gz'

def run_pipeline(mrid, in_img, out_dir):
    
    # Reorient image
    out_img = os.path.join(out_dir, mrid, mrid + '_')
    utilmri.reorient_img(in_img, 'LPS', out_img)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mrid", help="Provide the mrid", required=True
    )
    parser.add_argument(
        "--in_img", help="Provide the path to input image", required=True
    )
    parser.add_argument(
        "--out_dir", help="Provide the path to output dir", required=True
    )
    options = parser.parse_args()

    # Create out dir
    if not os.path.exists(options.out_dir):
        os.makedirs(options.out_dir)

    # Run pipeline
    print(f"Running: .....")
    run_pipeline(options.mrid, options.in_img, options.out_dir)
    print("Pipeline complete!")
