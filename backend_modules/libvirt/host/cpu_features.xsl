<?xml version="1.0" ?>
<!-- Transformation of libvirt definition for RHEL9 and derivatives -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Features for x86-64 v2 -->
  <xsl:template match="/domain/cpu[@mode = 'host-model']">
    <xsl:element name="cpu">
      <xsl:apply-templates select="node()|@*"/>
      <xsl:text>  </xsl:text>
      <feature policy='require' name='lahf_lm'/>
      <xsl:text>&#x0A;    </xsl:text>
      <feature policy='require' name='popcnt'/>
      <xsl:text>&#x0A;    </xsl:text>
      <feature policy='require' name='sse4.1'/>
      <xsl:text>&#x0A;    </xsl:text>
      <feature policy='require' name='sse4.2'/>
      <xsl:text>&#x0A;    </xsl:text>
      <feature policy='require' name='ssse3'/>
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
