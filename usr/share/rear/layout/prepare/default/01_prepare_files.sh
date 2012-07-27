# Create all files needed for layout restoration.

LAYOUT_FILE="$VAR_DIR/layout/disklayout.conf"
LAYOUT_DEPS="$VAR_DIR/layout/diskdeps.conf"
LAYOUT_TODO="$VAR_DIR/layout/disktodo.conf"
LAYOUT_CODE="$VAR_DIR/layout/diskrestore.sh"

FS_UUID_MAP="$VAR_DIR/layout/fs_uuid_mapping"

# Touchfiles for layout recreation.
LAYOUT_TOUCHDIR="$TMP_DIR/touch"
if [ -e $LAYOUT_TOUCHDIR ] ; then
    rm -rf $LAYOUT_TOUCHDIR
fi
mkdir -p $LAYOUT_TOUCHDIR

if [ -e $LAYOUT_FILE ] ; then
    backup_file $LAYOUT_FILE
fi

if [ -e /etc/rear/disklayout.conf ] ; then
    cp /etc/rear/disklayout.conf $LAYOUT_FILE
    MIGRATION_MODE="true"
    LogPrint "/etc/rear/disklayout.conf exists, entering Migration mode."
fi

if [ ! -e $LAYOUT_FILE ] ; then
    Log "Disklayout file does not exist, creating empty file."
    : > $LAYOUT_FILE
fi

if [ -e $FS_UUID_MAP ] ; then
    rm -f $FS_UUID_MAP  # map sure old data is deleted
fi

: > $LAYOUT_TODO
: > $LAYOUT_DEPS
