# #30_create_isolinux.sh
#
# create yaboot.cfg for Relax-and-Recover
#
#    Relax-and-Recover is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.

#    Relax-and-Recover is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Relax-and-Recover; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

# create yaboot directory structure
mkdir -p $v $TMP_DIR/ppc/chrp >&2
cp $v /usr/lib/yaboot/yaboot $TMP_DIR/ppc/chrp >&2

cat >"$TMP_DIR/ppc/bootinfo.txt" <<EOF
<chrp-boot>
<description>Relax-and-Recover</description>
<os-name>Linux</os-name>
<boot-script>boot &device;:\ppc\chrp\yaboot</boot-script>
</chrp-boot>
EOF

mkdir -p $v $TMP_DIR/etc >&2
cat >"$TMP_DIR/etc/yaboot.conf" <<EOF
init-message = "\nRelax-and-Recover boot\n\n"
timeout=100
default=Relax-and-Recover

image=kernel
	label=Relax-and-Recover
	initrd=initrd.cgz
	append=" root=/dev/ram0 $KERNEL_CMDLINE"

EOF

ISO_FILES=( "${ISO_FILES[@]}" etc=etc ppc=ppc )
