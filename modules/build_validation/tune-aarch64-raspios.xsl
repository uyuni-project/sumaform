<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSL transformation of libvirt definition for Raspberry Pi OS -->
 
  <xsl:output omit-xml-declaration="yes" indent="yes" />

  <!-- no IDE on aarch64, use SCSI instead -->
  <xsl:template match="@bus[.='ide']">
    <xsl:attribute name="bus"> <xsl:text>scsi</xsl:text> </xsl:attribute>
  </xsl:template>

  <!-- provide flash for booting -->
  <xsl:template match="os">
    <xsl:copy>
      <xsl:apply-templates select="*|@*" />
      <xsl:element name="loader">
        <xsl:attribute name="type"> <xsl:text>pflash</xsl:text> </xsl:attribute>
        <xsl:attribute name="readonly"> <xsl:text>yes</xsl:text> </xsl:attribute>
        <xsl:text>/usr/share/qemu/aavmf-aarch64-code.bin</xsl:text>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- change machine type -->
  <xsl:template match="type">
    <xsl:element name="type">
      <xsl:attribute name="machine"> <xsl:text>virt</xsl:text> </xsl:attribute>
      <xsl:text>hvm</xsl:text>
    </xsl:element>
  </xsl:template>

  <!-- use host passthrough mode for CPU -->
  <xsl:template match="cpu">
    <xsl:element name="cpu">
      <xsl:attribute name="mode"> <xsl:text>host-passthrough</xsl:text> </xsl:attribute>
      <xsl:attribute name="check"> <xsl:text>none</xsl:text> </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!-- work around https://gitlab.com/libvirt/libvirt/-/issues/177
       for <controller type="virtio-serial"> -->
  <!-- no LSI logic on aarch64, use virtio-scsi instead -->
  <xsl:template match="devices">
    <xsl:copy>
      <xsl:apply-templates select="*|@*" />
      <xsl:element name="controller">
        <xsl:attribute name="type"> <xsl:text>virtio-serial</xsl:text> </xsl:attribute>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>virtio-mmio</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="controller">
        <xsl:attribute name="type"> <xsl:text>scsi</xsl:text> </xsl:attribute>
        <xsl:attribute name="model"> <xsl:text>virtio-scsi</xsl:text> </xsl:attribute>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>virtio-mmio</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <!-- raspi OS needs USB keyboard and mouse, PCI video, and VNC graphics -->
      <xsl:element name="controller">
        <xsl:attribute name="type"> <xsl:text>usb</xsl:text> </xsl:attribute>
        <xsl:attribute name="index"> <xsl:text>0</xsl:text> </xsl:attribute>
        <xsl:attribute name="model"> <xsl:text>qemu-xhci</xsl:text> </xsl:attribute>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>pci</xsl:text> </xsl:attribute>
          <xsl:attribute name="domain"> <xsl:text>0x0000</xsl:text> </xsl:attribute>
          <xsl:attribute name="bus"> <xsl:text>0x00</xsl:text> </xsl:attribute>
          <xsl:attribute name="slot"> <xsl:text>0x07</xsl:text> </xsl:attribute>
          <xsl:attribute name="function"> <xsl:text>0x0</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="input">
        <xsl:attribute name="type"> <xsl:text>keyboard</xsl:text> </xsl:attribute>
        <xsl:attribute name="bus"> <xsl:text>usb</xsl:text> </xsl:attribute>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>usb</xsl:text> </xsl:attribute>
          <xsl:attribute name="bus"> <xsl:text>0</xsl:text> </xsl:attribute>
          <xsl:attribute name="port"> <xsl:text>1</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="input">
        <xsl:attribute name="type"> <xsl:text>mouse</xsl:text> </xsl:attribute>
        <xsl:attribute name="bus"> <xsl:text>usb</xsl:text> </xsl:attribute>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>usb</xsl:text> </xsl:attribute>
          <xsl:attribute name="bus"> <xsl:text>0</xsl:text> </xsl:attribute>
          <xsl:attribute name="port"> <xsl:text>2</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="graphics">
        <xsl:attribute name="type"> <xsl:text>vnc</xsl:text> </xsl:attribute>
        <xsl:attribute name="autoport"> <xsl:text>yes</xsl:text> </xsl:attribute>
        <xsl:element name="listen">
          <xsl:attribute name="type"> <xsl:text>address</xsl:text> </xsl:attribute>
          <xsl:attribute name="address"> <xsl:text>0.0.0.0</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="video">
        <xsl:element name="model">
          <xsl:attribute name="type"> <xsl:text>virtio</xsl:text> </xsl:attribute>
          <xsl:attribute name="vram"> <xsl:text>65536</xsl:text> </xsl:attribute>
          <xsl:attribute name="heads"> <xsl:text>1</xsl:text> </xsl:attribute>
          <xsl:attribute name="primary"> <xsl:text>yes</xsl:text> </xsl:attribute>
        </xsl:element>
        <xsl:element name="address">
          <xsl:attribute name="type"> <xsl:text>pci</xsl:text> </xsl:attribute>
          <xsl:attribute name="domain"> <xsl:text>0x0000</xsl:text> </xsl:attribute>
          <xsl:attribute name="bus"> <xsl:text>0x01</xsl:text> </xsl:attribute>
          <xsl:attribute name="slot"> <xsl:text>0x00</xsl:text> </xsl:attribute>
          <xsl:attribute name="function"> <xsl:text>0x0</xsl:text> </xsl:attribute>
          <xsl:attribute name="multifunction"> <xsl:text>on</xsl:text> </xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- work around https://gitlab.com/libvirt/libvirt/-/issues/177
       for <disk type="volume"> -->
  <xsl:template match="disk[@type='volume']">
    <xsl:copy>
      <xsl:apply-templates select="*|@*" />
      <xsl:element name="address">
        <xsl:attribute name="type"> <xsl:text>virtio-mmio</xsl:text> </xsl:attribute>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- work around https://gitlab.com/libvirt/libvirt/-/issues/177
       for <rng> -->
  <xsl:template match="rng" />

  <!-- raspi OS does not support ACPI -->
  <xsl:template match="acpi" />

  <!-- just copy the rest -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
