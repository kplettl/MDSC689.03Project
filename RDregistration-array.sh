#!/bin/bash

# $1 -> used for array jobs, takes first input, loop in .slurm file loops through all files 
filename=$(basename $1); 

id=${filename%%_*}; 
echo Patient ID: $id; 

RDPatientFile=$( find NIHPD_V1_Images/RDImages/ -name "*$id*"); RDPatientFileName=$(basename $RDPatientFile); 

echo Patient RD Image: $RDPatientFileName; 

#registering skull-stripped T1 to RD
echo Registering T1 to RD, patient ${id};

antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/RDImages/${id}_RD.nii.gz -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToRD/T1ToRD_${id}_;

echo Transforming Harvard Oxford Subcortical Regions to RD, patient ${id};

# #concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
# #Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
#transform harvard subcortical region to RD maps
antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii.gz\
            -o regResults/HarvardSub/RD/${id}_HarvardSubcortTransformedtoRD.nii -n NearestNeighbor \
            -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

#transform harvard cortical regions to RD maps
antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii.gz\
            -o regResults/HarvardCort/RD/${id}_HarvardCortTransformedtoRD.nii -n NearestNeighbor \
            -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

#transform JHU white matter regions to RD maps
antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii.gz\
            -o regResults/JHU_WM/RD/${id}_JHUTransformedtoRD.nii -n NearestNeighbor \
            -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

