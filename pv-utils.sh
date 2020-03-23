#!/bin/bash

pvTemplateFile="pv-template.yml"

deletePVs() {
    dir=$1
    numVols=$2
    for (( i = 1; i <= $numVols; i++ ))
    do
        pvFile=$dir/pv$i.yml
        vol=$dir/vol$i

        echo "Deleting pv defined in $pvFile ..."
        kubectl delete -f $pvFile

        echo "Unmounting volume $vol ..."
        sudo umount $vol
    done

    echo "Cleaning directory $dir"
    rm -rf $dir/*
}

createPVs() {
    dir=$1
    numVols=$2
    size=$(($3 * 1024))

    for (( i = 1; i <= $numVols; i++ ))
    do
        disk=$dir/disk$i
        vol=$dir/vol$i
        pvFile=$dir/pv$i.yml

        echo "Creating block device file: $disk size: $size k ..."
        dd if=/dev/zero of=$disk count=$size bs=1024

        echo "Creating fs ..."
        yes | mkfs.ext4 $disk

        echo "Creating mount: $vol ..."
        mkdir $vol

        echo "Mounting volume ..."
        sudo mount $disk $vol

        echo "Creating pv file ..."
        cp $pvTemplateFile $pvFile
        sed -i -e "s/PV_NAME/$i/g" "$pvFile"
        sed -i -e "s/PV_SIZE/$2Mi/g" "$pvFile"
        sed -i -e "s/PV_PATH/${vol//\//\\/}/g" "$pvFile"

        echo "Creating pv ..."
        kubectl apply -f $pvFile
    done
}

printUsage() {
    echo "A script to provision static persistent volumes with the specific size on a single host"
    echo "Usage: $0 command dir numVols [size]"
    echo " - command: create, delete"
    echo " - dir: an existing directory where the block devices and volumes will be created"
    echo " - numVols: number of volumes to be created"
    echo " - size: size of the volumes in MiB. Not required if command is delete".
}


if [ $# -lt 3 ]; then
    printUsage
    exit 0
fi

command=$1
dir=$2
numVols=$3

echo "command: $command $dir $numVols"

if [ $command == "create" ]; then
    if [ $# -lt 4 ]; then
        printUsage
        exit 0
    fi
    createPVs $dir $numVols $4
elif [ $command == "delete" ]; then
    deletePVs $dir $numVols
else
    echo "Unknown command $command ..."
    printUsage
fi


