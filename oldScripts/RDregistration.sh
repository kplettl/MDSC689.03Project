#!/bin/bash

RDFiles=NIHPD_V1_Images/RDImages/'*';

for f in $RDFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 
        # T1PatientFile=$( find NIHPD_V1_Images/T1Images/ -name "$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        # echo Patient T1 Image: $T1PatientFileName; 

        RDPatientFile=$( find NIHPD_V1_Images/RDImages/ -name "*$id*"); RDPatientFileName=$(basename $RDPatientFile); 

        echo Patient RD Image: $RDPatientFileName; 

        #registering T1 to RD
        echo Registering T1 to RD, patient ${id};

        antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/RDImages/${id}_RD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToRD/T1ToRD_${id}_;

        echo Transforming Harvard Oxford Subcortical Regions to RD, patient ${id};
        # #concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
        # #Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
  
        #transform harvard subcortical region to RD maps
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii\
                    -o regResults/HarvardSub/RD/${id}_HarvardSubcortTransformedtoRD.nii -n NearestNeighbor \
                    -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #transform harvard cortical regions to RD maps
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii\
                    -o regResults/HarvardCort/RD/${id}_HarvardCortTransformedtoRD.nii -n NearestNeighbor \
                    -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #transform JHU white matter regions to RD maps
        antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii\
                    -o regResults/JHU_WM/RD/${id}_JHUTransformedtoRD.nii -n NearestNeighbor \
                    -t transformations/T1ToRD/T1ToRD_${id}_1Warp.nii.gz -t transformations/T1ToRD/T1ToRD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #remove matrices after reg/transformation to save space? 
        # rm transformations/T1ToFA_${id}_0GenericAffine.mat transformations/PedsToT1_${id}_1Warp.nii.gz transformations/PedsToT1_${id}_0GenericAffine.mat \
        #            transformations/MNIToPeds_1Warp.nii.gz transformations/MNIToPeds_0GenericAffine.mat; 


        # antsRegistrationSyNQuick.sh -d 3 -f FA/$FAPatientFileName -m T1/$T1PatientFileName -o test_${id}_ -t r;     
        
        done