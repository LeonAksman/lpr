% Pattern Recognition for Neuroimaging Toolbox, aka. PRoNTo
% Verion 1.1 (PRoNTo) 14-May-2012
%__________________________________________________________________________
%     ____  ____        _   ________     
%    / __ \/ __ \____  / | / /_  __/_         ___ ___ 
%   / /_/ / /_/ / __ \/  |/ / / / __ \   _  _<  /<  /
%  / ____/ _, _/ /_/ / /|  / / / /_/ /  | |/ / / / /
% /_/   /_/ |_|\____/_/ |_/ /_/\____/   |___/_(_)_/ 
%
%                         PRoNTO v1.1 - http://www.mlnl.cs.ucl.ac.uk/pronto
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory
%
% $Id: Contents.m 741 2013-07-22 14:07:36Z mjrosa $
%
%__________________________________________________________________________
%
% PRoNTo v1.1 (2012) is the deliverable of a Pascal Harvest project 
% coordinated by Dr. Mourao-Miranda.
% PRoNTo is  developed by the Machine Learning & Neuroimaging Laboratory,
% Computer Science department, University College London, UK.
% http://www.mlnl.cs.ucl.ac.uk and associated researchers.
% 
% Main contributors, in alphabetical order: J. Ashburner, C. Chu, 
% A. Marquand, J. Mourao-Miranda, C. Phillips, J. Richiardi, J. Rondina, 
% M.J. Rosa, J. Schrouff,
% 
% The development of PRoNTo was possible with the financial and logistic 
% support of 
% - PASCAL Harvest Programme (http://www.pascal-network.org/)
% - the Department of Computer Science, University College London
%   (http://www.cs.ucl.ac.uk);
% - the Wellcome Trust;
% - PASCAL2 (http://www.pascal-network.org/) and its HARVEST programme;
% - the Fonds de la Recherche Scientifique-FNRS, Belgium
%   (http://www.fnrs.be);
% - The Foundation for Science and Technology, Portugal 
%   (http://www.fct.pt);
% - Swiss National Science Foundation (PP00P2-123438) and Center for
%   Biomedical Imaging (CIBM) of the EPFL and Universities and Hospitals
%   of Lausanne and Geneva. 
%
% PRoNTo is designed to work from MATLAB versions 7.5 (R2007b) to 
% 7.14 (R2012a), and will not work with earlier versions.
% Some routine may need to be compiled for your specific OS.
%
%__________________________________________________________________________
%
% PRoNTo is free software: you can redistribute it  and/or modify it under  
% the terms of the GNU General Public License as published by the Free 
% Software Foundation,  either version 2 of  the License,  or (at  your  
% option) any later version.
% PRoNTo is  distributed in the hope  that it will be  useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A  PARTICULAR PURPOSE.  See the  GNU General Public License   
% for more details.
% You should  have received a copy of the  GNU General Public License along
% with PRoNTo, in prt_LICENCE.man. If not, see 
% <http://www.gnu.org/licenses/>.
%
%__________________________________________________________________________
%
% List of .m files:
% -----------------
% Contents.m                    
% prt.m                         
% prt_apply_operation.m         
% prt_check_design.m            
% prt_compute_weights.m         
% prt_cv_model.m                
% prt_cv_opt_param.m            
% prt_data_conditions.m         
% prt_data_modality.m           
% prt_data_review.m             
% prt_defaults.m                
% prt_fs.m                      
% prt_func2html.m               
% prt_get_defaults.m            
% prt_get_filename.m            
% prt_init_fs.m                 
% prt_init_model.m              
% prt_latex.m                   
% prt_load.m                    
% prt_load_blocks.m             
% prt_model.m                   
% prt_normalise_kernel.m        
% prt_permutation.m             
% prt_remove_confounds.m        
% prt_stats.m                   
% prt_struct2latex.m            
% prt_text_input.m              
% prt_ui_compute_weights.m      
% prt_ui_cv_model.m             
% prt_ui_design.m               
% prt_ui_kernel_construction.m  
% prt_ui_main.m                 
% prt_ui_model.m                
% prt_ui_prepare_data.m         
% prt_ui_prepare_datamod.m      
% prt_ui_results.m              
% prt_ui_reviewCV.m             
% prt_ui_reviewmodel.m          
% prt_ui_select_class.m         
% prt_ui_select_reg.m  
% _devUtils\
%     verLessThanV6.m
% _unitTests
%     prt_compute_weights.m     
%     prt_create_weight_maps.m  
%     test_prt_machine.m   
% batch\
%     prt_batch.m         
%     prt_cfg_batch.m     
%     prt_cfg_cv_model.m  
%     prt_cfg_design.m    
%     prt_cfg_fs.m        
%     prt_cfg_model.m     
%     prt_cfg_weights.m   
%     prt_run_cv_model.m  
%     prt_run_design.m    
%     prt_run_fs.m        
%     prt_run_model.m     
%     prt_run_weights.m  
% machines\
%     prt_KRR.m                    
%     prt_machine.m                
%     prt_machine_RT_bin.m         
%     prt_machine_gpml.m           
%     prt_machine_krr.m            
%     prt_machine_rvr.m            
%     prt_machine_svm_bin.m        
%     prt_rvr.m                    
%     prt_weights.m                
%     prt_weights_bin_linkernel.m  
%     prt_weights_svm_bin.m     
% manual\
% masks\
% utils\
%     prt_centre_kernel.m       
%     prt_checkAlphaNumUnder.m  
%     prt_normalise_kernel.m    

