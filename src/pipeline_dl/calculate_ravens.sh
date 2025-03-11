#!/bin/bash

# Parse command-line arguments
while getopts "s:i:t:o:" opt; do
  case "$opt" in
    s)
      mrid="$OPTARG"
      ;;
    i)
      in_img="$OPTARG"
      ;;
    t)
      templ_img="$OPTARG"
      ;;
    o)
      out_dir="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

# Shift off the parsed options
shift $((OPTIND-1))

# Function to display usage information
usage() {
  echo "Usage: $(basename "$0") -s <mrid> -i <in_img> -t <templ_img> -o <out_dir>"
  echo "  -s <mrid>  The scan MRID."
  echo "  -i <in_img>  The input T1 image file name."
  echo "  -t <templ_img>  The template image file name."
  echo "  -o <out_dir> The output dir"
}
    
# Check if all required arguments are provided
if [ -z "$mrid" ] || [ -z "$in_img" ] || [ -z "$templ_img" ] || [ -z "$out_dir" ]; then
  usage
  exit 1
fi


echo "MRID: $mrid"
echo "Input image: $in_img"
echo "Template image: $templ_img"
echo "Output dir: $out_dir"

# Check input
if [ ! -e $in_img ]; then
    echo "Input image is not existing!"
    return;
fi
if [ ! -e $templ_img ]; then
    echo "Template image is not existing!"
    return;
fi

# Copy input image to output
mkdir -pv ${out_dir}/init
bname=`basename $in_img`
dname=`dirname $in_img`
if [ ! -e ${out_dir}/init/${bname} ]; then
    ln -sv $in_img ${out_dir}/init/${bname}
fi
in_img=${out_dir}/init/${bname}

# Copy template image to output
bname=`basename $templ_img`
dname=`dirname $templ_img`
if [ ! -e ${out_dir}/init/${bname} ]; then
    ln -sv $templ_img ${out_dir}/init/${bname}
fi
templ_img=${out_dir}/init/${bname}

read -p eee

# Segment image
mkdir -pv ${out_dir}/segment
NUMTHD=4
out_sg="${out_dir}/segment/${mrid}_Seg.nii.gz"
out_qc="${out_dir}/segment/${mrid}_Seg_QC.nii.gz"
out_vl="${out_dir}/segment/${mrid}_Seg_Vol.nii.gz"
out_pt="${out_dir}/segment/${mrid}_Seg_Post.nii.gz"
out_rs="${out_dir}/segment/${mrid}_Seg_Resample.nii.gz"

if [ ! -e $out_sg ]; then
    cmd="mri_synthseg --i $in_img --o $out_sg --robust --vol $out_vl --qc $out_qc --resample $out_rs --threads $NUMTHD --cpu"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip segmentation: $out_sg"
fi

# Register to atlas (affine)
mkdir -pv ${out_dir}/register
in_mv="${in_img}"
in_fx="${templ_img}"
out_md="${out_dir}/register/${mrid}_WarpedAffine.nii.gz"
out_tr="${out_dir}/register/${mrid}_TransAffine.txt"
if [ ! -e $out_md ]; then
    cmd="mri_synthmorph --moved $out_md --trans $out_tr --model affine --threads $NUMTHD $in_mv $in_fx"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip linear registration: $out_sg"
fi

# Register to atlas (deformable)
in_mv="${out_md}"
out_md="${out_dir}/register/${mrid}_WarpedDef.nii.gz"
out_tr="${out_dir}/register/${mrid}_TransDef.nii.gz"
if [ ! -e $out_md ]; then
    cmd="mri_synthmorph --moved $out_md --trans $out_tr --model deform --threads $NUMTHD $in_mv $in_fx"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip linear registration: $out_sg"
fi
   
# Warp labels to atlas 
in_img="${out_dir}/register/${mrid}_TransDef.nii.gz"
out_jac="${out_dir}/register/${mrid}_JacDet.nii.gz"
if [ ! -e $out_jac ]; then
    cmd="calc_jacobian -i $in_def -o $out_jac"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip linear registration: $out_sg"
fi

# # ##### Apply def to image
# # #mri_warp_convert --inras 002_S_0295_2006-04-18_synthmorph_TransDef.nii.gz --outm3z out.m3z --insrcgeom 002_S_0295_2006-04-18_synthmorph_WarpedAffine.nii.gz
# # #mri_convert --apply_transform out.m3z 002_S_0295_2006-04-18_synthmorph_WarpedAffine.nii.gz tmp12.nii.gz

# Calculate jacobian determinant
in_def="${out_dir}/register/${mrid}_TransDef.nii.gz"
out_jac="${out_dir}/register/${mrid}_JacDet.nii.gz"
if [ ! -e $out_jac ]; then
    cmd="calc_jacobian -i $in_def -o $out_jac"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip linear registration: $out_sg"
fi

# Calculate RAVENS map
in_jac="${out_dir}/register/${mrid}_JacDet.nii.gz"
in_seg="${out_dir}/register/${mrid}_seg_warped.nii.gz"
in_label='1'
out_rv="${out_dir}/register/${mrid}_ravens_${in_label}.nii.gz"
if [ ! -e $out_rv ]; then
    cmd="calc_ravens -j $in_jac -s $in_seg -r $in_label -o $out_rv"
    echo "About to run $cmd"
    $cmd
else
    echo "Out image exists, skip ravens map calculation: $out_rv"
fi
