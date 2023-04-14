<?xml version="1.0" encoding="UTF-8"?>
<!-- RELS-EXT -->
<xsl:stylesheet version="1.0"
    xmlns:java="http://xml.apache.org/xalan/java"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:foxml="info:fedora/fedora-system:def/foxml#"
    xmlns:fedora="info:fedora/fedora-system:def/relations-external#"
    xmlns:fedora-model="info:fedora/fedora-system:def/model#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:islandora-rels-ext="http://islandora.ca/ontology/relsext#" 
    xmlns:islandora="http://islandora.ca/ontology/relsext#" 
    xmlns:result="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    xmlns:encoder="xalan://java.net.URLEncoder" exclude-result-prefixes="rdf java">

    <xsl:variable name="single_valued_hashset_for_rels_ext" select="java:java.util.HashSet.new()"/>

    <xsl:template match="foxml:datastream[@ID='RELS-EXT']/foxml:datastreamVersion[last()]"
        name="index_RELS-EXT">
        <xsl:param name="content"/>
        <xsl:param name="prefix">RELS_EXT_</xsl:param>
        <xsl:param name="suffix">_ms</xsl:param>

        <!-- Clearing hash in case the template is ran more than once. -->
        <xsl:variable name="return_from_clear" select="java:clear($single_valued_hashset_for_rels_ext)"/>

        <xsl:apply-templates select="$content//rdf:Description/* | $content//rdf:description/*" mode="rels_ext_element">
          <xsl:with-param name="prefix" select="$prefix"/>
          <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>
 
            <!-- FLVC set parent fields -->
            <xsl:for-each select="$content//rdf:Description/fedora:isMemberOfCollection[@rdf:resource]">
                <field name="parent_collection_id_ms">
                <xsl:value-of select="@rdf:resource"/>
                </field>
                <xsl:if test="contains(@rdf:resource,':root')">
                  <field name="site_collection_id_ms">
                  <xsl:value-of select="@rdf:resource"/>
                  </field>
                </xsl:if>
                <xsl:variable name="walk_from_collection_pid">
                <xsl:value-of select="@rdf:resource"/>
                </xsl:variable>
                <xsl:variable name="query">select+%3Fobject+from+%3C%23ri%3E+where+%7B%3Fobject+%3Cfedora-model:hasModel%3E+%3Cinfo:fedora/islandora:collectionCModel%3E+%2E+%3C<xsl:value-of select="$walk_from_collection_pid"/>%3E+%3Cfedora-rels-ext:isMemberOfCollection%3E%2B+%3Fobject+%2E+%7D</xsl:variable>
                <xsl:variable name="sparqlUrl">http://localhost:8080/fedora/risearch?type=tuples&amp;lang=sparql&amp;limit=1000&amp;format=Sparql&amp;query=<xsl:value-of select="$query"/></xsl:variable>
                <xsl:variable name="sparql" select="document($sparqlUrl)"/>
                <xsl:for-each select="$sparql//result:object">
                  <field name="parent_collection_id_ms">
                  <xsl:value-of select="@uri"/>
                  </field>
                  <xsl:if test="contains(@uri,':root')">
                    <field name="site_collection_id_ms">
                    <xsl:value-of select="@uri"/>
                    </field>
                  </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$content//rdf:Description/fedora:isMemberOf[@rdf:resource]">
                <xsl:variable name="walk_from_parent_object_pid">
                <xsl:value-of select="@rdf:resource"/>
                </xsl:variable>
                <xsl:variable name="query2">select+%3Fobject+from+%3C%23ri%3E+where+%7B%3Fobject+%3Cfedora-model:hasModel%3E+%3Cinfo:fedora/islandora:collectionCModel%3E+%2E+%3C<xsl:value-of select="$walk_from_parent_object_pid"/>%3E+%3Cfedora-rels-ext:isMemberOfCollection%3E%2B+%3Fobject+%2E+%7D</xsl:variable>
                <xsl:variable name="sparqlUrl2">http://localhost:8080/fedora/risearch?type=tuples&amp;lang=sparql&amp;limit=1000&amp;format=Sparql&amp;query=<xsl:value-of select="$query2"/></xsl:variable>
                <xsl:variable name="sparql2" select="document($sparqlUrl2)"/>
                <xsl:for-each select="$sparql2//result:object">
                  <field name="parent_collection_id_ms">
                  <xsl:value-of select="@uri"/>
                  </field>
                  <xsl:if test="contains(@uri,':root')">
                    <field name="site_collection_id_ms">
                    <xsl:value-of select="@uri"/>
                    </field>
                  </xsl:if>
                  <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:intermediateCModel']">
                      <field name="parent_serial_id_ms">
                      <xsl:value-of select="$content//rdf:Description/fedora:isMemberOf/@rdf:resource"/>
                      </field>
                  </xsl:if>
                </xsl:for-each>
            </xsl:for-each>

            <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:pageCModel']">
                <field name="parent_book_id_ms">
                <xsl:value-of select="$content//rdf:Description/fedora:isMemberOf/@rdf:resource"/>
                </field>
            </xsl:if>

            <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:newspaperIssueCModel']">
                <field name="parent_newspaper_id_ms">
                <xsl:value-of select="$content//rdf:Description/fedora:isMemberOf/@rdf:resource"/>
                </field>
            </xsl:if>

            <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:newspaperPageCModel']">
                <field name="parent_issue_id_ms">
                <xsl:value-of select="$content//rdf:Description/fedora:isMemberOf/@rdf:resource"/>
                </field>
            </xsl:if>

            <xsl:for-each select="($content//rdf:Description/fedora:isMemberOf[@rdf:resource])[1] | ($content//rdf:Description/islandora:isComponentOf[@rdf:resource])[1]">
                <xsl:variable name="top_parent_query">select+%3Fobject+%3Fcollection+from+%3C%23ri%3E+where+%7B%3Fobject+%3Cfedora-rels-ext:isMemberOfCollection%3E+%3Fcollection+%2E+%3C<xsl:value-of select="@rdf:resource"/>%3E+%3Cfedora-rels-ext:isMemberOf%3E%2B+%3Fobject+%2E+%7D</xsl:variable>
                <xsl:variable name="top_parent_sparqlUrl">http://localhost:8080/fedora/risearch?type=tuples&amp;lang=sparql&amp;limit=1000&amp;format=Sparql&amp;query=<xsl:value-of select="$top_parent_query"/></xsl:variable>
                <xsl:variable name="top_parent_sparql" select="document($top_parent_sparqlUrl)"/>
                <xsl:for-each select="($top_parent_sparql//result:object)[1]">

                    <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:newspaperPageCModel']">
                        <field name="parent_newspaper_id_ms">
                        <xsl:value-of select="@uri"/>
                        </field>
                    </xsl:if>

                    <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:intermediateCModel']">
                        <field name="parent_serial_id_ms">
                        <xsl:value-of select="@uri"/>
                        </field>
                    </xsl:if>

                    <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:sp_pdf']">
                        <field name="parent_serial_id_ms">
                        <xsl:value-of select="@uri"/>
                        </field>
                    </xsl:if>

                    <xsl:if test="$content//rdf:Description/fedora-model:hasModel[@rdf:resource='info:fedora/islandora:intermediateSerialCModelStub']">
                        <field name="parent_serial_id_ms">
                        <xsl:value-of select="@uri"/>
                        </field>
                    </xsl:if>

                    <xsl:variable name="query3">select+%3Fobject+from+%3C%23ri%3E+where+%7B%3Fobject+%3Cfedora-model:hasModel%3E+%3Cinfo:fedora/islandora:collectionCModel%3E+%2E+%3C<xsl:value-of select="@uri"/>%3E+%3Cfedora-rels-ext:isMemberOfCollection%3E%2B+%3Fobject+%2E+%7D</xsl:variable>
                    <xsl:variable name="sparqlUrl3">http://localhost:8080/fedora/risearch?type=tuples&amp;lang=sparql&amp;limit=1000&amp;format=Sparql&amp;query=<xsl:value-of select="$query3"/></xsl:variable>
                    <xsl:variable name="sparql3" select="document($sparqlUrl3)"/>
                    <xsl:for-each select="$sparql3//result:object">
                      <field name="parent_collection_id_ms">
                      <xsl:value-of select="@uri"/>
                      </field>
                      <xsl:if test="contains(@uri,':root')">
                        <field name="site_collection_id_ms">
                        <xsl:value-of select="@uri"/>
                        </field>
                      </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>

    </xsl:template>

    <!-- Match elements, call underlying template. -->
    <xsl:template match="*[@rdf:resource]" mode="rels_ext_element">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>

      <xsl:call-template name="rels_ext_fields">
        <xsl:with-param name="prefix" select="$prefix"/>
        <xsl:with-param name="suffix" select="$suffix"/>
        <xsl:with-param name="type">uri</xsl:with-param>
        <xsl:with-param name="value" select="@rdf:resource"/>
      </xsl:call-template>
    </xsl:template>
    <xsl:template match="*[normalize-space(.)]" mode="rels_ext_element">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:if test="string($index_compound_sequence) = 'true' or (string($index_compound_sequence) = 'false' and not(self::islandora-rels-ext:* and starts-with(local-name(), 'isSequenceNumberOf')))">
        <xsl:call-template name="rels_ext_fields">
          <xsl:with-param name="prefix" select="$prefix"/>
          <xsl:with-param name="suffix" select="$suffix"/>
          <xsl:with-param name="type">literal</xsl:with-param>
          <xsl:with-param name="value" select="text()"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:template>

    <!-- Fork between fields without and with the namespace URI in the field
      name. -->
    <xsl:template name="rels_ext_fields">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:param name="type"/>
      <xsl:param name="value"/>

      <xsl:call-template name="rels_ext_field">
        <xsl:with-param name="prefix" select="$prefix"/>
        <xsl:with-param name="suffix" select="$suffix"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
      <xsl:call-template name="rels_ext_field">
        <xsl:with-param name="prefix" select="concat($prefix, namespace-uri())"/>
        <xsl:with-param name="suffix" select="$suffix"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </xsl:template>

    <!-- Actually create a field. -->
    <xsl:template name="rels_ext_field">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:param name="type"/>
      <xsl:param name="value"/>

    <xsl:variable name="dateValue">
      <xsl:call-template name="get_ISO8601_date">
        <xsl:with-param name="date" select="$value"/>
        <xsl:with-param name="pid" select="$PID"/>
        <xsl:with-param name="datastream" select="'RELS-EXT'"/>
      </xsl:call-template>
    </xsl:variable>
      <!-- Prevent multiple generating multiple instances of single-valued fields
      by tracking things in a HashSet -->
      <!-- The method java.util.HashSet.add will return false when the value is
      already in the set. -->
      <xsl:choose>
        <xsl:when
          test="java:add($single_valued_hashset_for_rels_ext, concat($prefix, local-name(), '_', $type, '_s'))">
          <field>
            <xsl:attribute name="name">
              <xsl:value-of select="concat($prefix, local-name(), '_', $type, '_s')"/>
            </xsl:attribute>
            <xsl:value-of select="$value"/>
          </field>
          <xsl:choose>
            <xsl:when test="@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#int'">
              <field>
                <xsl:attribute name="name">
                  <xsl:value-of select="concat($prefix, local-name(), '_', $type, '_l')"/>
                </xsl:attribute>
                <xsl:value-of select="$value"/>
              </field>
            </xsl:when>
            <xsl:when test="@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'">
              <xsl:if test="not(normalize-space($dateValue)='')">
                <field>
                  <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, local-name(), '_', $type, '_dt')"/>
                  </xsl:attribute>
                  <xsl:value-of select="$dateValue"/>
                </field>
              </xsl:if>
            </xsl:when>
            <xsl:when test="floor($value) = $value">
              <field>
                <xsl:attribute name="name">
                  <xsl:value-of select="concat($prefix, local-name(), '_', $type, '_intDerivedFromString_l')"/>
                </xsl:attribute>
                <xsl:value-of select="floor($value)"/>
              </field>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <field>
            <xsl:attribute name="name">
              <xsl:value-of select="concat($prefix, local-name(), '_', $type, $suffix)"/>
            </xsl:attribute>
            <xsl:value-of select="$value"/>
          </field>
          <xsl:if test="@rdf:datatype = 'http://www.w3.org/2001/XMLSchema#dateTime'">
            <xsl:if test="not(normalize-space($dateValue)='')">
              <field>
                <xsl:attribute name="name">
                  <xsl:value-of select="concat($prefix, local-name(), '_', $type, '_mdt')"/>
                </xsl:attribute>
                <xsl:value-of select="$dateValue"/>
              </field>
            </xsl:if>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
