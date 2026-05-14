%==========================================================================
% infoFFX.m 
%--------------------------------------------------------------------------
% Authors: Julia Uddén, Katarina Bendtz
% Date:      08/2017
%==========================================================================
fprintf('------------------\n')
fprintf('Reading infoFFX \n')
fprintf('------------------\n')

%spm_figure('GetWin','Graphics');

% Subject directories is in info.subject_IDs in infoSubjects.m:
infoSubjects;

cwd=pwd;

    
%--------------------------------------------------------------------------
% the  batch template .mat-file which include a structure named jobs 
% outlining the parameters for the subjobs;

% NOTE
info.todo               = {'spec','est','con'};
%info.todo               = {'spec', 'est'};
%info.todo               = {'est', 'con'};
%info.todo               = {'est'};
%info.todo               = {'con'};
%info.todo               = {'spec'};

%--------------------------------------------------------------------------
% Directories:

% Naming: 
% dirs: name of dir: "dir_name", full path and name: "dir", partial path: dir_rel_path
% files: name of file: "file_name", full path without file: "file_path", 
% partial path: file_rel_path
% full path and name: "file", regular expression for files: files_pattern

% the 'root' (top level) directory for the analysis;
% BIAS preproc pipeline
% info.root_dir                  = '/home/cararv/RobotfMRI/MR_data';
%info.script_dir                = fullfile('media','oskar','Lenovo PS6','fmri','ffx_scripts','ffx_scripts','first_level');
%info.script_dir                = fullfile('media','oskar','Lenovo
%PS6','SUBIC);
%info.script_dir                 = 'media/oskar/Expansion/fmri/ffx_scripts/ffx_scripts/first_level';
%info.script_dir                = fullfile('media','oskar','Expansion','fmri','ffx_scripts','ffx_scripts','first_level');
info.script_dir                 = fullfile('D:', 'fmri', 'ffx_scripts', 'ffx_scripts', 'first_level');
%info.root_dir                   = '/media/oskar/Expansion/SUBIC';
%info.root_dir                    = fullfile('media','oskar','Expansion','SUBIC');
info.root_dir                   = fullfile('D:', 'SUBIC');
%info.ffx_data_dir_rel_path     = 'func/ffxdata';
info.ffx_data_dir_rel_path      = fullfile('func','ffxdata');


%&&&&&&&&&&&&&&&&&&& No time derivative %%%%%%%%%%%%%%%%%%%%

%info.ffx_results_dir_rel_path  = 'func/ffxstats/RobotfMRI_pmod';
%info.ffx_results_dir_rel_path  = 'func/ffxstats/results';
info.ffx_results_dir_rel_path  = fullfile ('func','ffxstats','v7-fixTR');

% Q: Why is there a minus sign in fron?
%info.ffxresultsdir      = '-ffxStats';
%--------------------------------------------------------------------------
% generic name for the directory including information on regressors/
% conditions (names/onsets/durations) (cell arrays);
% NOTE: the files without any adjustment to latency:

%info.onset_and_dur_dir_name     = 'onset_and_duration_pmod_nTI/mat';
%info.onset_and_dur_dir_name      = 'onset_and_duration_files_ovrl/mat';
%info.onset_and_dur_dir_name       = '../MOUS/JohannaNamesOnsDur';
info.onset_and_dur_dir_name       = 'ons_durs_ex_eng_v7';
 
%--------------------------------------------------------------------------

% mat files for the different jobs

% NOTE: if you want to include time derivatves, make sure to
% change the contrast below as well.
%info.job_spec_mat_file_name            = 'FFXspec_incl_time_derivatives.mat';
% This is not including time derivatives
info.job_spec_mat_file_name            = 'FFXspec.mat';
info.job_est_mat_file_name             = 'FFXest.mat';
info.job_con_mat_file_name             = 'FFXcon.mat';


%--------------------------------------------------------------------------
% identifiers for the functional and structural images;

info.fct_data_file_pattern              = '^vswr.*\.nii';%'^swarfct.*\.nii'; pattern for the final func file
info.str                                = '^sub-.*_space-MNI152NLin2009cAsym_res-2_desc-preproc_T1w.nii';  %%%pattern for the final struct file (or maybe the raw file, mke sure what str stand for)
info.rp_file_pattern                    = '^rp.*\.txt';

%--------------------------------------------------------------------------
% if not the xpand5job internal prefix handling is desired 
% use for example the option below;
info.prefix                     = '';
info.prefixstatus               = true;
info.xpanded_job_name_suffix    = '_xpandedFFX';
info.rp                         = 'true';
%info.rp                         = 'false';
info.spm_mat_file_name          = 'SPM.mat';
info.specCopy                   = 'SPM_specCopy.mat';
info.estCopy                    = 'SPM_estCopy.mat';
info.conCopy                    = 'SPM_conCopy.mat';
info.specestCopy                = 'SPM_specestCopy.mat';
info.estconCopy                 = 'SPM_specestCopy.mat';
info.specestconCopy             = 'SPM_specestconCopy.mat';

%--------------------------------------------------------------------------
% Parametrization analysis
info.additive_pmod = 0;
%--------------------------------------------------------------------------
%
% Contrast Generation
%
%--------------------------------------------------------------------------
% Description of the design matrix:
%
% First comes the stimulus conditions and then there are the six motion parameters 
% and the constant that SPM adds.

%%%%%%%%%%%%%%% 
% PMOD SURPRISAL SUBIC%
%%%%%%%%%%%%%%%
%
% Description of the design matrix:
%
% First comes (1) COMP and its (2) FREQ and (3) SUPRISAL, then (4) PROD 
% and its (5) FREQ and (6) SUPRISAL. Then comes (7) SILENCE, (8)
% FIXATION, and (9) TI
%comp_vs_ib =  [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%prod_vs_ib =  [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0];
%comp_vs_eb =  [1 0 0 0 0 0 0 -1 0 0 0 0 0 0 0];
%prod_vs_eb =  [0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0];
%comp_supr =  [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0];
%prod_supr =  [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0];
%ti_vs_eb =    [0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0];
%compvsprod =  [1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0];
%prodvscomp =  [-1 0 0 1 0 0 0 0 0 0 0 0 0 0 0];
%info.contrast_matrix= {comp_vs_eb, prod_vs_eb, comp_supr, prod_supr, ti_vs_eb, compvsprod, prodvscomp};
%info.contrast_names = {'comp_eb', 'prod_eb', 'compsupr', 'prodsupr', 'ti_vs_eb', 'compvsprod', 'prodvscomp'};
%info.condition_names = {'comp', 'prod', 'silence', 'fix', 'ti'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% HUMAN VS ROBOT CONTRASTS %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prod_vs_ib [1 0 0 0 0 + motion params] - ib can be removed
%comp_vs_ib
%prod_vs_fix
%comp_vs_fix
%prod_vs_comp
%comp_vs_prod
%ti_vs_

% prod_vs_fix = [1 0 0 0 -1 0 0 0 0 0 0 0 0      1 0 0 0 -1 0 0 0 0 0 0 0 0 0    1 0 0 0 -1 0 0 0 0 0 0 0 0 0];
% comp_vs_fix = [0 1 0 0 -1 0 0 0 0 0 0 0 0 0      0 1 0 0 -1 0 0 0 0 0 0 0 0 0    0 1 0 0 -1 0 0 0 0 0 0 0 0 0];
% ti_vs_fix = [0 0 1 0 -1 0 0 0 0 0 0 0 0 0      0 0 1 0 -1 0 0 0 0 0 0 0 0 0    0 0 1 0 -1 0 0 0 0 0 0 0 0 0];
% prod_vs_comp = [1 -1 0 0 0 0 0 0 0 0 0 0 0 0      1 -1 0 0 0 0 0 0 0 0 0 0 0 0    1 -1 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_vs_prod = [-1 1 0 0 0 0 0 0 0 0 0 0 0 0      -1 1 0 0 0 0 0 0 0 0 0 0 0 0    -1 1 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_vs_prod = [-1 0 1 0 0 0 0 0 0 0 0 0 0 0      -1 0 1 0 0 0 0 0 0 0 0 0 0 0    -1 0 1 0 0 0 0 0 0 0 0 0 0 0];
% prod_vs_ti = [1 0 -1 0 0 0 0 0 0 0 0 0 0 0      1 0 -1 0 0 0 0 0 0 0 0 0 0 0    1 0 -1 0 0 0 0 0 0 0 0 0 0 0];
% ti_vs_comp = [0 -1 1 0 0 0 0 0 0 0 0 0 0 0      0 -1 1 0 0 0 0 0 0 0 0 0 0 0    0 -1 1 0 0 0 0 0 0 0 0 0 0 0];
% comp_vs_ti = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0      0 1 -1 0 0 0 0 0 0 0 0 0 0 0    0 1 -1 0 0 0 0 0 0 0 0 0 0 0];
% 
% low_vs_medium = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0      0 0 0 0 0 1 -1 0 0 0 0 0 0 0    0 0 0 0 0 1 -1 0 0 0 0 0 0 0];
% low_vs_high = [0 0 0 0 0 0 1 0 -1 0 0 0 0 0      0 0 0 0 0 1 0 -1 0 0 0 0 0 0    0 0 0 0 0 1 0 -1 0 0 0 0 0 0];
% medium_vs_high = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0      0 0 0 0 0 0 1 -1 0 0 0 0 0 0    0 0 0 0 0 0 1 -1 0 0 0 0 0 0];
% low_vs_fix = [0 0 0 0 -1 1 0 0 0 0 0 0 0 0      0 0 0 0 -1 1 0 0 0 0 0 0 0 0    0 0 0 0 -1 1 0 0 0 0 0 0 0 0];
% medium_vs_fix = [0 0 0 -1 0 -1 0 0 0 0 0 0 0 0      0 0 0 0 -1 0 1 0 0 0 0 0 0 0    0 0 0 0 -1 0 1 0 0 0 0 0 0 0];
% high_vs_fix = [0 0 0 0 -1 0 0 1 0 0 0 0 0 0      0 0 0 0 -1 0 0 1 0 0 0 0 0 0    0 0 0 0 -1 0 0 1 0 0 0 0 0 0];
% 
% prod_hm_vs_prod_low = [1 0 0 0 0 0 0 0 0 0 0 0 0 0     1 0 0 0 0 0 0 0 0 0 0 0 0 0   -1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_hm_vs_comp_low = [0 1 0 0 0 0 0 0 0 0 0 0 0 0     0 1 0 0 0 0 0 0 0 0 0 0 0 0   0 -1 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_hm_vs_ti_low = [0 0 1 0 0 0 0 0 0 0 0 0 0 0     0 0 1 0 0 0 0 0 0 0 0 0 0 0 0   0 0 -1 0 0 0 0 0 0 0 0 0 0 0];
% prod_low_vs_prod_hm = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0     -1 0 0 0 0 0 0 0 0 0 0 0 0 0   1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_low_vs_comp_hm = [0 -1 0 0 0 0 0 0 0 0 0 0 0 0     0 -1 0 0 0 0 0 0 0 0 0 0 0 0   0 1 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_low_vs_ti_hm = [0 0 -1 0 0 0 0 0 0 0 0 0 0 0     0 0 -1 0 0 0 0 0 0 0 0 0 0 0   0 0 1 0 0 0 0 0 0 0 0 0 0 0];
% 
% prod_h_vs_m = [1 0 0 0 0 0 0 0 0 0 0 0 0 0      -1 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_m_vs_h = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0      1 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_h_vs_low = [1 0 0 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    -1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_low_vs_h = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_m_vs_low = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      1 0 0 0 0 0 0 0 0 0 0 0 0 0    -1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_low_vs_m = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      -1 0 0 0 0 0 0 0 0 0 0 0 0 0    1 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_h_vs_m = [0 1 0 0 0 0 0 0 0 0 0 0 0 0      0 -1 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_m_vs_h = [0 -1 0 0 0 0 0 0 0 0 0 0 0 0      0 1 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_h_vs_low = [0 1 0 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 -1 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_low_vs_h = [0 -1 0 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 1 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_m_vs_low = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      0 1 0 0 0 0 0 0 0 0 0 0 0 0    0 -1 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_low_vs_m = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      0 -1 0 0 0 0 0 0 0 0 0 0 0 0    0 1 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_h_vs_m = [0 0 1 0 0 0 0 0 0 0 0 0 0 0      0 0 -1 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_m_vs_h = [0 0 -1 0 0 0 0 0 0 0 0 0 0 0      0 0 1 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% ti_h_vs_low = [0 0 1 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 -1 0 0 0 0 0 0 0 0 0 0 0];
% ti_low_vs_h = [0 0 -1 0 0 0 0 0 0 0 0 0 0 0      0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 1 0 0 0 0 0 0 0 0 0 0 0];
% ti_m_vs_low = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      0 0 1 0 0 0 0 0 0 0 0 0 0 0    0 0 -1 0 0 0 0 0 0 0 0 0 0 0];
% ti_low_vs_m = [0 0 0 0 0 0 0 0 0 0 0 0 0 0      0 0 -1 0 0 0 0 0 0 0 0 0 0 0    0 0 1 0 0 0 0 0 0 0 0 0 0 0];
% 
% prod_hm_vs_comp_hm = [1 -1 0 0 0 0 0 0 0 0 0 0 0 0     1 -1 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_low_vs_comp_low = [0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0   1 -1 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_h_vs_comp_h = [1 -1 0 0 0 0 0 0 0 0 0 0 0 0     0 0 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% prod_m_vs_comp_m = [0 0 0 0 0 0 0 0 0 0 0 0 0 0     1 -1 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_hm_vs_prod_hm = [-1 1 0 0 0 0 0 0 0 0 0 0 0 0     -1 1 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_low_vs_prod_low = [0 0 0 0 0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0 0 0 0 0   -1 1 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_h_vs_prod_h = [-1 1 0 0 0 0 0 0 0 0 0 0 0 0     0 0 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% comp_m_vs_prod_m = [0 0 0 0 0 0 0 0 0 0 0 0 0 0     -1 1 0 0 0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% 
% 
% info.contrast_matrix= {prod_vs_fix, comp_vs_fix,ti_vs_fix,prod_vs_comp,comp_vs_prod,ti_vs_prod,prod_vs_ti,ti_vs_comp,comp_vs_ti,...
%                         low_vs_medium, low_vs_high, medium_vs_high, low_vs_fix, medium_vs_fix, high_vs_fix,...
%                         prod_hm_vs_prod_low,comp_hm_vs_comp_low,ti_hm_vs_ti_low,prod_low_vs_prod_hm,comp_low_vs_comp_hm,ti_low_vs_ti_hm,...
%                         prod_h_vs_m,prod_m_vs_h,prod_h_vs_low,prod_low_vs_h,prod_m_vs_low,prod_low_vs_m,...
%                         comp_h_vs_m,comp_m_vs_h,comp_h_vs_low,comp_low_vs_h,comp_m_vs_low,comp_low_vs_m,...
%                         ti_h_vs_m,ti_m_vs_h,ti_h_vs_low,ti_low_vs_h,ti_m_vs_low,ti_low_vs_m,...
%                         prod_hm_vs_comp_hm,prod_low_vs_comp_low,prod_h_vs_comp_h,prod_m_vs_comp_m,...
%                         comp_hm_vs_prod_hm,comp_low_vs_prod_low,comp_h_vs_prod_h,comp_m_vs_prod_m;};
% info.contrast_names = { "prod_vs_fix","comp_vs_fix", "ti_vs_fix", "prod_vs_comp", "comp_vs_prod", "ti_vs_prod", "prod_vs_ti", "ti_vs_comp", "comp_vs_ti",...
%                         "low_vs_medium", "low_vs_high", "medium_vs_high", "low_vs_fix", "medium_vs_fix", "high_vs_fix",...
%                         "prod_hm_vs_prod_low", "comp_hm_vs_comp_low", "ti_hm_vs_ti_low", "prod_low_vs_prod_hm", "comp_low_vs_comp_hm", "ti_low_vs_ti_hm", ...
%                         "prod_h_vs_m", "prod_m_vs_h", "prod_h_vs_low", "prod_low_vs_h", "prod_m_vs_low", "prod_low_vs_m", ...
%                         "comp_h_vs_m", "comp_m_vs_h", "comp_h_vs_low", "comp_low_vs_h", "comp_m_vs_low", "comp_low_vs_m", ...
%                         "ti_h_vs_m", "ti_m_vs_h", "ti_h_vs_low", "ti_low_vs_h", "ti_m_vs_low", "ti_low_vs_m", ...
%                         "prod_hm_vs_comp_hm", "prod_low_vs_comp_low", "prod_h_vs_comp_h", "prod_m_vs_comp_m", ...
%                         "comp_hm_vs_prod_hm", "comp_low_vs_prod_low", "comp_h_vs_prod_h", "comp_m_vs_prod_m"};
% info.condition_names = {"production", "comprehension", "turn_initiation", "silence", "fixation_cross", "lown_eng", "medium_eng", "high_eng"};

% low_vs_medium =     [ 0 0 0 0 1 -1 0 0 0 0 0 0 0    0 0 0 0 1 -1 0 0 0 0 0 0 0  0 0 0 0 1 -1 0 0 0 0 0 0 0];
% low_vs_high =       [ 0 0 0 0 0 1 0 -1 0 0 0 0 0    0 0 0 0 1 0 -1 0 0 0 0 0 0  0 0 0 0 1 0 -1 0 0 0 0 0 0];
% medium_vs_high =    [ 0 0 0 0 1 -1 0 0 0 0 0 0 0    0 0 0 0 0 1 -1 0 0 0 0 0 0  0 0 0 0 0 1 -1 0 0 0 0 0 0];
% low_vs_fix =        [ 0 0 0 -1 1 0 0 0 0 0 0 0 0    0 0 0 -1 1 0 0 0 0 0 0 0 0  0 0 0 -1 1 0 0 0 0 0 0 0 0];
% medium_vs_fix =     [ 0 0 0 -1 0 1 0 0 0 0 0 0 0    0 0 0 -1 0 1 0 0 0 0 0 0 0  0 0 0 -1 0 1 0 0 0 0 0 0 0];
% high_vs_fix =       [ 0 0 0 -1 0 0 1 0 0 0 0 0 0    0 0 0 -1 0 0 1 0 0 0 0 0 0  0 0 0 -1 0 0 1 0 0 0 0 0 0];
% 
% info.contrast_matrix= {low_vs_medium, low_vs_high, medium_vs_high, low_vs_fix, medium_vs_fix, high_vs_fix};
% info.contrast_names = {"low_vs_medium", "low_vs_high", "medium_vs_high", "low_vs_fix", "medium_vs_fix", "high_vs_fix"};
% info.condition_names = {"comprehension", "turn_initiation", "silence", "fixation_cross", "lown_eng", "medium_eng", "high_eng"};

%v7 high-med
prod_anat_medium_vs_prod_anat_high =    [ 1 -1 0 0 0 0 0 0 0 0 0 0  1 -1 0 0 0 0 0 0 0 0 0 0];%   1 -1 0 0 0 0 0 0 0 0 0 0];
prod_anat_medium_vs_fix =               [ 1 0 0 0 0 -1 0 0 0 0 0 0  1 0 0 0 0 -1 0 0 0 0 0 0];%   1 0 0 0 0 0 -1 0 0 0 0 0];
prod_anat_high_vs_fix =                 [ 0 1 0 0 0 -1 0 0 0 0 0 0  0 1 0 0 0 -1 0 0 0 0 0 0];%   0 1 0 0 0 0 -1 0 0 0 0 0];

info.contrast_matrix= { prod_anat_medium_vs_prod_anat_high, prod_anat_medium_vs_fix, prod_anat_high_vs_fix};
info.contrast_names = {"prod_anat_medium_vs_prod_anat_high", "prod_anat_medium_vs_fix", " prod_anat_high_vs_fix"};
info.condition_names = { "prod_anat_medium", "prod_anat_high", "comprehension", "turn_initiation", "silence", "fixation_cross",};
%------------------
%v8 high - low
% prod_anat_low_vs_prod_anat_high =        [ 1 -1 0 0 0 0 0 0 0 0 0 0];%     1 -1 0 0 0 0 0 0 0 0 0 0];%    1 -1 0 0 0 0 0 0 0 0 0 0];
% prod_anat_low_vs_fix =                   [ 1 0 0 0 0 -1 0 0 0 0 0 0];%     1 0 0 0 0 -1 0 0 0 0 0 0];%    1 0 0 0 0 0 -1 0 0 0 0 0];
% prod_anat_high_vs_fix =                  [ 0 1 0 0 0 -1 0 0 0 0 0 0];%     0 1 0 0 0 -1 0 0 0 0 0 0];%    0 1 0 0 0 0 -1 0 0 0 0 0];
% 
% info.contrast_matrix= { prod_anat_low_vs_prod_anat_high, prod_anat_low_vs_fix, prod_anat_high_vs_fix};
% info.contrast_names = {"prod_anat_low_vs_prod_anat_high", "prod_anat_low_vs_fix", " prod_anat_high_vs_fix"};
% info.condition_names = { "prod_anat_low", "prod_anat_high", "comprehension", "turn_initiation", "silence", "fixation_cross",};
%----------------
%v9 low - med
% prod_anat_low_vs_prod_anat_medium =     [ 1 -1 0 0 0 0 0 0 0 0 0 0  1 -1 0 0 0 0 0 0 0 0 0 0];%   1 -1 0 0 0 0 0 0 0 0 0 0];
% prod_anat_low_vs_fix =                  [ 1 0 0 0 0 -1 0 0 0 0 0 0  1 0 0 0 0 -1 0 0 0 0 0 0];%   1 0 0 0 0 0 -1 0 0 0 0 0];
% prod_anat_medium_vs_fix =               [ 0 1 0 0 0 -1 0 0 0 0 0 0  0 1 0 0 0 -1 0 0 0 0 0 0];%   0 1 0 0 0 0 -1 0 0 0 0 0];
% 
% info.contrast_matrix= { prod_anat_low_vs_prod_anat_medium, prod_anat_low_vs_fix, prod_anat_medium_vs_fix};
% info.contrast_names = {"prod_anat_low_vs_prod_anat_medium", "prod_anat_low_vs_fix", " prod_anat_medium_vs_fix"};
% info.condition_names = { "prod_anat_low", "prod_anat_medium", "comprehension", "turn_initiation", "silence", "fixation_cross",};

% Run structure:
info.run_names = {};

for sub_ind = 1:length(info.subject_IDs)
    
    subject_ID = info.subject_IDs{sub_ind};
    subject_rundir = fullfile (info.root_dir, subject_ID, info.ffx_data_dir_rel_path);
    % If it doesn't exist, create it:
    if ~exist(subject_rundir, 'dir')
        mkdir(subject_rundir)

    end
    
    fprintf('\n');
    disp(subject_rundir);		 
    fprintf('\n');
    
    % There are one dir for each run, named after the para file associated with the run
    % Count number of dirs to get the
    % the number of runs

    cd(subject_rundir);
    % dir is a built-in  matlab function
    subdir = dir;
    % The first two listed are "." and "..", but will also be considered
    % here for simplicity.
    %nr_dirs = sum([subdir.isdir]);
    nr_dirs = length(subdir);

    % Save names of runs
    run_names_tmp = {};

    % We don't know how many runs there are until we have gone through
    % all dirs:
    run_ind = 1;
    nr_runs = 0;
    
    % run_name is actually the name of the para file associated to the specific run

    for dir_ind = 1:nr_dirs 

        dir_name = subdir(dir_ind).name;
        
        % MATLAB temp dir        
        abort_1 = ~isempty(strfind(dir_name,'MATLAB'));
        abort_2 = ~isempty(strfind(dir_name,'NamesOnDur'));
        abort_3 = logical(dir_name(1) == '.');
        
        
        fprintf('\n This folder is considered: \n')
        disp(dir_name);
        
        % Check so that not a MATLAB temp dir
        if ~(abort_1 == 1 || abort_2 == 1 || abort_3 == 1)
            % TODO: remove run 3 for PCP 1 if PCP 1 is not going to
            % be removed as a whole. Then you also have to adjust
            % the contrast matrix for this PCP.
            
            
            fprintf('\n This folder is saved: \n')
            disp(dir_name);
            
            % subdir is a struct with meta info about the dir.
            % name is one of its members.
            % The first two entries in dir are not directories
         
            run_names_tmp(run_ind) = cellstr(subdir(dir_ind).name);
            nr_dirs = run_ind;
            run_ind = run_ind + 1;
            
        end % if
	 

    end % for dirs
    
    fprintf('\n These runs are added for analysis: \n')
    disp(run_names_tmp);
    info.run_names{sub_ind} = run_names_tmp;

end % for sub_ind

% Move back to script dir:
cd(info.script_dir);
