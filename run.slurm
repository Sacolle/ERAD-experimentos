#!/bin/bash
#SBATCH --job-name=fletcher
#SBATCH --partition=cei
#SBATCH --nodes=1
#SBATCH --ntasks=27
#SBATCH --time=02:00:00 #n sei quanto tempo
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


set -eux


CSV_FILE=./fletcher-experiments.csv
mapfile -t csv_lines < <(tail -n +2 "$CSV_FILE")

# setup the output
OUTFOLDER=$(printf "%s%s" "$SCRATCH" "fletcher")
mkdir -p $OUTFOLDER

# path to executable
MAINPATH=~/nix-starpu-dev/dev/star-fletcher

cd $MAINPATH

for line in "${csv_lines[@]}"; do
    [[ -z "$line" ]] && continue # skip empty

    IFS=',' read -r size output segmentation <<< "$line"

    echo "============================="
    echo "  Size: $size"
    echo "  Output: $output"
    echo "  Segmentation: $segmentation"

    filename=$(printf "%s_%s_%s" "$size" "$output" "$segmentation")
    
    dt=0.0005
    totalsteps=100
    t=$(awk "BEGIN { print $dt * $totalsteps }")
    absorption=16
    dtoutput=$(awk "BEGIN { print $dt * $output }")
    # add the fxt path and buffsize

    STARPU_TRACE_BUFFER_SIZE=2048 \
    STARPU_FXT_TRACE=1 \
    STARPU_FXT_PREFIX=$OUTFOLDER \
    STARPU_FXT_SUFFIX=$(printf "trace_%s" "$filename" ) \
    nix run .\#star-fletcher -- TTI $size $size $size \
    $absorption 12.5 12.5 12.5 $dt $t $segmentation $dtoutput 2>&1 > $OUTFOLDER/$filename.out
done


echo "retriving the experimental results"

# retrive the resources in the scratch folder
mkdir -p ~/experiment-output
cp $OUTFOLDER/* ~/experiment-output



echo "done"

