#!/bin/bash

TRFiles=NIHPD_V1_Images/TRImages/'*';

for f in $TRFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 

        TRPatientFile=$( find NIHPD_V1_Images/TRImages/ -name "$id*"); TRPatientFileName=$(basename $TRPatientFile); 

        echo Patient TR Image: $TRPatientFileName; 

        #flip y axis of DTI images so they are in the same orientation as atlas images 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/TRImages/$TRPatientFileName NIHPD_V1_Images/TRImages/${id}_TR_reoriented.nii 0 1 2 0 1 0;

        #generating mean diffusivity maps = trace/3 
        ImageMath 3 NIHPD_V1_Images/MDImages/${id}_MD.nii / NIHPD_V1_Images/TRImages/${id}_TR_reoriented.nii 3; 

    done

FAFiles=NIHPD_V1_Images/FAImages/'*';

for f in $FAFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 

        FAPatientFile=$( find NIHPD_V1_Images/FAImages/ -name "$id*"); FAPatientFileName=$(basename $FAPatientFile); 

        echo Patient FA Image: $FAPatientFileName; 

        #flip y axis of DTI images so they are in the same orientation as atlas images 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/FAImages/$FAPatientFileName NIHPD_V1_Images/FAImages/${id}_FA_reoriented.nii 0 1 2 0 1 0;
        

    done 

EVFiles=NIHPD_V1_Images/EVImages/'*';

for f in $EVFiles; 
    do 
        filename=$(basename $f); 
        id=${filename%%_*}; 
        echo Patient ID: $id; 
        # T1PatientFile=$( find NIHPD_V1_Images/T1Images/ -name "$id*"); T1PatientFileName=$(basename $T1PatientFile); 
        # echo Patient T1 Image: $T1PatientFileName; 

        EVPatientFile=$( find NIHPD_V1_Images/EVImages/ -name "*$id*"); EVPatientFileName=$(basename $EVPatientFile); 

        echo Patient EV Image: $EVPatientFileName; 

        #split 4D EV image into 3 separate images (1000 -> lambda 1, 1001 -> lambda 2, 1002 -> lambda 3)
        ImageMath 4 NIHPD_V1_Images/EVImages/${id}_EV_decomp_.nii.gz TimeSeriesDisassemble NIHPD_V1_Images/EVImages/$EVPatientFileName;

        #make AD image directory for storing AD maps
        # mkdir NIHPD_V1_Images/ADImages/;

        #flip y axis of DTI images so they are in the same orientation as atlas images
        
        # generating lambda 1: axial diffusivity map 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1000.nii.gz NIHPD_V1_Images/ADImages/${id}_AD.nii 0 1 2 0 1 0;
        #lambda 2
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1001.nii.gz NIHPD_V1_Images/EVImages/${id}_EV_1001_reoriented.nii 0 1 2 0 1 0;
        #lambda 3 
        PermuteFlipImageOrientationAxes 3 NIHPD_V1_Images/EVImages/${id}_EV_decomp_1002.nii.gz NIHPD_V1_Images/EVImages/${id}_EV_1002_reoriented.nii 0 1 2 0 1 0;

        #make RD image directory for storing RD maps
        # mkdir NIHPD_V1_Images/RDImages/;

        #generating RD map -> Add lambda 2 and lambda 3 images, then divide result by 2 
        ImageMath 3 NIHPD_V1_Images/EVImages/${id}_EV_added.nii.gz + NIHPD_V1_Images/EVImages/${id}_EV_1001_reoriented.nii NIHPD_V1_Images/EVImages/${id}_EV_1002_reoriented.nii;

        ImageMath 3 NIHPD_V1_Images/RDImages/${id}_RD.nii.gz / NIHPD_V1_Images/EVImages/${id}_EV_added.nii.gz 2;

    done 