## Import packages
import pandas as pd
import json
import os
import argparse
import nibabel as nib
import numpy as np
import pystrum.pynd.ndutils as nd

def jacobian_determinant(disp):
    """
    jacobian determinant of a displacement field.
    NB: to compute the spatial gradients, we use np.gradient.

    Parameters:
        disp: 2D or 3D displacement field of size [*vol_shape, nb_dims], 
              where vol_shape is of len nb_dims

    Returns:
        jacobian determinant (scalar)
    """

    # check inputs
    volshape = disp.shape[:-1]
    nb_dims = len(volshape)
    assert len(volshape) in (2, 3), 'flow has to be 2D or 3D'

    # compute grid
    grid_lst = nd.volsize2ndgrid(volshape)
    grid = np.stack(grid_lst, len(volshape))

    # compute gradients
    J = np.gradient(disp + grid)

    # 3D glow
    if nb_dims == 3:
        dx = J[0]
        dy = J[1]
        dz = J[2]

        # compute jacobian components
        Jdet0 = dx[..., 0] * (dy[..., 1] * dz[..., 2] - dy[..., 2] * dz[..., 1])
        Jdet1 = dx[..., 1] * (dy[..., 0] * dz[..., 2] - dy[..., 2] * dz[..., 0])
        Jdet2 = dx[..., 2] * (dy[..., 0] * dz[..., 1] - dy[..., 1] * dz[..., 0])

        return Jdet0 - Jdet1 + Jdet2

    else:  # must be 2

        dfdx = J[0]
        dfdy = J[1]

        return dfdx[..., 0] * dfdy[..., 1] - dfdy[..., 0] * dfdx[..., 1]

def calc_jacobian(f_in, f_def, f_out):
    # Read image
    nii = nib.load(f_in)
    img = nii.get_fdata()

    nii_d = nib.load(f_def)
    img_d = nii_d.get_fdata()
    
    # Calculate jacobian
    jac = jacobian_determinant(img_d)
    
    # Save image
    nii_out = nib.Nifti1Image(jac, nii.affine)
    nib.save(nii_out, f_out)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-i", "--in_img", help="Input image name", required=True
    )
    parser.add_argument(
        "-d", "--in_def", help="Input image name", required=True
    )
    parser.add_argument(
        "-o", "--out_img", help="Output image name", required=True
    )
    options = parser.parse_args()

    # Run pipeline
    print(f"Running: .....")
    calc_jacobian(options.in_img, options.in_def, options.out_img)
    print("Pipeline complete!")
