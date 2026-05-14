function xpanded_jobs = xpandjobs(matlabbatch, info, sub_ind, dirs)

fprintf('\n');   
fprintf('======================\n');
fprintf('Running xpanded_jobs \n'); 
fprintf('======================\n');
fprintf('\n');

subject_ID = info.subject_IDs{sub_ind};

n_runs=length(info.run_names{sub_ind});

fprintf('With subject %s and %d runs ', subject_ID);
fprintf('\n');
fprintf('Length of matlabbatch: \n');
disp(length(matlabbatch));

%%% OBS!!! MOVEMENT PARAMETERS REMOVEDROW 200!!!!!!!

%--------------------------------------------------------------------------
% LOOP OVER TASKS
%--------------------------------------------------------------------------
for job_ind=1:length(matlabbatch)
    
    if strcmp(fieldnames(matlabbatch{job_ind}.spm),'stats')
        
        % Q: info.prefixstatus = true, info.prefix = ''
        
        if info.prefixstatus
            prefix=info.prefix;
        end % if 
        
        for stat_ind=1:length(matlabbatch{job_ind}.spm.stats)
            
            
            if exist(dirs.ffx_results,'dir')~=7
                    disp(['mkdir is trying to create: "' dirs.ffx_results '"']);
                    mkdir(dirs.ffx_results); 
            end % end if
            
            % SPM.mat file
                
            spm_mat_file = fullfile(dirs.ffx_results, info.spm_mat_file_name);
            
               
            %--------------------------------------------------------------------
            % MODEL SPECIFICATION - defining the design matrix
            %--------------------------------------------------------------------

            if strcmp(fieldnames(matlabbatch{job_ind}.spm.stats(stat_ind)),'fmri_spec')
                

                % Add the runs as spm sessions
                
            
                for run_ind=1:n_runs   
                
                    run_name=info.run_names{sub_ind}(run_ind);      

                    fprintf('Run in the following directory is prepared for specification:');
                    disp(run_name);
                    fprintf('\n');
                    
                    % Dir with preprocessed data files for this run:
                    data_files_path = fullfile(dirs.ffx_data,run_name);
                    
                    % Scans:
                    % TODO: Remove this function if this is so easy
                    scans = get_file_list(data_files_path, info.fct_data_file_pattern);
                    matlabbatch{job_ind}.spm.stats(stat_ind).fmri_spec.sess(run_ind).scans = cellstr(scans);
                    

                    % Setting defaults (I think this is a bug in SPM8, but I get errors if I don't):
                    matlabbatch{job_ind}.spm.stats.fmri_spec.sess(run_ind).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
                    matlabbatch{job_ind}.spm.stats.fmri_spec.sess(run_ind).regress = struct('name', {}, 'val', {});
                    matlabbatch{job_ind}.spm.stats.fmri_spec.sess(run_ind).hpf = 128;

                    %matlabbatch{job_ind}.spm.stats.fmri_spec.sess(run_ind).multi_reg = {''};

                    
                    %fprintf('\n scans: \n');
                    %disp(scans);
                    
                    % Onset and duration files give the conditions columns
                    % In interactive SPM it is callled multiple conditions
                    
                    
                    run_name_vector = [run_name{1}];
                    %ind = strfind(run_name_vector, '_para');
                    run_name_clean = run_name_vector(4);
                    
                    fprintf('\n run_name_clean: ');
                    disp(run_name_clean)
                    
                    
                    %%%MDD%%%
                    %onset_and_dur_file_name = cellstr(strcat('onsdur', subject_ID, '_run', run_name_clean, '.mat'));
                    %%%OVRL%%%
                    %onset_and_dur_file_name = cellstr(strcat('onset_and_durations_', subject_ID, '_run', run_name_clean, '.mat'));
                    %%%SURPRISAL (JOHANNAS)%%%     
                    %onset_and_dur_file_name = cellstr(strcat('onsdur', subject_ID, '_run', run_name_clean, '.mat'));
                    %%%SURPRISAL (RETOKENIZED)%%%    
                    
                    %fMRIprep
                    %onset_and_dur_file_name = cellstr(strcat(subject_ID, "_run-0", run_name_clean, '_merged.mat'));
                    onset_and_dur_file_name = cellstr(strcat(subject_ID, "_run-0", run_name_clean, '_exchange.mat'));
                    
                    
                    
                    %onset_and_dur_file_name = cellstr(strcat('onset_and_durations_PCP_', subject_ID, '_run', run_name_clean, '_adj_plus_1_TR.mat'));
                    fprintf('\n onset_and_dur_file_name')
                    disp(onset_and_dur_file_name)
                    
                    % Q: Why is this a list? is is just one file! I will
                    % try to make it just one file and see if it works.
                    % Look at the original file if you want to try the
                    % spm_select version instead.
                    % names_on_dur_file = spm_select('List', subjectPath, info.names_on_dur_dir_name, names_on_dur_file_name);
                    names_on_dur_file = fullfile(info.script_dir, info.onset_and_dur_dir_name, onset_and_dur_file_name);
                                
                    matlabbatch{job_ind}.spm.stats(stat_ind).fmri_spec.sess(run_ind).multi = cellstr(names_on_dur_file);
                
                    % User specified regressor part, add additive Pmod Columns ...
                    % Parametrization: not used in the EvLab analysis
                   
 % --------------------------------------------------------------------------------
                    
                    % TODO: If this is to be used, it needs to be fixed
 
                    if info.additive_pmod == 1
                        fprintf('\n ERROR: Ooops, in pmod mode \n');
%                         pmodPath = '/project/3011020.09/juludd/FFX/Additive_Pmod';
%                         load(fullfile(pmodPath,strcat('Big_X',info.Pmodname,'.mat')));
%                          
%                         SbjX = Big_X{sub_ind};
% 
%                         % Add movement parameters 
%                     
%                         rpPath=data_files_path; 
%                         rpFile=fullfile(rpPath, spm_select('List',rpPath,info.rpfile));
% 
%                         rpMat = load(rpFile);
%                     
%                         % Q: What is happening here? 
%                     
%                         if length(rpMat) > length(SbjX)
%                             rowdiff = length(rpMat) - length(SbjX);
%                             SbjX = [SbjX;zeros(rowdiff,size(SbjX,2))];
%                         elseif length(rpMat) < length(SbjX)
%                             diplay('Warning, movement paraments shorter than conds')
%                         end % end if elseif
% 
%                         if length(rpMat) == length(SbjX)
%                  
%                              %all_multi_reg = [SbjX(:,[1,3,5,7,9]), rpMat]; end; %OrigFormat    
%                              %all_multi_reg = [SbjX(:,[1:2:39]), rpMat]; end; %OrigFormat but Additive timebins 
%                              %all_multi_reg = [SbjX(:,[1,  3, 5, 9,11, ...
%                              %                         13,15,17,21,23, ...
%                              %                         25,27,29,33,35, ...
%                              %                         37,39,41,45,47]), rpMat]; end; %OrigFormat
%                              %but Additive timebins and remove AudFileLEngth
% 
%                              %all_multi_reg = [SbjX(:,[1:2:79]), rpMat]; end; %OrigFormat
%                              %all_multi_reg = [SbjX(:,[1:40]), rpMat]; end; 
%                              % Additive timebins, with words
% 
% 
%                              %all_multi_reg = [SbjX(:,[1,3,5,9,11]), rpMat]; end; %OrigFormat but remove AudFileLength
%                              %all_multi_reg = [SbjX(:,[1,3,5,7,9,11]), rpMat]; end; %AudFileLEngth
%                              %all_multi_reg = [SbjX(:,[1,3,5,7,9,11,13]), rpMat]; end; %4ComplColns
%                              %all_multi_reg = [SbjX(:,[7,9,11,13]), rpMat]; end; %4ComplColns minus first 3 controls
%                              %all_multi_reg = [SbjX(:,[1:2:15]), rpMat]; end; %TotalDepLength
%                              %all_multi_reg = [SbjX(:,[1,3,5,7,9,11]), rpMat]; end; %4ComplColns minus not redundant 320
%                              %all_multi_reg  = [SbjX(:,[1, 3, 5, 7, 9,11, ...
%                              %                        15,17,19,21,23,25]), rpMat]; end; % ''    ''   ''   ''  words
% 
%                             % Q: What is happening here?    
%                             all_multi_reg = [SbjX(:,[1,3,5,7,9,11,13,15,17,19]), rpMat]; 
%                         end % if rp length
%                         
%                         %4ComplColns_words
%            
%                         %%OrigFormat Aud File length above
% 
%                         %all_multi_reg = [SbjX(:,[1:2:39]), rpMat]; end; %TimebinFormat
%                         %all_multi_reg = [SbjX(:,[1:2:47]), rpMat]; end; %TimebinFormat
% 
%                         all_multi_reg_filename = strcat(fullfile(pmodPath,'All_multi_regs',strcat(subject_ID,info.Pmodname)),'.txt');
%                         dlmwrite(all_multi_reg_filename,all_multi_reg);
% 
%                         matlabatch{job_ind}.spm.stats(stat_ind).fmri_spec.sess(run_ind).multi_reg = ...
%                         {all_multi_reg_filename};
                        
% --------------------------------------------------------------------------------                        

                    else % if not additive pmod
                        
                        % Multiple regressors
                        % Add only movement parameters 
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%% I AM COMMENTING OUT THIS TO REMOVE MOVEMENT
                        %%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        rp_file = fullfile(data_files_path,  ...
                        spm_select('List',[data_files_path{1}] ,info.rp_file_pattern));

                        matlabbatch{job_ind}.spm.stats(stat_ind).fmri_spec.sess(run_ind).multi_reg = ...
                        cellstr(rp_file);   
                        
                        %%%%%%%%%%% UNCOMMENT ALL ABOVE TO ADD MOVEMENT
                        %%%%%%%%%%% PARAMETERS!!%%%%%%%%%%%%%%%%%%%%%%%

                    end % end if else additive pmod 
                  
                end % runs
        
                % Specify output dir:        
                matlabbatch{job_ind}.spm.stats(stat_ind).fmri_spec.dir=cellstr(dirs.ffx_results);
         
                matlabbatch{job_ind}.spm.stats(stat_ind).fmri_spec.mask = fullfile ('D:','fmri','ffx_scripts','ffx_scripts','first_level','MNI152_T1_2mm_brain_mask.nii');
                
            %------------------------------------------------------------------
            % MODEL ESTIMATION
            %------------------------------------------------------------------
            elseif strcmp(fieldnames(matlabbatch{job_ind}.spm.stats(stat_ind)),'fmri_est')
            
                fprintf('\n INSIDE FMRI_EST!!!!!! \n')
                
                matlabbatch{job_ind}.spm.stats(stat_ind).fmri_est.spmmat=cellstr(spm_mat_file);
                
            %------------------------------------------------------------------
            % CONTRAST GENERATION AND ESTIMATION
            %------------------------------------------------------------------
            elseif strcmp(fieldnames(matlabbatch{job_ind}.spm.stats(stat_ind)),'con')
                
                % Set the output file:
                matlabbatch{job_ind}.spm.stats(stat_ind).con.spmmat=cellstr(spm_mat_file);
                
                %------------------------------------------------------------------
                % INCLUDE CONTRASTS
                %------------------------------------------------------------------
                
                fprintf('\n INSIDE FMRI_CON!!!!!! job_ind = \n');
                disp(job_ind);
                
                
                
                %first_run_name=info.run_names{sub_ind}(1);      

                % Which experiment?
                %experiment = get_experiment_name_from_run_name(first_run_name);

                % If more contrasts:    
                % Get the constrast names
                % contrast_names = info.contrast_names(experiment);

                % Get the contrast matrix
                contrast_matrix = info.contrast_matrix;
                fprintf('This is the contrast matrix: ')
                disp(contrast_matrix)
                
                fprintf('This is the length of the contrast vector: ')
                disp(length(contrast_matrix))

                % Get the condition names (to know the dimention of one run):
                %condition_names = info.condition_names(experiment);
                condition_names = info.condition_names;
                contrast_names = info.contrast_names;
                

                % The dimension length of the contrast vector for this
                % subject (one set of conditions and realignment parameter 
                % per run):

                
                % We don't need to normalize the contrast vector, see my Evernote notes: "Analysis"        
                %for i=1:1
                % If more contrasts:    
                %for i=1:length(contrast_names)

                    % Name of the contrast(s)  
                    %matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{i}.tcon.name = 'Indirect_vs_Direct';
                    % If more contrasts:    
                    % = contrast_names{i};
                       
                    % Normalize vector:
                    
                    % count 1s:
                    %n_1s = 0;
                    %for j=1:length(contrast_vector)
                    %    disp(contrast_vector(j));
                    %    if contrast_vector(j) == 1
                    %        n_1s = n_1s + 1;
                    %    end
                    %end    
                    %norm = n_1s;
                    %contrast_vector_normalized = contrast_vector/norm;
                            
                    
                    %fprintf('\n Here is the normalized contrast vector: \n');
                    %disp(contrast_vector_normalized);
                
                    %matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{i}.tcon.convec = contrast_vector_normalized;
                    % If more contrasts:            
                    % = contrast_matrices(i, contrast_vector_length)';

                %end % for contrast_names
               %matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{1,1}.tcon.name = 'Indirect_vs_Direct';    
               %matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{1,1}.tcon.convec = contrast_vector;
               
               for c= 1:length(contrast_matrix)
               
                    matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{1,c}.tcon.name = char(contrast_names{c});    
                    matlabbatch{job_ind}.spm.stats(stat_ind).con.consess{1,c}.tcon.convec = contrast_matrix{c};
                    
               end % end for several contrasts
   
               
            else 
                fprintf('No spec, est, or con job was specified\n');
            end % if est, spec or con
            
        end % for stats jobs
        
    else
        error('Unrecognized spatial/temporal/stats/util job');
    end % if else stats job
    
end % for jobs
%--------------------------------------------------------------------------
% OUTPUT - EXPANDED JOB-STRUCTURE
%--------------------------------------------------------------------------
xpanded_jobs = matlabbatch;
end % xpandjobs
