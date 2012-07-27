# umount ISO mountpoint

if [[ "$OUTPUT_UMOUNTCMD" ]] ; then
    OUTPUT_URL="var://OUTPUT_UMOUNTCMD"
fi

if [[ -z "$OUTPUT_URL" ]] ; then
    return
fi

umount_url $OUTPUT_URL $BUILD_DIR/outputfs

rmdir $v $BUILD_DIR/outputfs >&2
if [[ $? -eq 0 ]] ; then
    # the argument to RemoveExitTask has to be identical to the one given to AddExitTask
    RemoveExitTask "rmdir $v $BUILD_DIR/outputfs >&2"
fi