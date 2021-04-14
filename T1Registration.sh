#!/bin/bash

#register Adult MNI atlas to pediatric NIHPD atlas (ages 4.5-18.5)
# antsRegistrationSyN.sh -d 3 -f atlas/nihpd_originZero.nii -m atlas/mni1mm.nii.gz -o transformations/MNIToPeds_

T1Files=NIHPD_V1_Images/T1Images/'*'

for f in $T1Files; 
    do 
        T1PatientFileName=$(basename $f); 
        id=$( cut -d_ -f 2 <<< "$T1PatientFileName"); 
        echo Patient ID: $id; 
        echo Patient T1 Image: $T1PatientFileName;

        #set direction cosine matrix of T1 image to the same as the atlas (T1 dr mtx is not identity, cannot register if not the same)
        CopyImageHeaderInformation atlas/nihpd_originZero.nii NIHPD_V1_Images/T1Images/$T1PatientFileName NIHPD_V1_Images/T1Images/${id}_T1_dirMtxI.nii.gz 1 1 1;

        #register pediatric atlas (origin set to zero) with each patient T1 image using the pediatric brain mask as the moving image mask
        antsRegistrationSyNQuick.sh -d 3 -f NIHPD_V1_Images/T1Images/${id}_T1_dirMtxI.nii.gz -m atlas/nihpd_originZero.nii -o transformations/PedsToT1_${id}_ \
                    -x NULL,nihpd_mask_originZero.nii;

        #apply transform from previous registration (NIHPD atlas to T1) to transform template mask into patient specific mask
        #for use when registering T1 image to DTI images
        antsApplyTransforms -d 3 -i nihpd_mask_originZero.nii -r NIHPD_V1_Images/T1Images/${id}_T1_dirMtxI.nii.gz \
                    -o masks/${id}_nihpd_mask_transformed.nii.gz -n NearestNeighbor -t transformations/PedsToT1_${id}_1Warp.nii.gz \
                    -t transformations/PedsToT1_${id}_0GenericAffine.mat -v 1;

        #skull-strip T1 images using patient specific mask (format: dimensions (3), output T1, multiply (m), inputs: T1 image, transformed mask)
        ImageMath 3 NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz m NIHPD_V1_Images/T1Images/${id}_T1_dirMtxI.nii.gz masks/${id}_nihpd_mask_transformed.nii.gz;
        
        #flip x, y axis of skull stripped T1 so they are in the same orientation as atlas images 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz 0 1 2 1 1 0;

        echo "T1 registration for patient $id done, starting next patient";

    done