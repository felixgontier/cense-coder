% clear all, close all, clc;
% 
% load dict;
% f_dict = fopen('dict.txt', 'w');
% 
% for ind_sym = 1:size(dict, 1)-1
%     fwrite(f_dict, [num2str(dict{ind_sym, 1}) ',']);
%     for ind_code = 1:length(dict{ind_sym, 2})-1
%         fwrite(f_dict, [num2str(dict{ind_sym, 2}(ind_code)) ',']);
%     end
%     fwrite(f_dict, [num2str(dict{ind_sym, 2}(end)) 10]);
% end
% fwrite(f_dict, [num2str(dict{end, 1}) ',']);
% for ind_code = 1:length(dict{end, 2})-1
%     fwrite(f_dict, [num2str(dict{end, 2}(ind_code)) ',']);
% end
% fwrite(f_dict, [num2str(dict{end, 2}(end)) 10]);
% 
% fclose(f_dict);

clear all, close all, clc;

load tob_a_4096;
for ind_band = 1:length(f_band)
    f_band2{ind_band}(1) = f_band{ind_band}(1);
    if ~isempty(find(H_band{ind_band}==1, 1))
        f_band2{ind_band}(2) = f_band2{ind_band}(1)+find(H_band{ind_band}==1, 1)-2;
        f_band2{ind_band}(3) = f_band2{ind_band}(1)+length(H_band{ind_band})-find(flip(H_band{ind_band})==1, 1)+1;
    else
        f_band2{ind_band}(2) = 0;
        f_band2{ind_band}(3) = 0;
    end
    f_band2{ind_band}(4) = f_band{ind_band}(2);
end
f_band = f_band2;

f_weights = fopen('tob_4096.txt', 'w');

for ind_band = 1:length(f_band)-1
    fwrite(f_weights, [num2str(f_band{ind_band}(1)) ',' num2str(f_band{ind_band}(2)) ',' num2str(f_band{ind_band}(3)) ',' num2str(f_band{ind_band}(4)) ',']);
    for ind_bin = 1:length(H_band{ind_band})-1
        fwrite(f_weights, [num2str(H_band{ind_band}(ind_bin)) ',']);
    end
    fwrite(f_weights, [num2str(H_band{ind_band}(end)) 10]);
end
fwrite(f_weights, [num2str(f_band{end}(1)) ',' num2str(f_band{end}(2)) ',' num2str(f_band{ind_band}(3)) ',' num2str(f_band{ind_band}(4)) ',']);
for ind_bin = 1:length(H_band{end})-1
    fwrite(f_weights, [num2str(H_band{end}(ind_bin)) ',']);
end
fwrite(f_weights, [num2str(H_band{end}(end)) 10]);

fclose(f_weights);


% f_weights = fopen('tob_4096.txt', 'w');
% 
% for ind_band = 1:length(f_band)-1
%     fwrite(f_weights, [num2str(f_band{ind_band}(1)) ',' num2str(f_band{ind_band}(2)) ',']);
%     for ind_bin = 1:length(H_band{ind_band})-1
%         fwrite(f_weights, [num2str(H_band{ind_band}(ind_bin)) ',']);
%     end
%     fwrite(f_weights, [num2str(H_band{ind_band}(end)) 10]);
% end
% fwrite(f_weights, [num2str(f_band{end}(1)) ',' num2str(f_band{end}(2)) ',']);
% for ind_bin = 1:length(H_band{end})-1
%     fwrite(f_weights, [num2str(H_band{end}(ind_bin)) ',']);
% end
% fwrite(f_weights, [num2str(H_band{end}(end)) 10]);
% 
% fclose(f_weights);









