#
# Check that bacula is installed and configuration files exist

if [ "$BEXTRACT_DEVICE" -o "$BEXTRACT_VOLUME" ]; then

   ### Bacula support using bextract
   has_binary bextract
   StopIfError "Bacula bextract is missing"

   [ -s /etc/bacula/bacula-sd.conf ]
   StopIfError "Bacula configuration file (bacula-sd.conf) missing"

else

   ### Bacula support using bconsole
   has_binary bacula-fd
   StopIfError "Bacula File Daemon is missing"

   [ -s /etc/bacula/bacula-fd.conf ]
   StopIfError "Bacula configuration file (bacula-fd.conf) missing"

   has_binary bconsole
   StopIfError "Bacula console executable is missing"

   [ -s /etc/bacula/bconsole.conf ]
   StopIfError "Bacula configuration file (bconsole.conf) missing"

fi
