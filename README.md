# openhab-pi-bluez
This Docker image allows you to use the integrated Bluetooth chip of Raspberry Pi models with OpenHAB.

**Please note:** This image in theory is compatible with all Bluetooth-enabled Raspberry Pi models up to the 4B. 
However, only the Pi 4B has been tested sofar.

## Usage
To build the image simply run `. ./build.sh` on a Linux host.

As this image is based on the official OpenHAB Docker image, please refer to the guide available 
[here](https://www.openhab.org/docs/installation/docker.html "here") for OpenHAB related configurations.

Make sure that BlueZ (or alternatives) are not running on the host system before you spin up a container. You may even 
uninstall BlueZ on the host system completely, if you plan to use the bluetooth chip solely for OpenHAB.

Additionally, the following parameters are required specifically for this image:
- `--net=host`, `--cap-add=NET_ADMIN`: These parameters enable the container to access the HCI and bluetooth stack and 
additionally enable host networking, which might not be desired. However, other combinations and setups have not been 
tested yet.
- `--device=/dev/ttyAMA0`: This maps the bluetooth chip to the container. **Please check your device mapping for the 
correct value to avoid hardware failures.**
- `--device=/dev/vcio`: This maps the video chip to the container. This is required for proper bluetooth chip resets as 
done by the `vcmailbox` binary.
- `-v /etc/firmware/:/etc/firmware/:ro`: Provides the host's firmware to the container. In some cases the firmware on 
the host is located at `/lib/firmware`. If this applies to you, either adapt the mapping, or create a symlink with 
`ln -s /lib/firmware /etc/firmware`.

A sample Docker run command for a Raspberry Pi 4B looks as follows:
```
docker run --name openhab \
    -d \
    --restart unless-stopped \
    --net=host \
    --cap-add=NET_ADMIN \
    --device=/dev/ttyAMA0 \
    --device=/dev/vcio \
    -v /lib/firmware/:/etc/firmware/:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v "$(pwd)/conf/:/openhab/conf/" \
    -v "$(pwd)/userdata/:/openhab/userdata/" \
    -v "$(pwd)/addons/:/openhab/addons/" \
    -e USER_ID=$(id -u) \
    -e GROUP_ID=$(id -g) \
    openhab-pi-bluez:2.5.2-armhf-debian
```

## Limitations
- The host system naturally can't use the bluetooth chip while this Docker image is running.
- This image is **only compatible with ARMv7 (armhf, aarch32)** hosts due to the fact that the tinyb compiled 
libraries provided by the OpenHAB Bluetooth binding, are only compiled for ARMv7.

## License
openhab-pi-bluez is licensed under the MIT license. A copy of said license can be found 
[here](https://github.com/fenik/openhab-pi-bluez/blob/master/LICENSE.md "here").
