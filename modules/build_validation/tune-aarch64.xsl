<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSL transformation of libvirt definition for aarch64 VMs -->
 
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

  <!-- just copy the rest -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
