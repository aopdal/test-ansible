#!/bin/bash
# This script will prepare an environment for running the code after downloading it.

cd "$(dirname "$0")"
VIRTUALENV="$(pwd -P)/venv"
PYTHON="${PYTHON:-python3}"

# Creating directories for ansible
if [ -d "roles" ];
then
    echo "roles directory exists."
else
	mkdir roles
fi
if [ -d "collections" ];
then
    echo "collections directory exists."
    rm -Rf collections
  	mkdir collections
else
	mkdir collections
fi

# Validate the minimum required Python version
COMMAND="${PYTHON} -c 'import sys; exit(1 if sys.version_info < (3, 10) else 0)'"
PYTHON_VERSION=$(eval "${PYTHON} -V")
eval $COMMAND || {
  echo "--------------------------------------------------------------------"
  echo "ERROR: Unsupported Python version: ${PYTHON_VERSION}. This code requires"
  echo "Python 3.10 or later. To specify an alternate Python executable, set"
  echo "the PYTHON environment variable. For example:"
  echo ""
  echo "  sudo PYTHON=/usr/bin/python3.10 ./upgrade.sh"
  echo ""
  echo "To show your current Python version: ${PYTHON} -V"
  echo "--------------------------------------------------------------------"
  exit 1
}
echo "Using ${PYTHON_VERSION}"

# Remove the existing virtual environment (if any)
if [ -d "$VIRTUALENV" ]; then
  COMMAND="rm -rf ${VIRTUALENV}"
  echo "Removing old virtual environment..."
  eval $COMMAND
else
  WARN_MISSING_VENV=1
fi

# Create a new virtual environment
COMMAND="${PYTHON} -m venv ${VIRTUALENV}"
echo "Creating a new virtual environment at ${VIRTUALENV}..."
eval $COMMAND || {
  echo "--------------------------------------------------------------------"
  echo "ERROR: Failed to create the virtual environment. Check that you have"
  echo "the required system packages installed and the following path is"
  echo "writable: ${VIRTUALENV}"
  echo "--------------------------------------------------------------------"
  exit 1
}

# Activate the virtual environment
source "${VIRTUALENV}/bin/activate"

# Upgrade pip
COMMAND="pip install --upgrade pip"
echo "Updating pip ($COMMAND)..."
eval $COMMAND || exit 1
pip -V

# Install required Python packages
COMMAND="pip install -r requirements.txt"
echo "Installing core dependencies ($COMMAND)..."
eval $COMMAND || exit 1

# Install ansible collections
#
# if installation from ansible-galaxy fails, verify if ansible-galaxy-ng.s3.dualstack.us-east-1.amazonaws.com is used.
#
ansible-galaxy collection install netbox.netbox -p collections --force
#ansible-galaxy collection install git+https://github.com/netbox-community/ansible_modules.git,devel -p collections --force

if [ -v WARN_MISSING_VENV ]; then
  echo "--------------------------------------------------------------------"
  echo "WARNING: No existing virtual environment was detected. A new one has"
  echo "been created. (If this is a new installation,"
  echo "this warning can be ignored.)"
  echo "The following environment variables are used, add the information"
  echo "to your setup."
  echo "export NETBOX_API=https://xxx"
  echo "export NETBOX_TOKEN=xx"
  echo "--------------------------------------------------------------------"
fi

echo "Upgrade complete!"
