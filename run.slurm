#!/bin/bash
#SBATCH --job-name=fletcher
#SBATCH --partition= # :TODO:
#SBATCH --nodes=1
#SBATCH --ntasks=27
#SBATCH --time=02:00:00 #n sei quanto tempo
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

experiment_count=1
CSV_FILE=./fletcher-experiments.csv
mapfile -t csv_lines < <(tail -n +2 "$CSV_FILE")

# setup the output
OUTFOLDER=$SCRATCH/fletcher
mkdir -p $OUTFOLDER

# compile the code
# the outfolder is set in compilation to the scratch folder
cd nix-starpu-dev/dev/star-fletcher
nix develop --command make
cd ~

for line in "${csv_lines[@]}"; do
    [[ -z "$line" ]] && continue # skip empty

    IFS=',' read -r size outuput segmentation <<< "$line"

    echo "============================="
    echo "  Size: $size"
    echo "  Output: $output"
    echo "  Segmentation: $segmentation"
    
    dt=0.0005
    totalsteps=100
    t=$(( $dt*$totalsteps ))
    absorption=16
    dtoutput=$(( $dt*$totalsteps ))
    # change this 
    path=$(hostname)/$size/$iterations/$threads
    # add the fxt path and buffsize
    TODOFLAGS ./fletcher/original/ModelagemFletcher.exe TTI $size $size $size \
    $absorption 12.5 12.5 12.5 $dt $t $segmentation $dtoutput 2>&1 > $path/$blocks.out
done

# retrive the resources in the scratch folder

# STARPU_TRACE_BUFFER_SIZE=1024 # in Mb
# STARPU_FXT_TRACE=1
# STARPU_FXT_PREFIX=~/trace
# STARPU_FXT_SUFFIX=test
