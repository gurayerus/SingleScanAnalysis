import os
from typing import Any
import nibabel as nib
import pandas as pd
from nibabel.orientations import axcodes2ornt, ornt_transform
import pystrum.pynd.ndutils as nd

IMG_EXT = ".nii.gz"

def reorient_img(in_img: Any, ref: Any, out_img: Any) -> None:
    '''
    Reorient image
    '''
    if os.path.exists(out_img):
        print("Out file exists, skip reorientation ...")

    else:
        # Read input img
        nii_in = nib.load(in_img)

        # Detect target orient
        if len(ref) == 3:
            ref_orient = ref
        else:
            nii_ref = nib.load(ref)
            ref_orient = nib.aff2axcodes(nii_ref.affine)
            ref_orient = "".join(ref_orient)

        # Find transform from current (approximate) orientation to
        # target, in nibabel orientation matrix and affine forms
        orient_in = nib.io_orientation(nii_in.affine)
        orient_out = axcodes2ornt(ref_orient)
        transform = ornt_transform(orient_in, orient_out)
        # affine_xfm = inv_ornt_aff(transform, nii_in.shape)

        # Apply transform
        reoriented = nii_in.as_reoriented(transform)

        # Write to out file
        reoriented.to_filename(out_img)


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
