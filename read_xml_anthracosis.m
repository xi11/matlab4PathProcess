%**************************************************************************
% This code extracts annotations from .xml format files and creates mask images.
% The size of the mask image will be the same as the raw .svs image.
% There were 4 Ids identified in the xml files:
% >> Id="1" Name="nerve without tumor"
% >> Id="2" Name="perineural invasion junction"
% >> Id="3" Name="tumor without nerve"
% >> Id="4" Name="nontumor without nerve"
% for each Id, a mask will be created and saved in .png format in the 'masks' folder.
%     
% written by Azam Hamidinekoo, May 2021
% adapted for Anthracosis project by Xiaoxi Pan, Oct 2023
%**************************************************************************


close all
clear
clc

root = pwd;
path_root = '/Volumes/plm5/TMP-IL/0_TMP-IL Projects/001TMP_IL Digital Pathology Group/Anthracosis project/Anthracosis 2023_PROSPECT/folder b1 (9-14-23)';
mask_dir = '/Volumes/plm5/TMP-IL/0_TMP-IL Projects/001TMP_IL Digital Pathology Group/Anthracosis project/Anthracosis 2023_PROSPECT/annotations';
dir_svs = dir(fullfile(path_root, '*.svs'));
show_results = 0;

for wsi = 1:5
    svs_file=[dir_svs(wsi).folder, '/', dir_svs(wsi).name];
    xml_file=strrep(svs_file,'svs','xml');
    
    savepath = fullfile(mask_dir,strrep(dir_svs(wsi).name,'.svs',''));
    if ~exist(savepath, 'dir')
    mkdir(savepath)
    end
    
    % ---------------  read the xml annotation -------------------------
    xDoc = xmlread(xml_file);
    Annots=xDoc.getElementsByTagName('Annotation'); % get a list of all the annotation tags
    for annoti = 0:Annots.getLength-1
        annotation=Annots.item(annoti);  % for each annotation tag
        
        Regions=annotation.getElementsByTagName('Region'); % get a list of all the region tags
        
        for regioni = 0:Regions.getLength-1
            Region=Regions.item(regioni);  % for each region tag
            
            %get a list of all the vertexes (which are in order)
            verticies=Region.getElementsByTagName('Vertex');
            xy{regioni+1}=zeros(verticies.getLength-1,2); % allocate space for them
            for vertexi = 0:verticies.getLength-1 %iterate through all verticies
                %get the x value of that vertex
                x=str2double(verticies.item(vertexi).getAttribute('X'));
                
                %get the y value of that vertex
                y=str2double(verticies.item(vertexi).getAttribute('Y'));
                xy{regioni+1}(vertexi+1,:)=[x,y]; % finally save them into the array
            end
        end
        % --------------    create the mask    ----------------------
        svsinfo=imfinfo(svs_file);
        s = 1; %base level of maximum resolution
        s2 = 1; % down sampling of 1:?
        hratio = svsinfo(s2).Height/svsinfo(s).Height;  %determine ratio
        wratio = svsinfo(s2).Width/svsinfo(s).Width;
        
        nrow=svsinfo(s2).Height;
        ncol=svsinfo(s2).Width;
        mask=zeros(nrow,ncol); %pre-allocate a mask

        for zz=1:length(xy) %for each region
            smaller_x=xy{zz}(:,1)*wratio; %down sample the region using the ratio
            smaller_y=xy{zz}(:,2)*hratio;
            
            %make a mask and add it to the current mask
            mask=mask+poly2mask(smaller_x,smaller_y,nrow,ncol);
        end
        % ----------------  show the result  ------------
        if show_results == 1
            figure
            imshow(mask)
        end
        % save the mask
        savepath2=[savepath,'\', strrep(dir_svs(wsi).name,'.svs',['_',num2str(annoti+1),'.png'])];
        disp(savepath2)
        imwrite(mask,savepath2)
        
        clear mask xy 
    end
end