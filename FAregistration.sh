#!/bin/bash

# antsRegistrationSyN.sh -d 3 -f atlas/nihpd_originZero.nii -m atlas/mni1mm.nii.gz -o transformations/MNIToPeds_

FAFiles=NIHPD_V1_Images/FAImages/'*';

for f in $FAFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 
    
        # T1PatientFile=$( find NIHPD_V1_Images/T1Images/ -name "$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        # echo Patient T1 Image: $T1PatientFileName; 

        # #set direction cosine matrix of T1 image to the same as the atlas (T1 dr mtx is not identity, cannot register if not the same)
        # CopyImageHeaderInformation atlas/nihpd_originZero.nii T1/$T1PatientFileName T1/${id}_T1_dirMtxI.nii.gz 1 1 1;

        # #register pediatric atlas (origin set to zero) with each patient T1 image using the pediatric brain mask as the moving image mask
        # antsRegistrationSyN.sh -d 3 -f T1/${id}_T1_dirMtxI.nii.gz -m atlas/nihpd_originZero.nii -o transformations/PedsToT1_${id}_ \
        #             -x NULL,nihpd_mask_originZero.nii;

        # #apply transform from previous registration (NIHPD atlas to T1) to transform template mask into patient specific mask
        # #for use when registering T1 image to DTI images
        # antsApplyTransforms -d 3 -i nihpd_mask_originZero.nii -r T1/${id}_T1_dirMtxI.nii.gz \
        #             -o masks/${id}_nihpd_mask_transformed.nii.gz -n NearestNeighbor -t transformations/PedsToT1_${id}_1Warp.nii.gz \
        #             -t transformations/PedsToT1_${id}_0GenericAffine.mat -v 1;

        # #skull-strip T1 images using patient specific mask (format: output T1, multiply T1 image with transformed mask)
        # ImageMath 3 T1/${id}_T1_skullstripped.nii.gz m T1/${id}_T1_dirMtxI.nii.gz masks/${id}_nihpd_mask_transformed.nii.gz;

        FAPatientFile=$( find NIHPD_V1_Images/FAImages/ -name "$id*"); FAPatientFileName=$(basename $FAPatientFile); 

        echo Patient FA Image: $FAPatientFileName; 

        #flip y axis of DTI images so they are in the same orientation as atlas images 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/FAImages/$FAPatientFileName NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii 0 1 2 0 1 0;
        #flip x, y axis of T1 so they are in the same orientation as atlas images 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz 0 1 2 1 1 0;

        # SetOrigin 3 FA/${id}_FA_reoriented.nii FA/${id}_FA_reorientedOriginZero.nii 0 0 0 

        #register T1 image with DTI image (FA here) using the transformed T1 mask as a moving image mask
        #dti data is skull stripped, T1 is not, so mask is necessary to ensure registration only uses brain and not skull, neck, etc. in the T1 images 
        # -t r -> rigid reg
        # -t a -> rigid + affine reg
        # no -t flag -> non-linear reg
        echo Registering T1 to FA, patient ${id};
        # antsRegistrationSyN.sh -d 3 -f FA/${id}_FA_reoriented.nii -m T1/${id}_T1_dirMtxI.nii.gz -o transformations/T1ToFA_${id}_ \
        #             -x NULL,masks/${id}_nihpd_mask_transformed.nii.gz -t r;

        #alternate: run registration with skull-stripped T1 images rather than performing masked registration (to avoid effects at edge of mask)
        antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii -m NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz -o transformations/T1ToFA/T1ToFA_${id}_;

        echo Transforming Harvard Oxford Subcortical Atlas, patient ${id};
        #concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
        #Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii\
                    -o regResults/HarvardSub/${id}_HarvardSubcortTransformedtoFA.nii -n NearestNeighbor \
                    -t transformations/T1ToFA/T1ToFA_${id}_1Warp.nii.gz -t transformations/T1ToFA/T1ToFA_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #harvard oxford cortical 
        echo Transforming Harvard Oxford Cortical Atlas, patient ${id};

        antsApplyTransforms -d 3 -i atlas/HarvardOxfordCortical.nii.gz -r NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii\
                    -o regResults/HarvardCort/${id}_HarvardCortTransformedtoFA.nii -n NearestNeighbor \
                    -t transformations/T1ToFA/T1ToFA_${id}_1Warp.nii.gz -t transformations/T1ToFA/T1ToFA_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #JHU white matter atlas
        echo Transforming Johns Hopkins White Matter Atlas, patient ${id};

        antsApplyTransforms -d 3 -i atlas/JHU_WM1mm.nii.gz -r NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii\
                    -o regResults/JHU_WM/${id}_JHUTransformedtoFA.nii -n NearestNeighbor \
                    -t transformations/T1ToFA/T1ToFA_${id}_1Warp.nii.gz -t transformations/T1ToFA/T1ToFA_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;
        #remove matrices after reg/transformation to save space? 
        # rm transformations/T1ToFA_${id}_0GenericAffine.mat transformations/PedsToT1_${id}_1Warp.nii.gz transformations/PedsToT1_${id}_0GenericAffine.mat \
        #            transformations/MNIToPeds_1Warp.nii.gz transformations/MNIToPeds_0GenericAffine.mat; 


        # antsRegistrationSyNQuick.sh -d 3 -f FA/$FAPatientFileName -m T1/$T1PatientFileName -o test_${id}_ -t r;     
        
        done