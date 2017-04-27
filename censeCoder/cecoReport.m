function config = cecoReport(config)                        
% cecoReport REPORTING of the expLanes experiment censeCoder
%    config = cecoInitReport(config)                        
%       config : expLanes configuration state               
                                                            
% Copyright: felix                                          
% Date: 20-Apr-2017                                         
                                                            
if nargin==0, censeCoder('report', 'rhv'); return; end      
                                                            
config = expExpose(config, 't');                            
