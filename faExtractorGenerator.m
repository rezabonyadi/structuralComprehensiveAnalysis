clear all;
close all;

bashFolder=['faExtractor-bashs' datestr(datetime,'yyyymmddHHMMSS')];
root='/data/fasttemp/uqmbonya/faceData/';
resultsFolder=[root 'Results-DTI/'];
subjectsFolder=[resultsFolder 'dtiAnalysed/'];
masksFolder=[root 'Masks/'];
faFolder=[resultsFolder 'faExtracted-RUF/'];
mkdir(faFolder);

roiMask='UFR_bin.nii.gz';
mainAtlas='/usr/share/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz';

subjects={...
   '11','12','13','14','15','16','17','18','19','110','111','112','113',...
   '114','115','116','117','118','119','120','121'...
   '21','22','23','24','25','26','27','28','29','210','211','212','213',...
   '214','215','216','217','219','220','221','222'...
   };
if(~exist([bashFolder]))
    mkdir([bashFolder]);
end;
fid=fopen([bashFolder '/faExtractor-run.sh'],'wt'); 
fprintf(fid,'#!/bin/bash -p \n'); 
for i=1:length(subjects)
    subFolder=subjectsFolder;
    subFile=[subFolder subjects{i} '/' subjects{i} '-dtiFitted_FA.nii.gz'];
    transformedSub=[faFolder subjects{i} '-FA_transformed.nii.gz'];
    transformedMat=[faFolder subjects{i} '-transformed-mat.mat'];
%     The following optimally maps your data to the space of the mainAtals.
    fprintf(fid,'%s \n',['flirt -in ' subFile ' -ref ' mainAtlas ... 
        ' -out ' transformedSub ' -omat ' transformedMat ...
        ' -bins 256 -cost normmi -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -interp trilinear']);    
    roiMaskFile=[masksFolder roiMask];
    transformedMaskedFA=[faFolder 'extracted-FA.txt'];
    fprintf(fid,'%s \n',['val=$(fslmeants -i ' transformedSub ' -m ' ...
        roiMaskFile ')']);
    fprintf(fid,'%s \n',['echo -n sub_' subjects{i} '= >> ' transformedMaskedFA]);
    fprintf(fid,'%s \n',['echo ${val} >> ' transformedMaskedFA]);
end;
fclose(fid);
disp('Run the following command in a terminal after all DTI steps finished: ');
a=cd;
disp(['bash ' a '/' bashFolder '/faExtractor-run.sh']);
