## Import packages
import pandas as pd
import json
import os
import argparse
import utils_mri as utilmri
import nibabel as nib


## https://antspy.readthedocs.io/en/latest/_modules/ants/registration/create_jacobian_determinant_image.html


#def label_to_image():
    

def run_pipeline(sub_id, sub_img, ref_id, ref_img, out_dir):

    NUMTHD = 4

    for tmp_id, tmp_img in [[sub_id, sub_img], [ref_id, ref_img]]:
        
        # Reorient images
        print('Reorienting image ...')
        out_sub = os.path.join(out_dir, 'reoriented', tmp_id)
        if not os.path.exists(out_sub):
            os.makedirs(out_sub)
        out_reorient = os.path.join(out_sub, tmp_id + '_T1_LPS.nii.gz')
        if not os.path.exists(out_reorient):
            utilmri.reorient_img(tmp_img, 'LPS', out_reorient)
        else:
            print(f'Out file exists, skip: {out_reorient}')

        # Segment image
        print('Segmenting image ...')
        out_sub = os.path.join(out_dir, 'segmented', tmp_id)
        if not os.path.exists(out_sub):
            os.makedirs(out_sub)
        out_seg = os.path.join(out_sub, tmp_id + '_Seg.nii.gz')
        out_qc = os.path.join(out_sub, tmp_id + '_Seg_QC.csv')
        out_vol = os.path.join(out_sub, tmp_id + '_Seg_Vol.csv')
        out_post = os.path.join(out_sub, tmp_id + '_Seg_Post.nii.gz')
        out_resample = os.path.join(out_sub, tmp_id + '_Seg_Resample.nii.gz')
        cmd = f'mri_synthseg --i {out_reorient} --o {out_seg} --robust --vol {out_vol} --qc {out_qc} --resample {out_resample} --threads {NUMTHD} --cpu'
        if not os.path.exists(out_seg):
            print(f'About to run: {cmd}')
            os.system(cmd)
        else:
            print(f'Out file exists, skip: {out_seg}')    

    # Register image to atlas (affine)
    moving = os.path.join(out_dir, 'reoriented', sub_id, f'{sub_id}_T1_LPS.nii.gz')
    fixed = os.path.join(out_dir, 'reoriented', ref_id, f'{ref_id}_T1_LPS.nii.gz')
    out_sub = os.path.join(out_dir, 'warped', sub_id)
    if not os.path.exists(out_sub):
        os.makedirs(out_sub)
    moved = os.path.join(out_sub, sub_id + '_WarpedAffine.nii.gz')
    trans = os.path.join(out_sub, sub_id + '_Trans.txt')
    cmd = f'mri_synthmorph --moved {moved} --trans {trans} --model affine --threads {NUMTHD} {moving} {fixed}'
    print(f'About to run: {cmd}')
    os.system(cmd)


    # Register image to atlas (def)
    moving = moved
    moved = os.path.join(out_sub, sub_id + '_WarpedDef.nii.gz')
    trans = os.path.join(out_sub, sub_id + '_Trans.nii.gz')
    cmd = f'mri_synthmorph --moved {moved} --trans {trans} --model deform --threads {NUMTHD} {moving} {fixed}'
    print(f'About to run: {cmd}')
    os.system(cmd)

    # Create label image
    

    ##### Apply def to image
    #mri_warp_convert --inras 002_S_0295_2006-04-18_synthmorph_TransDef.nii.gz --outm3z out.m3z --insrcgeom 002_S_0295_2006-04-18_synthmorph_WarpedAffine.nii.gz

    #mri_convert --apply_transform out.m3z 002_S_0295_2006-04-18_synthmorph_WarpedAffine.nii.gz tmp12.nii.gz

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--sid", help="Provide the subject id", required=True
    )
    parser.add_argument(
        "--simg", help="Provide the path to subject image", required=True
    )
    parser.add_argument(
        "--rid", help="Provide the reference id", required=True
    )
    parser.add_argument(
        "--rimg", help="Provide the path to reference image", required=True
    )
    parser.add_argument(
        "--out_dir", help="Provide the path to output dir", required=True
    )
    options = parser.parse_args()

    # Run pipeline
    print(f"Running: .....")
    run_pipeline(options.sid, options.simg, options.rid, options.rimg, options.out_dir)
    print("Pipeline complete!")
