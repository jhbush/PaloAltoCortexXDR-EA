# PaloAltoCortexXDR-EA

Jamf Pro extension attributes for monitoring Palo Alto Cortex XDR on macOS endpoints.

## Current state

This repository contains two shell-based extension attributes intended for use in Jamf Pro:

- `CortexAgentVersion.sh` returns the installed Cortex XDR agent version, or `Not Installed` / `Unknown` when no valid value can be read.
- `CortexAgentStatus.sh` reports the operational health of the agent and whether required macOS system extensions are loaded.

Each script prints a single `<result>...</result>` string so it can be consumed directly by Jamf Pro's extension attribute mechanism.

## Included checks

### `CortexAgentVersion.sh`

Validates that the Palo Alto `cytool` binary exists at `/Library/Application Support/PaloAltoNetworks/Traps/bin/cytool`, then queries:

- `cytool opswat version`

Expected output is a version string such as `9.2.0.1234`, or one of the fallback values below:

- `Not Installed`
- `Unknown`

### `CortexAgentStatus.sh`

Checks whether the Cortex XDR agent is installed and reporting healthy state by validating:

- `cytool opswat running`
- `cytool opswat protected`
- `systemextensionsctl list` for the required Palo Alto security and network extensions

Possible result values include:

- `Healthy`
- `Unhealthy - Agent Not Running`
- `Unhealthy - Agent Not Protected`
- `Unhealthy - Security Extension Missing`
- `Unhealthy - Network Extension Missing`
- `Unhealthy - Multiple Issues: ...`
- `Not Installed`

## Jamf Pro usage

Import either script as a custom extension attribute in Jamf Pro and configure the policy scope and smart groups as needed. The scripts are designed to return a plain result string without any additional formatting so Jamf can display and evaluate the value directly.

## Notes

- These scripts assume the Palo Alto Cortex XDR agent is installed in the standard macOS location used by the official Traps package.
- They are intentionally lightweight and do not require any external dependencies beyond the macOS system utilities already available on supported endpoints.
