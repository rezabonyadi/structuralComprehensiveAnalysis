function fid=prepareBashFile(subject,addresses,bashFolder)
if(~exist([bashFolder]))
    mkdir([bashFolder]);
end;
fid=fopen([bashFolder '/subjectBash_' subject '.sh'],'wt');
    fprintf(fid,'#!/bin/bash -p \n');
fprintf(fid,'%s \n', ['export FREESURFER_HOME=' addresses.freesurferAddress]);
fprintf(fid,'%s \n', 'source $FREESURFER_HOME/SetUpFreeSurfer.sh');

fprintf(fid,'%s \n',['FSLDIR=' addresses.fslAddress]);% '
fprintf(fid,'%s \n','. ${FSLDIR}/etc/fslconf/fsl.sh');
fprintf(fid,'%s \n','PATH=${FSLDIR}/bin:${PATH}');
fprintf(fid,'%s \n','export FSLDIR PATH');
