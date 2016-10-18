# How to rebuild Packer images

 - Download and install [Packer](https://www.packer.io/downloads.html)
 - Run
 ```
 PACKER_LOG=1 packer build centos6.json
 ```
 - in case of errors, run again with full logging:
 ```
 PACKER_LOG=1 packer build centos6.json
 ```

# Credits

These Packer scripts were originally derived from [Christoph Hartmann's packer-rhel project](https://github.com/TelekomLabs/packer-rhel).
