function write_mrml_bilateral_parcels(atlas_folder, output_folder, kept_IDs, suffix)

mrml_all_cluster = [atlas_folder filesep 'clustered_tracts_display_100_percent.mrml']; %"clustered_tracts_display_100_percent"

fileID = fopen(mrml_all_cluster,'r');
mrml_cell = textscan(fileID,'%s', 'Delimiter','\n');
mrml_cell = mrml_cell{1, 1};
fclose(fileID);

output_selected_atlas_mrml = [output_folder filesep 'scene_' suffix '.mrml'];

f = fopen(output_selected_atlas_mrml, 'w');
fprintf(f, '%s\n', mrml_cell{1});

line = '<ModelDisplay';
fprintf(f, '%s\n', line);
line = ['id="vtkMRMLModelDisplayNode' suffix '"  name="ModelDisplay"  hideFromEditors="true"  selectable="true"  selected="false"  color="0.5 0.5 0.5"  edgeColor="0 0 0"  selectedColor="1 0 0"  selectedAmbient="0.4"  ambient="0"  diffuse="1"  selectedSpecular="0.5"  specular="0"  power="1"  opacity="1"  pointSize="1"  lineWidth="1"  representation="2"  lighting="true"  interpolation="1"  shading="true"  visibility="true"  edgeVisibility="false"  clipping="false"  sliceIntersectionVisibility="false"  sliceIntersectionThickness="1"  frontfaceCulling="false"  backfaceCulling="true"  scalarVisibility="false"  vectorVisibility="false"  tensorVisibility="false"  interpolateTexture="false"  scalarRangeFlag="2"  autoScalarRange="true"  scalarRange="0 100"  ></ModelDisplay>'];
fprintf(f, '%s\n', line);

line = '<ModelHierarchy';
fprintf(f, '%s\n', line);
line = ['id="vtkMRMLModelHierarchyNode' suffix '"  name="Hierarchy' suffix '"  hideFromEditors="false"  selectable="true"  selected="false"  sortingValue="0"  allowMultipleChildren="true"  displayNodeID="vtkMRMLModelDisplayNode' suffix '"  expanded="true"  ></ModelHierarchy>'];
fprintf(f, '%s\n', line);

kept_lines = (kept_IDs - 1) .* 16 + 1 + 1;
for i = kept_lines
    for j = 0:15
        line = mrml_cell{i+j};
        k = strfind(line, 'fileName');
        
        if ~isempty(k)
           line = [line(1:k+9) atlas_folder filesep line(k+10:end)];
        end
        
        line = strrep(line, 'SubsamplingRatio="0.0134228187919"', 'SubsamplingRatio="1.0"'); 
        
        line = strrep(line, 'vtkMRMLFiberBundleStorageNode', ['vtkMRMLFiberBundleStorageNode', suffix]);
        line = strrep(line, 'vtkMRMLFiberBundleLineDisplayNode', ['vtkMRMLFiberBundleLineDisplayNode', suffix]);
        line = strrep(line, 'vtkMRMLFiberBundleTubeDisplayNode', ['vtkMRMLFiberBundleTubeDisplayNode', suffix]);
        line = strrep(line, 'vtkMRMLFiberBundleGlyphDisplayNode', ['vtkMRMLFiberBundleGlyphDisplayNode', suffix]);
        line = strrep(line, 'vtkMRMLFiberBundleNode', ['vtkMRMLFiberBundleNode', suffix]);
        line = strrep(line, 'vtkMRMLDiffusionTensorDisplayPropertiesNode', ['vtkMRMLDiffusionTensorDisplayPropertiesNode', suffix]);
        line = strrep(line, 'vtkMRMLModelHierarchyNode', ['vtkMRMLModelHierarchyNode', suffix]);

        fprintf(f, '%s\n', line);
        
        k1 = strfind(line, 'vtkMRMLFiberBundleNode'); 
        if ~isempty(k1)
           k2 = strfind(line, 'name');
           vtkMRMLFiberBundleNode_id = line(k1+length('vtkMRMLFiberBundleNode'):k2-4);
        end
    end
    
    line = '<ModelHierarchy';
    fprintf(f, '%s\n', line);
    line = ['id="vtkMRMLModelHierarchyNode' vtkMRMLFiberBundleNode_id '"  name="ModelHierarchy"  hideFromEditors="true"  selectable="true"  selected="false"  parentNodeRef="vtkMRMLModelHierarchyNode' suffix '"  associatedNodeRef="vtkMRMLFiberBundleNode' vtkMRMLFiberBundleNode_id '"  sortingValue="1"  allowMultipleChildren="true"  expanded="true"  ></ModelHierarchy>'];
    fprintf(f, '%s\n', line);
end

fprintf(f, '%s\n', mrml_cell{end});
fclose(f);
