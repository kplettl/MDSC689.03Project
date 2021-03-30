#!/bin/bash

EVFiles=NIHPD_V1_Images/EVImages/'*';

for f in $EVFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 
        T1PatientFile=$( find NIHPD_V1_Images/T1Images/ -name "$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        echo Patient T1 Image: $T1PatientFileName; 

        EVPatientFile=$( find NIHPD_V1_Images/EVImages/ -name "*$id*"); EVPatientFileName=$(basename $EVPatientFile); 

        echo Patient EV Image: $EVPatientFileName; 

        #split 4D EV image into 3 separate images (1000 -> lambda 1, 1001 -> lambda 2, 1002 -> lambda 3)
        ImageMath 4 NIHPD_V1_Images/EVImages/${id}_EV_decomp_.nii TimeSeriesDisassemble NIHPD_V1_Images/EVImages/$EVPatientFileName;

        #flip x axis of DTI images so they are in the same orientation as T1 images 
        # generating lambda 1: axial diffusivity map 

        #make AD image directory for storing AD maps
        mkdir NIHPD_V1_Images/ADImages/;

        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1000.nii NIHPD_V1_Images/ADImages/${id}_AD.nii 0 1 2 1 0 0;

        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1001.nii NIHPD_V1_Images/EVImages/${id}_EV_1001_reoriented.nii 0 1 2 1 0 0;

        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1002.nii NIHPD_V1_Images/EVImages/${id}_EV_1002_reoriented.nii 0 1 2 1 0 0;

        #make RD image directory for storing RD maps
        mkdir NIHPD_V1_Images/RDImages/;

        #generating RD map -> Add lambda 2 and lambda 3 images, then divide result by 2 
        ImageMath 3 NIHPD_V1_Images/EVImages/${id}_EV_added.nii.gz + NIHPD_V1_Images/EVImages/${id}_EV_1001_reoriented.nii NIHPD_V1_Images/EVImages/${id}_EV_1002_reoriented.nii;

        ImageMath 3 NIHPD_V1_Images/RDImages/${id}_RD.nii.gz / NIHPD_V1_Images/EVImages/${id}_EV_added.nii.gz 2;

        # SetOrigin 3 FA/${id}_FA_reoriented.nii FA/${id}_FA_reorientedOriginZero.nii 0 0 0 

        #register T1 image with AD image using the transformed T1 mask as a moving image mask
        #dti data is skull stripped, T1 is not, so mask is necessary to ensure registration only uses brain and not skull, neck, etc. in the T1 images 
        # -t r -> rigid reg
        # -t a -> rigid + affine reg
        # no -t flag -> non-linear reg
        echo Registering T1 to AD, patient ${id};
        # antsRegistrationSyN.sh -d 3 -f FA/${id}_FA_reoriented.nii -m T1/${id}_T1_dirMtxI.nii.gz -o transformations/T1ToFA_${id}_ \
        #             -x NULL,masks/${id}_nihpd_mask_transformed.nii.gz -t r;

        #alternate: run registration with skull-stripped T1 images rather than performing masked registration (to avoid effects at edge of mask)
        antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/ADImages/${id}_AD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz -o transformations/T1ToAD_${id}_ -t r;

        echo Transforming Harvard Oxford Subcortical Regions to AD, patient ${id};
        #concatenate all transforms to transform subcortical region atlas into patient-specific DTI space
        #Adult atlas -> peds atlas -> patient-specific T1 -> patient-specific DTI
        antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/ADImages/${id}_AD.nii\
                    -o regResults/${id}_HarvardSubcortTransformedtoAD.nii -n NearestNeighbor \
                    -t transformations/T1ToAD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;

        #registering T1 to RD
        echo Registering T1 to RD, patient ${id};

        antsRegistrationSyN.sh -d 3 -f NIHPD_V1_Images/RDImages/${id}_RD.nii -m NIHPD_V1_Images/T1Images/${id}_T1_skullstripped.nii.gz -o transformations/T1ToRD_${id}_ -t r;

        antsApplyTransforms -d 3 -i atlas/HarvardOxfordSubcortical.nii.gz -r NIHPD_V1_Images/RDImages/${id}_RD.nii\
                    -o regResults/${id}_HarvardSubcortTransformedtoRD.nii -n NearestNeighbor \
                    -t transformations/T1ToRD_${id}_0GenericAffine.mat \
                    -t transformations/PedsToT1_${id}_1Warp.nii.gz -t transformations/PedsToT1_${id}_0GenericAffine.mat \
                    -t transformations/MNIToPeds_1Warp.nii.gz -t transformations/MNIToPeds_0GenericAffine.mat -v 1;


        #remove matrices after reg/transformation to save space? 
        # rm transformations/T1ToFA_${id}_0GenericAffine.mat transformations/PedsToT1_${id}_1Warp.nii.gz transformations/PedsToT1_${id}_0GenericAffine.mat \
        #            transformations/MNIToPeds_1Warp.nii.gz transformations/MNIToPeds_0GenericAffine.mat; 


        # antsRegistrationSyNQuick.sh -d 3 -f FA/$FAPatientFileName -m T1/$T1PatientFileName -o test_${id}_ -t r;     
        
        done