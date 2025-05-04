#!/usr/bin/env bash

matrix_names=(                     \
    "Harwell-Boeing/lns/lnsp_131"  \
    "misc/qcd/conf6.0-00l8x8-8000" \
    "SPARSKIT/fidap/fidap011"      \
)

data_dir="data"

mkdir -p ${data_dir}

for name in "${matrix_names[@]}"; do

    # substitute slashes with undescores
    saved_name=${name//\//_}

    download_path="https://math.nist.gov/pub/MatrixMarket2/${name}.mtx.gz"
    echo ${download_path}

    # download the file with curl
    curl ${download_path} > "data/${saved_name}.mtx.gz"

    # decompress
    gzip -d "data/${saved_name}.mtx.gz"

done;

