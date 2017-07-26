function runMriConvert(fid,inFolder,outFolder,nameFile)
listFiles=dir(inFolder);
firstFile=listFiles(3).name;

fprintf(fid,'%s \n', ...
    ['mri_convert ' inFolder firstFile ' ' outFolder nameFile '.nii']);

