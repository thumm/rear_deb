# here we will calculate the space required to hold the backup archive on the remote rsync system
_local_size=0
_remote_size=0
while read -r ; do
	LogPrint "Calculating size of $REPLY"
	# on Linux output is represented in 1024-blocks (or kB)
	df -P "$REPLY"  >$TMP_DIR/fs_size
	StopIfError "Failed to determine size of ${REPLY}."
	fs_size=$(tail -n 1 $TMP_DIR/fs_size | awk '{print $3}')
	_local_size=$((_local_size+fs_size))
done < $TMP_DIR/backup-include.txt
LogPrint "Estimated size of local file systems is $((_local_size/1024)) MB"

case $RSYNC_PROTO in

	(ssh)
		LogPrint "Calculating size of $RSYNC_HOST:$RSYNC_PATH"
		ssh -l $RSYNC_USER $RSYNC_HOST "df -P ${RSYNC_PATH}" >$TMP_DIR/rs_size 2>&8
		StopIfError "Failed to determine size of ${RSYNC_PATH}"
		_div=1	# 1024-blocks
		grep -q "512-blocks" $TMP_DIR/rs_size && _div=2 # HPUX: divide with 2 to get kB size
		_remote_size=$(tail -n 1 $TMP_DIR/rs_size | awk '{print $2}')
		_remote_size=$((_remote_size/_div))
		[[ $_remote_size -gt $_local_size ]]
		StopIfError "Not enough disk space available on $RSYNC_HOST:$RSYNC_PATH ($_remote_size < $_local_size)"
		;;

	(rsync)
		# TODO: how can we calculate the free size on remote system via rsync protocol??
		:
		;;

esac

