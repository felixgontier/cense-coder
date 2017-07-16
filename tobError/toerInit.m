function [config, store] = toerInit(config)                        
% toerInit INITIALIZATION of the expLanes experiment tobError      
%    [config, store] = toerInit(config)                            
%      - config : expLanes configuration state                     
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: felix                                                 
% Date: 12-Jul-2017                                                
                                                                   
if nargin==0, tobError(); return; else store=[];  end              
