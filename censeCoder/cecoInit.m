function [config, store] = cecoInit(config)                        
% cecoInit INITIALIZATION of the expLanes experiment censeCoder    
%    [config, store] = cecoInit(config)                            
%      - config : expLanes configuration state                     
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: felix                                                 
% Date: 20-Apr-2017                                                
                                                                   
if nargin==0, censeCoder(); return; else store=[];  end            
