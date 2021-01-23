#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Sets up printers then starts cupsd.

set -euo pipefail

/etc/init.d/cups start

BRPRINTER_DEST=MFC-J625DW
lpadmin -p ${BRPRINTER_DEST} \
	-v lpd://${BRPRINTER_IP}/BINARY_P1 \
	-P /usr/share/cups/model/Brother/brother_mfcj625dw_printer_en.ppd
cupsenable ${BRPRINTER_DEST}
cupsaccept ${BRPRINTER_DEST}

HPPRINTER_DEST=MFP_M177fw
lpadmin -p ${HPPRINTER_DEST} \
	-v hp:/net/HP_Color_LaserJet_Pro_MFP_M177fw?ip=${HPPRINTER_IP} \
	-m drv:///hpcups.drv/hp-color_laserjet_pro_mfp_m177fw.ppd
cupsenable ${HPPRINTER_DEST}
cupsaccept ${HPPRINTER_DEST}

# set default printer options
lpadmin -p ${BRPRINTER_DEST} -o PageSize=A4
lpadmin -p ${BRPRINTER_DEST} -o BRDuplex=DuplexNoTumble

while :; do
	sleep infinity
done
