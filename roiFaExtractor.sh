#!/bin/bash -p 

# Gets the roi mask file name
read -p "Please specify the name of the roi mask: " roiMaskFile

echo "Thresholding the stat1 images by 0.95"
# This is to threshold the stat1 file
fslmaths tbss_tfce_corrp_tstat1.nii.gz -thr 0.95 -bin significant_thresholded_stat1

echo "Generating FA values text file for the whole brain connectivity"
# This is to extract significant FA values for the whole brain for all subjects
fslmeants -i all_FA_skeletonised.nii.gz -m significant_thresholded_stat1.nii.gz -o signi_FA_forallmysubs.txt

echo "Applying the roi mask to the thresholded stat1 images"
# This masks the significant_thresholded_stat1 using the given mask
fslmaths significant_thresholded_stat1.nii.gz -mul $roiMaskFile significant_thresholded_stat1_roiMasked.nii.gz

echo "Generating FA values text file for the roi-masked thresholded stat1 image"
# This generates the FA values for all subjects for the given roi
fslmeants -i all_FA_skeletonised.nii.gz -m significant_thresholded_stat1_roiMasked.nii.gz -o signi_FA_forallmysubs_roi.txt
