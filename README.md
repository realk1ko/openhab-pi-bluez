# openhab-pi-bluez
These `cont-init.d` scripts allow your openHAB Docker container access to the Bluetooth chip of your Raspberry Pi.

**Please note:** The scripts are in theory compatible with all Bluetooth-enabled Raspberry Pi models up to the 4B. 
However, only the Pi 4B has been tested sofar.

## Usage
As the scripts can be used with the official openHAB Docker image, please refer to the guide available 
[here](https://www.openhab.org/docs/installation/docker.html "here") for openHAB related configurations. The scripts 
rely on the `cont-init.d` of the official openHAB image.

1. You need to make sure that BlueZ (or alternatives) are not running on the host system before you start your 
container. You may even uninstall BlueZ on the host system completely, if you plan to use the Bluetooth chip solely for 
openHAB.

2. The scripts of this repository have to be mounted in (or pushed to) the running openHAB container. Mounting the 
scripts is the preferred option and can be achieved by passing the following arguments to your `docker run` command:
   - `-v /path/to/10-pi-bluez-setup:/etc/cont-init.d/10-pi-bluez-setup:ro`: This mounts the setup script, which 
   installs the Bluetooth stack, required libraries and firmware tools on the next startup.
   - `-v /path/to/20-pi-bluez-init:/etc/conit-init.d/20-pi-bluez-init:ro`: This mounts the initialization scripts, 
   which resets and initializes the Bluetooth chip on each start of the container.

3. The following parameters are additionally required to allow access to the Bluetooth chip:
   - `--net=host`, `--cap-add=NET_ADMIN`: These parameters enable the container to access the HCI and Bluetooth stack. 
   They additionally enable host networking, which might not be desired in some cases. However, other combinations and 
   setups have not been tested yet.
   - `--device=/dev/ttyAMA0`: This maps the Bluetooth chip to the container. **Please check your device mapping for the 
   correct value to prevent hardware failures.**
   - `--device=/dev/vcio`: This maps the video chip to the container. This is required for proper Bluetooth chip resets 
   as done by the `vcmailbox` binary.
   - `-v /etc/firmware/:/etc/firmware/:ro`: Provides the hosts firmware to the container. In some cases the firmware on 
   the host is located at `/lib/firmware/`. If this applies to you, either adapt the mapping, or create a symlink with 
   `ln -s /lib/firmware/ /etc/firmware`.

A minimal Docker run command for a Raspberry Pi 4B looks as follows:
```
docker run --name openhab \
    -d \
    --restart unless-stopped \
    --cap-add=NET_ADMIN \
    --net=host \
    --device=/dev/ttyAMA0 \
    --device=/dev/vcio \
    -v /etc/firmware/:/etc/firmware/:ro \
    -v "$(pwd)/10-pi-bluez-setup:/etc/cont-init.d/10-pi-bluez-setup:ro"
    -v "$(pwd)/20-pi-bluez-init:/etc/cont-init.d/20-pi-bluez-init:ro"
    openhab/openhab:2.5.2-armhf-debian
```

## Limitations
- The host system naturally can't use the Bluetooth chip while the container is running.
- The scripts are **only compatible with ARMv7 (armhf, aarch32)** hosts due to the fact that the tinyb compiled 
libraries provided by the openHAB Bluetooth binding are only compiled for ARMv7.

## License
openhab-pi-bluez is licensed under the MIT license. A copy of said license can be found 
[here](https://github.com/fenik/openhab-pi-bluez/blob/master/LICENSE.md "here").
