function [symbol, prob, prob_time] = huff_dict(x, mode, nbits)

assert(isvector(x), 'x must be a vector.');
if nargin < 2;
    mode = 'seq';
end

if strcmp(mode, 'seq')
    %% Sequential search
    tic;
    symbol = [];
    count = [];
    for inds = 1:length(x)
        found = 0;
        for indd = 1:length(symbol)
            if symbol(indd) == x(inds)
                count(indd) = count(indd) + 1;
                found = 1;
                break;
            end
        end
        if found == 0
            symbol(end+1) = x(inds);
            count(end+1) = 1;
        end
    end
    prob = count/length(x);
    prob_time = toc;
    disp(['Sequential algorithm complete. Time elapsed is ' num2str(prob_time) ' seconds.']);
elseif strcmp(mode, 'sort')
    %% Sorting
%     tic;
    x_sort = sort(x);
    symbol = x_sort(1);
    count = 0;
    cur_ind = 1;

    while true
        next_ind = cur_ind-1+find(x_sort(cur_ind:end)~=symbol(end), 1);
        if ~isempty(next_ind)
            count(end) = count(end)+next_ind-cur_ind;
        else
            count(end) = count(end)+length(x_sort)-cur_ind+1;
            break;
        end
        symbol(end+1) = x_sort(next_ind);
        count(end+1) = 0;
        cur_ind = next_ind;
    end
    prob = count/length(x);
%     prob_time = toc;
%     disp(['Sorting algorithm complete. Time elapsed is ' num2str(prob_time) ' seconds.']);
elseif strcmp(mode, 'unique')
    tic;
%     symbol = unique(x);
    %% ADDED TO GENERATE A GLOBAL DICTIONNARY - EVERY CASE IS NEEDED
    symbol = (-2^(nbits-1):2^(nbits-1)-1);
    count = zeros(size(symbol));
    parfor ind_sym = 1:length(symbol)
        %disp(num2str(symbol(ind_sym)));
        count(ind_sym) = count(ind_sym)+sum(x==symbol(ind_sym));
    end
    sym_zero = count == 0;
    count(sym_zero) = 1;
    prob = count/(length(x)+sum(sym_zero));
    %% END
%     count = zeros(size(symbol));
%     for ind_x = 1:length(x)
%         %if ~mod(ind_x, 100000) disp('test'); end
%         count(symbol==x(ind_x)) = count(symbol==x(ind_x))+1;
%     end
%     prob = count/length(x);
    prob_time = toc;
    disp(['Unique algorithm complete. Time elapsed is ' num2str(prob_time) ' seconds.']);
else
    disp(['Mode ', mode, ' not recognized']);
    error;
end

end
