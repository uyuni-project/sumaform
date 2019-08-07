<?xml version="1.0" ?>
<!-- Add sysinfo on the VM to obfuscate QEMU in dmidecode output -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Ensure the sysinfo contains no QEMU -->
  <xsl:template match="/domain/os">
    <xsl:element name="sysinfo">
      <xsl:attribute name="type">smbios</xsl:attribute>
      <xsl:element name="bios">
        <xsl:element name="entry">
          <xsl:attribute name="name">vendor</xsl:attribute>
          <xsl:text>SUSE</xsl:text>
        </xsl:element>
      </xsl:element>
      <xsl:element name="system">
        <xsl:element name="entry">
          <xsl:attribute name="name">manufacturer</xsl:attribute>
          <xsl:text>SUSE</xsl:text>
        </xsl:element>
      </xsl:element>
      <xsl:element name="baseBoard">
        <xsl:element name="entry">
          <xsl:attribute name="name">manufacturer</xsl:attribute>
          <xsl:text>SUSE</xsl:text>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <!-- DMI types 4 and 17 aren't affected by the smbios config, use qemu args to change them -->
    <xsl:element name="commandline" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">-smbios</xsl:attribute>
      </xsl:element>
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">type=17,manufacturer=SUSE</xsl:attribute>
      </xsl:element>
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">-smbios</xsl:attribute>
      </xsl:element>
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">type=4,manufacturer=SUSE</xsl:attribute>
      </xsl:element>
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">-smbios</xsl:attribute>
      </xsl:element>
      <xsl:element name="arg" namespace="http://libvirt.org/schemas/domain/qemu/1.0">
        <xsl:attribute name="value">type=3,manufacturer=SUSE</xsl:attribute>
      </xsl:element>
    </xsl:element>
    <xsl:element name="os">
      <xsl:element name="smbios">
        <xsl:attribute name="mode">sysinfo</xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- Copy the rest -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
