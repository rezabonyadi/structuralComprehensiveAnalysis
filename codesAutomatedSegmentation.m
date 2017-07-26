clear all;
close all;
%delete(gcp);
isCluster=1;
useTemp=1;
userInfo.user='uqmbonya';
addresses.freesurferAddress='/data/lfs2/software/ubuntu14/freesurfer-v6-2017-03-08';
addresses.fslAddress='/usr/share/fsl/5.0/';
addresses.rootDir='/data/dumu/reutens/uqmbonya/projects/Maryam/Facestudy/fmriData/rawData/';
%'/data/dumu/reutens/uqmbonya/DTIexample/tutorial3/';
addresses.tempDir='/data/fasttemp/uqmbonya/faceData/';
addresses.mriRaw='AllData/';
addresses.struc.folder='MP2RAGE/';
addresses.dti.folder='DTI/';
addresses.analysesResults='Results/';
addresses.struc.nifti='niftiSegmentation/';
addresses.struc.segmented='segmented/';
addresses.dti.nifti='niftiDti/';
addresses.dti.anylysed='dtiAnalysed/';

run.dti.analyses=1;
run.dti.convert=1;

run.struc.segmentation=0;
run.struc.convert=0;

% subjects={...
%    '21','22','23','24','25','26','27','28','29','210','211','212','213',...
%    '214','215','216','217','219','220','221','222'...
%    };
subjects={...
   '11','12','13','14','15','16','17','18','19','110','111','112','113',...
   '114','115','116','117','118','119','120','121'...
   };
%  subjects={...
%     '14','15'
%     };   

if(useTemp)
%     % The code copies the raw data from the miRaw to the tempDir folder
%     % first
     if(~exist([addresses.tempDir addresses.mriRaw]))
         mkdir([addresses.tempDir addresses.mriRaw]);
     end;
% 
    %% Copy data from original Address to a temporary address
    for i=1:length(subjects)
        disp(['Copying subject ' subjects{i}]);
        if(~exist([addresses.tempDir addresses.mriRaw subjects{i}]))
            mkdir([addresses.tempDir addresses.mriRaw subjects{i}]);
        end;
        copyfile([addresses.rootDir addresses.mriRaw subjects{i} '/' addresses.struc.folder],...
            [addresses.tempDir addresses.mriRaw subjects{i} '/' addresses.struc.folder]);
        copyfile([addresses.rootDir addresses.mriRaw subjects{i} '/' addresses.dti.folder],...
            [addresses.tempDir addresses.mriRaw subjects{i} '/' addresses.dti.folder]);        
    end;
    addresses.rootDir=addresses.tempDir;
end;    
addresses.mriRaw=[addresses.rootDir addresses.mriRaw];
addresses.analysesResults=[addresses.rootDir addresses.analysesResults];

%% Generate the bash files for each subject
bashFolder=['bashs' datestr(datetime,'yyyymmddHHMMSS')];
for i=1:length(subjects)
    fid=prepareBashFile(subjects{i},addresses,bashFolder);    
    if(run.struc.convert)
        inFolder=[addresses.mriRaw subjects{i} '/' addresses.struc.folder];
        outFolder=[addresses.analysesResults  addresses.struc.nifti subjects{i} '/'];
        if(~exist([outFolder]))
            mkdir([outFolder]);
        end;
        runMriConvert(fid,inFolder,outFolder,subjects{i});
    end;
    if(run.struc.segmentation)
        outFolder=[addresses.analysesResults addresses.struc.segmented subjects{i} '/'];
        if(~exist([outFolder]))
            mkdir([outFolder]);
        end;    
        inFile=[addresses.analysesResults addresses.struc.nifti subjects{i} '/'];
        runSegmentation(fid,inFile,outFolder,subjects{i});
    end;
    if(run.dti.convert)
        inFolder=[addresses.mriRaw subjects{i} '/' addresses.dti.folder];
        outFolder=[addresses.analysesResults  addresses.dti.nifti subjects{i} '/'];
        if(~exist([outFolder]))
            mkdir([outFolder]);
        end;
        runMriConvert(fid,inFolder,outFolder,subjects{i});
    end;
    if(run.dti.analyses)
        inFolder=[addresses.analysesResults  addresses.dti.nifti subjects{i} '/'];        
        outFolder=[addresses.analysesResults  addresses.dti.anylysed subjects{i} '/'];
        if(~exist([outFolder]))
            mkdir([outFolder]);
        end;
        runDTIAnalyses(fid,inFolder,outFolder,subjects{i});
    end;
    fclose(fid);
end;

%% Generate the final bash file for all subjects
fid=fopen([bashFolder '/bulkRun.sh'],'wt');
fprintf(fid,'#!/bin/bash -p \n');   
a=cd;
for i=1:length(subjects)
    if(isCluster)
        fprintf(fid,'%s \n',['qbatch -q big.q -- bash ' a '/' bashFolder '/subjectBash_' subjects{i} '.sh']);
    else
        fprintf(fid,'%s \n',['bash ' a '/' bashFolder '/subjectBash_' subjects{i} '.sh']);
   end;
end;

fclose(fid);
%if(~isCluster)
    disp('Run the following command in a terminal: ');
    disp(['bash ' a '/' bashFolder '/bulkRun.sh']);
%else
%    disp('Run the following command in a terminal to run on the cai cluster: '); 
%    disp(['ssh -p 2200 ' userInfo.user '@cai-zlock.cai.uq.edu.au -t "bash -ic ' a '/' bashFolder '/bulkRun.sh"']);
%end;

