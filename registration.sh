#!/bin/bash

antsRegistrationSyNQuick.sh -d 3 -f atlas/nihpd_originZero.nii -m atlas/mni1mm.nii.gz -o transformations/MNIToPeds_

for f in $FAFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo $id; 
        T1PatientFile=$( find T1/ -name "*$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        echo $T1PatientFileName; 
        CopyImageHeaderInformation atlas/nihpd_originZero.nii T1/$T1PatientFileName T1/${id}_T1_dirMtxI.nii.gz 1 1 1;

        antsRegistrationSyNQuick.sh -d 3 -f T1/${id}_T1_dirMtxI.nii.gz -m atlas/nihpd_originZero.nii -o transformations/PedsToT1_${id}_ \
        -x NULL,nihpd_mask_originZero.nii;

        antsApplyTransform -d 3 -i nihpd_mask_originZero.nii -r T1/${id}_T1_dirMtxI.nii.gz \
                    -o masks/${id}_nihpd_mask_transformed.nii.gz -n NearestNeighbor -t transformations/PedsToT1_${id}_1Warp.nii.gz \
                    -t transformations/PedsToT1_${id}_0GenericAffine.mat -v 1;

        FAPatientFile=$( find FA/ -name "*$id*"); FAPatientFileName=$(basename $FAPatientFile); 
        echo $FAPatientFileName; 

        PermuteFlipImageOrientationAxes 3 FA/$FAPatientFileName FA/${id}_FA_reoriented.nii 0 1 2 1 0 0

         antsRegistrationSyNQuick.sh -d 3 -f FA/${id}_FA_reoriented.nii -m T1/${id}_T1_dirMtxI.nii.gz -o transformations/T1ToFA_{0}_ \
         -x NULL,masks/${id}_nihpd_mask_transformed.nii.gz -t r

    

        antsRegistrationSyNQuick.sh -d 3 -f FA/$FAPatientFileName -m T1/$T1PatientFileName -o test_${id}_ -t r;     
        
        done