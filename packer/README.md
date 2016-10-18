# How to rebuild Packer images

 - Download and instal [Packer](https://www.packer.io/downloads.html)
 - Run
 ```
 PACKER_LOG=1 packer build -only="centos-6-cloud-kvm" packer-centos-6.json
 ```

# Credits

These Packer scripts were originally derived from [Christoph Hartmann's packer-rhel project](https://github.com/TelekomLabs/packer-rhel).
