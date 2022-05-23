<?xml version="1.0" ?>
<!-- Transformation of libvirt definition for PXE-booted machines -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Machine type = Genuine Intel -->
  <xsl:template match="/domain/os">
    <xsl:element name="sysinfo">
      <xsl:attribute name="type">smbios</xsl:attribute>
      <xsl:text>&#x0A;    </xsl:text>
      <xsl:element name="system">
        <xsl:text>&#x0A;      </xsl:text>
        <xsl:element name="entry">
          <xsl:attribute name="name">manufacturer</xsl:attribute>
          <xsl:text>${manufacturer}</xsl:text>
        </xsl:element>
        <xsl:text>&#x0A;      </xsl:text>
        <xsl:element name="entry">
          <xsl:attribute name="name">product</xsl:attribute>
          <xsl:text>${product}</xsl:text>
        </xsl:element>
        <xsl:text>&#x0A;    </xsl:text>
      </xsl:element>
      <xsl:text>&#x0A;  </xsl:text>
    </xsl:element>
    <xsl:text>&#x0A;  </xsl:text>
    <xsl:element name="os">
      <xsl:text>&#x0A;    </xsl:text>
      <xsl:element name="smbios">
        <xsl:attribute name="mode">sysinfo</xsl:attribute>
      </xsl:element>
      <xsl:text>&#x0A;    </xsl:text>
      <xsl:element name="bootmenu">
        <xsl:attribute name="enable">yes</xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- Boot order = 2 for disk -->
  <xsl:template match="/domain/devices/disk[@device = 'disk']">
    <xsl:element name="disk">
      <xsl:apply-templates select="node()|@*"/>
      <xsl:text>  </xsl:text>
      <xsl:element name="boot">
        <xsl:attribute name="order">2</xsl:attribute>
      </xsl:element>
      <xsl:text>&#x0A;    </xsl:text>
    </xsl:element>
  </xsl:template>

  <!-- Boot order = 1 for network -->
  <xsl:template match="/domain/devices/interface[@type = 'network']">
    <xsl:element name="interface">
      <xsl:apply-templates select="node()|@*"/>
      <xsl:text>  </xsl:text>
      <xsl:element name="boot">
        <xsl:attribute name="order">1</xsl:attribute>
      </xsl:element>
      <xsl:text>&#x0A;    </xsl:text>
    </xsl:element>
  </xsl:template>

  <!-- Copy the rest -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
