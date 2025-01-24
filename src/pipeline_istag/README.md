Overview:
- This folder keeps a copy of scripts on CBICA cluster from different parts of the CSF-RAVENS pipelines
- The scripts are provided here to provide guidance
- They will not run directly as the data is not provided

Data:
- CSF_RAVENS: Steps for creating CSF RAVENS maps from initial T1 images 
    - Reorient T1 image to LPS
    - Calculate DLICV
    - Segment tissues using FAST
    - Calculate RAVENS
- zCSF maps:
    - Identify reference subjects that match the target subject (by age,sex)
    - Calculate z-scored ROI values
    - Calculate z-scored RAVENS maps
    
