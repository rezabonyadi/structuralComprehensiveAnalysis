function runSegmentation(fid,inFile,outFolder,subject)
fprintf(fid,'%s \n',['SUBJECTS_DIR=' outFolder]); % Where to save segmented, folder    
fprintf(fid,'%s \n',['recon-all -i ' inFile ' -s ' subject '-segmented -all']);
