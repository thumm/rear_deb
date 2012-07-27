# Try to automatically resize disks

if [[ -z "$MIGRATION_MODE" ]] ; then
    return 0
fi

# Resize all partitions, except the boot partition
# This does not resize volumes on top of the affected partitions.

cp $LAYOUT_FILE $LAYOUT_FILE.tmp
backup_file $LAYOUT_FILE

while read type device size junk ; do
    sysfsname=$(get_sysfs_name $device)

    if [[ -d /sys/block/$sysfsname ]] ; then
        newsize=$(get_disk_size $sysfsname)

        if (( "$newsize" == "$size" )) ; then
            continue
        fi

        oldsize=$size
        difference=$(( newsize - oldsize )) # can be negative!
        Log "Total resize of ${difference}B"

        Log "Searching for resizeable partitions on disk $device (${newsize}B)"

        # Find partitions that could be resized
        partitions=()
        resizeable_space=0
        available_space=$newsize
        while read type part size start name flags name junk; do
            case $flags in
                (*boot*|*bios_grub*)
                    available_space=$(( available_space - ${size%B} ))
                    Log "Will not resize partition $name."
                    ;;
                (*)
                    partitions=( "${partitions[@]}" "$name|${size%B}" )
                    resizeable_space=$(( resizeable_space + ${size%B} ))
                    Log "Will resize partition $name."
                    ;;
            esac
        done < <(grep "^part $device" $LAYOUT_FILE)

        if (( ${#partitions[@]} == 0 )) ; then
            Log "No resizeable partitions found."
            continue
        fi

        if (( available_space < 0 )) ; then
            LogPrint "No space to automatically resize partitions on disk $device."
            LogPrint "Please do this manually."
            continue
        fi

        # evenly distribute the size changes
        ### example:
        ### resize     to      3145728000
        ###          from    160041885696
        ### partitions:
        ###  1 :                 209682432 (boot -> skipped)
        ###  2 :              128639303680
        ###  3 :               30040653824
        ###
        ### space used by resizeable partitions
        ###  128639303680 + 30040653824 = 158679957504
        ### available for resize on disk
        ###   3145728000 - 209682432 = 2936045568
        ### divide available space evenly
        ### 2' : 128639303680 * 2936045568 / 158679957504 = 2380205183
        ### 3' :  30040653824 * 2936045568 / 158679957504 =  555840384
        ###                                                 2936045567
        for data in "${partitions[@]}" ; do
            name=${data%|*}
            partition_size=${data#*|}

            new_size=$(echo "$partition_size $resizeable_space $available_space" | awk '{ printf "%d", ($1/$2)*$3; }')

            (( new_size > 0 ))
            BugIfError "Partition $name resized to a negative number."

            nr=$(echo "$name" | sed -r 's/.+([0-9])$/\1/')
            sed -r -i "s|^(part $device) ${partition_size}(.+)$nr$|\1 ${new_size}\2$nr|" $LAYOUT_FILE.tmp
            Log "Resized partition $name from ${partition_size}B to ${new_size}B."
        done
    fi
done < <(grep "^disk " $LAYOUT_FILE)

mv $LAYOUT_FILE.tmp $LAYOUT_FILE
