#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

cleanup() {
  rm -rf -- "${temp_directory}"
  if [ -n "${initial_tty_device_permissions:-}" ] &&
    [ "$(stat -c '%a' "${tty_device}")" != "${initial_tty_device_permissions}" ]; then
    sudo chmod "${initial_tty_device_permissions}" "${tty_device}"
  fi
}

working_directory="${HOME}/Downloads/diy_jade136"
temp_directory="${working_directory}/temp"
trap cleanup EXIT

jade_git_tag="1.0.36"
jade_save_directory="${working_directory}/jade"
jade_repo_url="https://github.com/blockstream/jade.git"

esp_idf_git_tag="v5.4.2"
esp_idf_temp_directory="${temp_directory}/esp-idf"
esp_idf_save_directory="${working_directory}/esp-idf"
esp_idf_repo_url="https://github.com/espressif/esp-idf.git"

chosen_device="TTGO T-Display"
tty_device="/dev/ttyACM2"

clear
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "---                                                      ---"
echo "---          Do-It-Yourself Jade Install Script          ---"
echo "---                Written by Epic Curious               ---"
echo "---                                                      ---"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo

[ "${CI:-false}" = true ] && echo "Exiting the script for CI runners." && exit 0

while [ ! -c "${tty_device}" ]; do
  read -srn1 -p "Connect your ${chosen_device} and PRESS ANY KEY to continue... " && echo
done
initial_tty_device_permissions="$(stat -c '%a' "${tty_device}")"
if [ "${initial_tty_device_permissions:2}" -lt 6 ]; then
  echo -e "\nElevating write permissions for ${chosen_device}"
  sudo chmod o+rw "${tty_device}"
  echo
fi

idf.py flash

echo -e "\nSUCCESS! Jade ${jade_version} is now installed on your ${chosen_device}.\nYou can close this window.\n"
