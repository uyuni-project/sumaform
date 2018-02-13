# How to rebuild Packer images

 - Download and install [Packer](https://www.packer.io/downloads.html)
 - Run
 ```
 packer build <IMAGE_NAME>.json
 ```
 - in case of errors, run again with full logging:
 ```
 PACKER_LOG=1 packer build <IMAGE_NAME>.json
 ```

Note: packer will start QEMU to run a temporary virtual machine to build the image. Thus, the host you run packer on must be able to execute QEMU. Additionally, if you use a bridge to access the network from VMs, you should change the packer json file to adjust QEMU parameters accordingly, eg:

```json
"qemuargs": [
  [ "-m", "1024M" ],
  ["-machine", "type=pc,accel=kvm"],
  ["-net", "bridge"],
  ["-net", "nic,model=virtio"]
],
```

# Credits

These Packer scripts were originally derived from [Christoph Hartmann's packer-rhel project](https://github.com/TelekomLabs/packer-rhel).
