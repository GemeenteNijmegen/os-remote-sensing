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
          <prop k="color" v="243,166,178,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="35,35,35,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
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
  <customproperties/>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
    <activeChecks type="StringList">
      <Option type="QString" value=""/>
    </activeChecks>
    <checkConfiguration/>
  </geometryOptions>
  <legend type="default-vector"/>
  <referencedLayers/>
  <fieldConfiguration>
    <field configurationFlags="None" name="fid">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="index">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gid">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="pand_identificatie">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="bouwjaar">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="status">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gebruiksdoel">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="oppervlakte_min">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="oppervlakte_max">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="aantal_verblijfsobjecten">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="rdf_seealso">
      <editWidget type="">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="fid" name="" index="0"/>
    <alias field="index" name="" index="1"/>
    <alias field="gid" name="" index="2"/>
    <alias field="pand_identificatie" name="" index="3"/>
    <alias field="bouwjaar" name="" index="4"/>
    <alias field="status" name="" index="5"/>
    <alias field="gebruiksdoel" name="" index="6"/>
    <alias field="oppervlakte_min" name="" index="7"/>
    <alias field="oppervlakte_max" name="" index="8"/>
    <alias field="aantal_verblijfsobjecten" name="" index="9"/>
    <alias field="rdf_seealso" name="" index="10"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" field="fid" expression=""/>
    <default applyOnUpdate="0" field="index" expression=""/>
    <default applyOnUpdate="0" field="gid" expression=""/>
    <default applyOnUpdate="0" field="pand_identificatie" expression=""/>
    <default applyOnUpdate="0" field="bouwjaar" expression=""/>
    <default applyOnUpdate="0" field="status" expression=""/>
    <default applyOnUpdate="0" field="gebruiksdoel" expression=""/>
    <default applyOnUpdate="0" field="oppervlakte_min" expression=""/>
    <default applyOnUpdate="0" field="oppervlakte_max" expression=""/>
    <default applyOnUpdate="0" field="aantal_verblijfsobjecten" expression=""/>
    <default applyOnUpdate="0" field="rdf_seealso" expression=""/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" unique_strength="1" field="fid" notnull_strength="1" constraints="3"/>
    <constraint exp_strength="0" unique_strength="0" field="index" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="gid" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="pand_identificatie" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="bouwjaar" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="status" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="gebruiksdoel" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="oppervlakte_min" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="oppervlakte_max" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="aantal_verblijfsobjecten" notnull_strength="0" constraints="0"/>
    <constraint exp_strength="0" unique_strength="0" field="rdf_seealso" notnull_strength="0" constraints="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="fid"/>
    <constraint exp="" desc="" field="index"/>
    <constraint exp="" desc="" field="gid"/>
    <constraint exp="" desc="" field="pand_identificatie"/>
    <constraint exp="" desc="" field="bouwjaar"/>
    <constraint exp="" desc="" field="status"/>
    <constraint exp="" desc="" field="gebruiksdoel"/>
    <constraint exp="" desc="" field="oppervlakte_min"/>
    <constraint exp="" desc="" field="oppervlakte_max"/>
    <constraint exp="" desc="" field="aantal_verblijfsobjecten"/>
    <constraint exp="" desc="" field="rdf_seealso"/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig sortExpression="" actionWidgetStyle="dropDown" sortOrder="0">
    <columns/>
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
  <editforminitcode><![CDATA[]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable/>
  <labelOnTop/>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression></previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
