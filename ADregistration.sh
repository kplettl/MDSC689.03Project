#!/bin/bash

ADFiles=NIHPD_V1_Images/ADImages/'*';

for f in $ADFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 
        # T1PatientFile=$( find NIHPD_V1_Images/T1Images/ -name "$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        # echo Patient T1 Image: $T1PatientFileName; 

        ADPatientFile=$( find NIHPD_V1_Images/ADImages/ -name "*$id*"); ADPatientFileName=$(basename $ADPatientFile); 

        echo Patient AD Image: $ADPatientFileName; 

        #register T1 image with AD image using the transformed T1 mask as a moving image mask
        #dti data is skull stripped, T1 is not, so mask is necessary to ensure registration only uses brain and not skull, neck, etc. in the T1 images 
        # -t r -> rigid reg
        # -t a -> rigid + affine reg
        # no -t flag -> non-linear reg
        echo Registering T1 to AD, patient ${id};
        # antsRegistrationSyN.sh -d 3 -f FA/${id}_FA_reoriented.nii -m T1/${id}_T1_dirMtxI.nii.gz -o transformations/T1ToFA_${id}_ \
        #             -x NULL,masks/${id}_nihpd_mask_transformed.nii.gz -t r;

        #alternate: run registration with skull-stripped T1 images rather than performing masked registration (to avoid effects at edge of mask)
        antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/ADImages/${id}_AD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToAD/T1ToAD_${id}_;

        # #registering T1 to RD
        # echo Registering T1 to RD, patient ${id};

        # antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/RDImages/${id}_RD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_SS_reoriented.nii.gz -o transformations/T1ToRD/T1ToRD_${id}_;

        echo Transforming Harvard Oxford Subcortical Regions to AD, patient ${id};
        #concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
        #Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
                    -o regResults/HarvardSub/AD/${id}_HarvardSubcortTransformedtoAD.nii -n NearestNeighbor \
                    -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #transform harvard cortical regions to AD
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
                    -o regResults/HarvardCort/AD/${id}_HarvardCortTransformedtoAD.nii -n NearestNeighbor \
                    -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;
                    
        #transform JHU white matter regions to AD
        antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
                    -o regResults/JHU_WM/AD/${id}_JHUTransformedtoAD.nii -n NearestNeighbor \
                    -t transformations/T1ToAD/T1ToAD_${id}_1Warp.nii.gz -t transformations/T1ToAD/T1ToAD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #remove matrices after reg/transformation to save space? 
        # rm transformations/T1ToFA_${id}_0GenericAffine.mat transformations/PedsToT1_${id}_1Warp.nii.gz transformations/PedsToT1_${id}_0GenericAffine.mat \
        #            transformations/MNIToPeds_1Warp.nii.gz transformations/MNIToPeds_0GenericAffine.mat; 


        # antsRegistrationSyNQuick.sh -d 3 -f FA/$FAPatientFileName -m T1/$T1PatientFileName -o test_${id}_ -t r;     
        
        done