#!/bin/bash

# $1 -> used for array jobs, takes first input, loop in .slurm file loops through all files 
filename=$(basename $1); 

id=${filename%%_*}; 
echo Patient ID: $id; 

ADPatientFile=$( find NIHPD_V1_Images/ADImages/ -name "*$id*"); ADPatientFileName=$(basename $ADPatientFile); 

echo Patient AD Image: $ADPatientFileName; 

echo Registering T1 to AD, patient ${id};

#register skull-stripped T1 to AD
antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/ADImages/${id}_AD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToAD/T1ToAD_${id}_;

echo Transforming Harvard Oxford Subcortical Regions to AD, patient ${id};
#concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
#Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
            -o regResults/HarvardSub/AD/${id}_HarvardSubcortTransformedtoAD.nii -n NearestNeighbor \
            -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

#transform harvard cortical regions to AD
antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
            -o regResults/HarvardCort/AD/${id}_HarvardCortTransformedtoAD.nii -n NearestNeighbor \
            -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;
            
#transform JHU white matter regions to AD
antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
            -o regResults/JHU_WM/AD/${id}_JHUTransformedtoAD.nii -n NearestNeighbor \
            -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

