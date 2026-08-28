#!/bin/zsh

###############################################################################
# Jamf Pro Extension Attribute
#
# Name:
#   Cortex XDR Version
#
# Purpose:
#   Return the installed Cortex XDR agent version using Palo Alto's cytool.
#
# Expected Results:
#   9.2.0.1234
#   Not Installed
#   Unknown
###############################################################################

PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

CYTOOL="/Library/Application Support/PaloAltoNetworks/Traps/bin/cytool"

###############################################################################
# Verify Cortex XDR / cytool is installed
###############################################################################

if [[ ! -x "$CYTOOL" ]]; then
    echo "<result>Not Installed</result>"
    exit 0
fi

###############################################################################
# Query installed agent version
###############################################################################

VERSION="$("$CYTOOL" opswat version 2>/dev/null | tr -d '\r' | xargs)"

if [[ -n "$VERSION" ]]; then
    echo "<result>${VERSION}</result>"
else
    echo "<result>Unknown</result>"
fi

exit 0