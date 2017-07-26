clear all;
close all;

bashFolder=['tbss-bashs' datestr(datetime,'yyyymmddHHMMSS')];
resultsFolder='/data/fasttemp/uqmbonya/faceData/Results/';
subjectsFolder=[resultsFolder 'dtiAnalysed/'];
tbssFolder=[resultsFolder 'TBSS/'];
mkdir(tbssFolder);

subjectsG1={...
   '11','12','13','14','15','16','17','18','19','110','111','112','113',...
   '114','115','116','117','118','119','120','121'...
   };
subjectsG2={...
   '21','22','23','24','25','26','27','28','29','210','211','212','213',...
   '214','215','216','217','219','220','221','222'...
   };

if(~exist([bashFolder]))
    mkdir([bashFolder]);
end;
fid=fopen([bashFolder '/tbss-run.sh'],'wt'); 
fprintf(fid,'#!/bin/bash -p \n'); 
for i=1:length(subjectsG1)
    fprintf(fid,'%s \n',['cp ' subjectsFolder ...
        subjectsG1{i} '/' subjectsG1{i} '-dtiFitted_FA.nii.gz ' ...
        tbssFolder 'G1_' subjectsG1{i} '-dtiFitted_FA.nii.gz']);
end;
for i=1:length(subjectsG2)
    fprintf(fid,'%s \n',['cp ' subjectsFolder ...
        subjectsG2{i} '/' subjectsG2{i} '-dtiFitted_FA.nii.gz ' ...
        tbssFolder 'G2_' subjectsG2{i} '-dtiFitted_FA.nii.gz']);
end;
fprintf(fid,'%s \n',['cd ' tbssFolder]);
fprintf(fid,'%s \n','tbss_1_preproc *.nii.gz');
fprintf(fid,'%s \n','tbss_2_reg -T');
fprintf(fid,'%s \n','tbss_3_postreg -S');
fprintf(fid,'%s \n','tbss_4_prestats 0.2');
fprintf(fid,'%s \n','cd stats');
fprintf(fid,'%s \n',['design_ttest2 design ' num2str(length(subjectsG1)) ...
    ' ' num2str(length(subjectsG2))]);
fprintf(fid,'%s \n', ...
    'randomise -i all_FA_skeletonised -o tbss -m mean_FA_skeleton_mask -d design.mat -t design.con -n 500 --T2');
fclose(fid);
disp('Run the following command in a terminal after all DTI steps finished: ');
a=cd;
disp(['bash ' a '/' bashFolder '/tbss-run.sh']);
