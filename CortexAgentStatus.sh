#!/bin/zsh

###############################################################################
# Jamf Pro Extension Attribute
#
# Name:
#   Cortex XDR Health
#
# Purpose:
#   Determine whether Cortex XDR is installed, running, protected, and has
#   its expected macOS system extensions loaded.
#
# Expected Results:
#
#   Healthy
#
#   Unhealthy - Agent Not Running
#   Unhealthy - Agent Not Protected
#   Unhealthy - Security Extension Missing
#   Unhealthy - Network Extension Missing
#   Unhealthy - Multiple Issues: ...
#
#   Not Installed
#
# Supported:
#   Modern macOS / Cortex XDR deployments
###############################################################################

PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

CYTOOL="/Library/Application Support/PaloAltoNetworks/Traps/bin/cytool"

SECURITY_EXTENSION="com.paloaltonetworks.traps.securityextension"
NETWORK_EXTENSION="com.paloaltonetworks.traps.networkextension"

ISSUES=()

###############################################################################
# Verify Cortex XDR / cytool is installed
###############################################################################

if [[ ! -x "$CYTOOL" ]]; then
    echo "<result>Not Installed</result>"
    exit 0
fi

###############################################################################
# Cortex operational status
###############################################################################

RUNNING="$("$CYTOOL" opswat running 2>/dev/null | tr -d '\r' | xargs)"
PROTECTED="$("$CYTOOL" opswat protected 2>/dev/null | tr -d '\r' | xargs)"

if [[ "$RUNNING" != "true" ]]; then
    ISSUES+=("Agent Not Running")
fi

if [[ "$PROTECTED" != "true" ]]; then
    ISSUES+=("Agent Not Protected")
fi

###############################################################################
# System Extension status
###############################################################################

SYSTEM_EXTENSIONS="$(systemextensionsctl list 2>/dev/null)"

SECURITY_EXTENSION_LOADED="false"
NETWORK_EXTENSION_LOADED="false"

if print -r -- "$SYSTEM_EXTENSIONS" | grep -Fq "$SECURITY_EXTENSION"; then
    SECURITY_EXTENSION_LOADED="true"
fi

if print -r -- "$SYSTEM_EXTENSIONS" | grep -Fq "$NETWORK_EXTENSION"; then
    NETWORK_EXTENSION_LOADED="true"
fi

if [[ "$SECURITY_EXTENSION_LOADED" != "true" ]]; then
    ISSUES+=("Security Extension Missing")
fi

if [[ "$NETWORK_EXTENSION_LOADED" != "true" ]]; then
    ISSUES+=("Network Extension Missing")
fi

###############################################################################
# Determine overall health
###############################################################################

if (( ${#ISSUES[@]} == 0 )); then
    RESULT="Healthy"
elif (( ${#ISSUES[@]} == 1 )); then
    RESULT="Unhealthy - ${ISSUES[1]}"
else
    RESULT="Unhealthy - Multiple Issues: ${(j:, :)ISSUES}"
fi

echo "<result>${RESULT}</result>"

exit 0