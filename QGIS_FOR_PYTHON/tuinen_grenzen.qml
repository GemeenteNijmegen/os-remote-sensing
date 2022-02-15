<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis minScale="100000000" labelsEnabled="0" simplifyAlgorithm="0" simplifyDrawingHints="1" simplifyDrawingTol="1" simplifyLocal="1" simplifyMaxScale="1" version="3.16.7-Hannover" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0" readOnly="0" maxScale="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <temporal startField="" durationField="" endField="" endExpression="" accumulate="0" fixedDuration="0" enabled="0" startExpression="" mode="0" durationUnit="min">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <renderer-v2 enableorderby="0" forceraster="0" type="singleSymbol" symbollevels="0">
    <symbols>
      <symbol clip_to_extent="1" type="fill" name="0" force_rhr="0" alpha="1">
        <layer pass="0" class="SimpleFill" enabled="1" locked="0">
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="77,175,74,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="255,255,255,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.4"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="no"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <rotation/>
    <sizescale/>
  </renderer-v2>
  <customproperties>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="variableNames"/>
    <property key="variableValues"/>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
    <DiagramCategory width="15" showAxis="1" labelPlacementMethod="XHeight" penWidth="0" opacity="1" spacingUnitScale="3x:0,0,0,0,0,0" maxScaleDenominator="1e+08" diagramOrientation="Up" rotationOffset="270" penAlpha="255" lineSizeType="MM" sizeType="MM" penColor="#000000" minimumSize="0" spacing="5" scaleDependency="Area" scaleBasedVisibility="0" height="15" direction="0" barWidth="5" backgroundColor="#ffffff" sizeScale="3x:0,0,0,0,0,0" spacingUnit="MM" enabled="0" lineSizeScale="3x:0,0,0,0,0,0" backgroundAlpha="255" minScaleDenominator="0">
      <fontProperties style="" description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0"/>
      <attribute label="" field="" color="#000000"/>
      <axisSymbol>
        <symbol clip_to_extent="1" type="line" name="" force_rhr="0" alpha="1">
          <layer pass="0" class="SimpleLine" enabled="1" locked="0">
            <prop k="align_dash_pattern" v="0"/>
            <prop k="capstyle" v="square"/>
            <prop k="customdash" v="5;2"/>
            <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="customdash_unit" v="MM"/>
            <prop k="dash_pattern_offset" v="0"/>
            <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="dash_pattern_offset_unit" v="MM"/>
            <prop k="draw_inside_polygon" v="0"/>
            <prop k="joinstyle" v="bevel"/>
            <prop k="line_color" v="35,35,35,255"/>
            <prop k="line_style" v="solid"/>
            <prop k="line_width" v="0.26"/>
            <prop k="line_width_unit" v="MM"/>
            <prop k="offset" v="0"/>
            <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="offset_unit" v="MM"/>
            <prop k="ring_filter" v="0"/>
            <prop k="tweak_dash_pattern_on_corners" v="0"/>
            <prop k="use_custom_dash" v="0"/>
            <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" name="name" value=""/>
                <Option name="properties"/>
                <Option type="QString" name="type" value="collection"/>
              </Option>
            </data_defined_properties>
          </layer>
        </symbol>
      </axisSymbol>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings showAll="1" obstacle="0" dist="0" linePlacementFlags="18" priority="0" zIndex="0" placement="1">
    <properties>
      <Option type="Map">
        <Option type="QString" name="name" value=""/>
        <Option name="properties"/>
        <Option type="QString" name="type" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
    <activeChecks/>
    <checkConfiguration type="Map">
      <Option type="Map" name="QgsGeometryGapCheck">
        <Option type="double" name="allowedGapsBuffer" value="0"/>
        <Option type="bool" name="allowedGapsEnabled" value="false"/>
        <Option type="QString" name="allowedGapsLayer" value=""/>
      </Option>
    </checkConfiguration>
  </geometryOptions>
  <legend type="default-vector"/>
  <referencedLayers/>
  <fieldConfiguration>
    <field configurationFlags="None" name="fid">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="identificatieLokaalID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="kadastraleGemeenteCode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="sectie">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="perceelnummer">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gid">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="pand_identificatie">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="bouwjaar">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="status">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gebruiksdoel">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="oppervlakte_min">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="oppervlakte_max">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="aantal_verblijfsobjecten">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="rdf_seealso">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="opp">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" name="" index="0"/>
    <alias field="identificatieLokaalID" name="" index="1"/>
    <alias field="kadastraleGemeenteCode" name="" index="2"/>
    <alias field="sectie" name="" index="3"/>
    <alias field="perceelnummer" name="" index="4"/>
    <alias field="gid" name="" index="5"/>
    <alias field="pand_identificatie" name="" index="6"/>
    <alias field="bouwjaar" name="" index="7"/>
    <alias field="status" name="" index="8"/>
    <alias field="gebruiksdoel" name="" index="9"/>
    <alias field="oppervlakte_min" name="" index="10"/>
    <alias field="oppervlakte_max" name="" index="11"/>
    <alias field="aantal_verblijfsobjecten" name="" index="12"/>
    <alias field="rdf_seealso" name="" index="13"/>
    <alias field="opp" name="" index="14"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" field="fid" expression=""/>
    <default applyOnUpdate="0" field="identificatieLokaalID" expression=""/>
    <default applyOnUpdate="0" field="kadastraleGemeenteCode" expression=""/>
    <default applyOnUpdate="0" field="sectie" expression=""/>
    <default applyOnUpdate="0" field="perceelnummer" expression=""/>
    <default applyOnUpdate="0" field="gid" expression=""/>
    <default applyOnUpdate="0" field="pand_identificatie" expression=""/>
    <default applyOnUpdate="0" field="bouwjaar" expression=""/>
    <default applyOnUpdate="0" field="status" expression=""/>
    <default applyOnUpdate="0" field="gebruiksdoel" expression=""/>
    <default applyOnUpdate="0" field="oppervlakte_min" expression=""/>
    <default applyOnUpdate="0" field="oppervlakte_max" expression=""/>
    <default applyOnUpdate="0" field="aantal_verblijfsobjecten" expression=""/>
    <default applyOnUpdate="0" field="rdf_seealso" expression=""/>
    <default applyOnUpdate="0" field="opp" expression=""/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" unique_strength="1" field="fid" notnull_strength="1" constraints="3"/>
    <constraint exp_strength="0" unique_strength="0" field="identificatieLokaalID" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="kadastraleGemeenteCode" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="sectie" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="perceelnummer" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="gid" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="pand_identificatie" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="bouwjaar" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="status" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="gebruiksdoel" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="oppervlakte_min" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="oppervlakte_max" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="aantal_verblijfsobjecten" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="rdf_seealso" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="opp" notnull_strength="0" constraints="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="fid"/>
    <constraint exp="" desc="" field="identificatieLokaalID"/>
    <constraint exp="" desc="" field="kadastraleGemeenteCode"/>
    <constraint exp="" desc="" field="sectie"/>
    <constraint exp="" desc="" field="perceelnummer"/>
    <constraint exp="" desc="" field="gid"/>
    <constraint exp="" desc="" field="pand_identificatie"/>
    <constraint exp="" desc="" field="bouwjaar"/>
    <constraint exp="" desc="" field="status"/>
    <constraint exp="" desc="" field="gebruiksdoel"/>
    <constraint exp="" desc="" field="oppervlakte_min"/>
    <constraint exp="" desc="" field="oppervlakte_max"/>
    <constraint exp="" desc="" field="aantal_verblijfsobjecten"/>
    <constraint exp="" desc="" field="rdf_seealso"/>
    <constraint exp="" desc="" field="opp"/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig sortExpression="" actionWidgetStyle="dropDown" sortOrder="0">
    <columns>
      <column hidden="0" type="field" name="fid" width="-1"/>
      <column hidden="0" type="field" name="identificatieLokaalID" width="-1"/>
      <column hidden="0" type="field" name="kadastraleGemeenteCode" width="-1"/>
      <column hidden="0" type="field" name="sectie" width="-1"/>
      <column hidden="0" type="field" name="perceelnummer" width="-1"/>
      <column hidden="0" type="field" name="gid" width="-1"/>
      <column hidden="0" type="field" name="pand_identificatie" width="-1"/>
      <column hidden="0" type="field" name="bouwjaar" width="-1"/>
      <column hidden="0" type="field" name="status" width="-1"/>
      <column hidden="0" type="field" name="gebruiksdoel" width="-1"/>
      <column hidden="0" type="field" name="oppervlakte_min" width="-1"/>
      <column hidden="0" type="field" name="oppervlakte_max" width="-1"/>
      <column hidden="0" type="field" name="aantal_verblijfsobjecten" width="-1"/>
      <column hidden="0" type="field" name="rdf_seealso" width="-1"/>
      <column hidden="0" type="field" name="opp" width="-1"/>
      <column hidden="1" type="actions" width="-1"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <storedexpressions/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
Formulieren van QGIS kunnen een functie voor Python hebben die wordt aangeroepen wanneer het formulier wordt geopend.

Gebruik deze functie om extra logica aan uw formulieren toe te voegen.

Voer de naam van de functie in in het veld "Python Init function".

Een voorbeeld volgt hieronder:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field name="aantal_verblijfsobjecten" editable="1"/>
    <field name="bouwjaar" editable="1"/>
    <field name="fid" editable="1"/>
    <field name="gebruiksdoel" editable="1"/>
    <field name="gid" editable="1"/>
    <field name="identificatieLokaalID" editable="1"/>
    <field name="kadastraleGemeenteCode" editable="1"/>
    <field name="opp" editable="1"/>
    <field name="oppervlakte_max" editable="1"/>
    <field name="oppervlakte_min" editable="1"/>
    <field name="pand_identificatie" editable="1"/>
    <field name="perceelnummer" editable="1"/>
    <field name="rdf_seealso" editable="1"/>
    <field name="sectie" editable="1"/>
    <field name="status" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="aantal_verblijfsobjecten" labelOnTop="0"/>
    <field name="bouwjaar" labelOnTop="0"/>
    <field name="fid" labelOnTop="0"/>
    <field name="gebruiksdoel" labelOnTop="0"/>
    <field name="gid" labelOnTop="0"/>
    <field name="identificatieLokaalID" labelOnTop="0"/>
    <field name="kadastraleGemeenteCode" labelOnTop="0"/>
    <field name="opp" labelOnTop="0"/>
    <field name="oppervlakte_max" labelOnTop="0"/>
    <field name="oppervlakte_min" labelOnTop="0"/>
    <field name="pand_identificatie" labelOnTop="0"/>
    <field name="perceelnummer" labelOnTop="0"/>
    <field name="rdf_seealso" labelOnTop="0"/>
    <field name="sectie" labelOnTop="0"/>
    <field name="status" labelOnTop="0"/>
  </labelOnTop>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"fid"</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
