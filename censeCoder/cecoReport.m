function config = cecoReport(config)                        
% cecoReport REPORTING of the expLanes experiment censeCoder
%    config = cecoInitReport(config)                        
%       config : expLanes configuration state               
                                                            
% Copyright: felix                                          
% Date: 20-Apr-2017                                         
                                                            
if nargin==0, censeCoder('report', 'r'); return; end%censeCoder('report', 'rhv'); return; end      
                                                            
config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4}, 'obs', 'cv_acc', 'step', 3, 'color', 'k'); % KNN accuracy as f(mel,fps)
config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4}, 'obs', 'csii', 'step', 3, 'expand', 2, 'color', 'k'); % CSII indicator as f(mel,fps)
config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4}, 'obs', 'bitrate', 'step', 2, 'expand', 2, 'color', 'k'); % bitrate as f(mel,fps)



