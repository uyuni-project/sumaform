<?xml version="1.0" ?>
<!-- Transformation of libvirt definition for ppc64le guests -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- pseries machines have no ACPI, APIC nor PAE -->
  <xsl:template match="/domain/features/acpi | /domain/features/apic | /domain/features/pae"/>

  <!-- The ppc64le images use 4096-byte sectors -->
  <xsl:template match="/domain/devices/disk[@device='disk']">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <blockio logical_block_size='4096' physical_block_size='4096'/>
    </xsl:copy>
  </xsl:template>

  <!-- pseries has no IDE: put the combustion CD-ROM on SCSI -->
  <xsl:template match="/domain/devices/disk[@device='cdrom']/target">
    <target dev='sda' bus='scsi'/>
  </xsl:template>

  <!-- Drop the IDE drive address, if any, and let libvirt assign a SCSI one -->
  <xsl:template match="/domain/devices/disk[@device='cdrom']/address"/>

  <!-- The initrd on the images has virtio_scsi but not ibmvscsi -->
  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <controller type='scsi' index='0' model='virtio-scsi'/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy the rest -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
