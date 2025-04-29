#!/bin/bash

echo "Starting HoneyNetX installation..."
env bash -c "$(curl -sL https://github.com/telekom-security/tpotce/raw/master/install.sh)"

if [ $? -eq 0 ]; then
    echo "T-Pot installation completed successfully!"
    echo "The system will now reboot."
    echo "After reboot:"
    echo "- SSH will be available on port 64295"
    echo "- Web interface will be available on port 64297"
    read -p "Press Enter to reboot now..."
    sudo reboot
else
    echo "HoneyNetX installation failed."
    exit 1
fi