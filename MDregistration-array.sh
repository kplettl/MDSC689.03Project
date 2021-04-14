#!/bin/bash

# $1 -> used for array jobs, takes first input, loop in .slurm file loops through all files 
filename=$(basename $1); 

id=${filename%%_*}; 
echo Patient ID: $id; 


echo Registering T1 to MD, patient ${id};
#register skull-stripped T1 to MD
antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/MDImages/${id}_MD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToMD/T1ToMD_${id}_;

echo Transforming Harvard Oxford Subcortical Atlas, patient ${id};
#concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
#Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/MDImages/${id}_MD.nii \
            -o regResults/HarvardSub/MD/${id}_HarvardSubcortTransformedtoMD.nii -n NearestNeighbor \
            -t transformations/T1ToMD/T1ToMD_${id}_1Warp.nii.gz -t transformations/T1ToMD/T1ToMD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

#harvard oxford cortical 
echo Transforming Harvard Oxford Cortical Atlas, patient ${id};

antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/MDImages/${id}_MD.nii \
            -o regResults/HarvardCort/MD/${id}_HarvardCortTransformedtoMD.nii -n NearestNeighbor \
            -t transformations/T1ToMD/T1ToMD_${id}_1Warp.nii.gz -t transformations/T1ToMD/T1ToMD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

#JHU white matter atlas
echo Transforming Johns Hopkins White Matter Atlas, patient ${id};

antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/MDImages/${id}_MD.nii \
            -o regResults/JHU_WM/MD/${id}_JHUTransformedtoMD.nii -n NearestNeighbor \
            -t transformations/T1ToMD/T1ToMD_${id}_1Warp.nii.gz -t transformations/T1ToMD/T1ToMD_${id}_0GenericAffine.mat \
            -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
            -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;
