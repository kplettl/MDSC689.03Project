#!/bin/bash

####### Reserve computing resources #############
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --array=1-51
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=4:00:00
#SBATCH --mem=10G
#SBATCH --partition=cpu2019
#SBATCH --job-name=MDRegistration
#SBATCH --output=%x-%j.out

####### Notify me by email #########
#SBATCH --mail-user=kira.plettl@ucalgary.ca
#SBATCH --mail-type=ALL

####### Set environment variables ###############
module load ants/2.3.1

####### Run your script #########################

f=$(sed -n "${SLURM_ARRAY_TASK_ID}p" MDImageList.txt)

bash MDregistration-array.sh $f
    

