#! /bin/bash

# User reported false positives for MMotti's regex filters
# https://github.com/mmotti

# This file is not currently referenced during install.
# If you experience issues with any of the following domains,
# you will need the add them manually to your Pi-hole installation.
pihole -w \
anti-ad.net \
iij.ad.jp \
stats.foldingathome.org \
stats.stackexchange.com \
www.ad.nl \
www.iij.ad.jp \
support.iam.ad.azure.com
