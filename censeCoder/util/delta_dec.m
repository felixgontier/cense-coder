function x_d = delta_dec(x_c)

assert(isvector(x_c));

x_d = zeros(size(x_c));
prev = 0;
for indel = 1:length(x_c)
    x_d(indel) = x_c(indel) + prev;
    prev = x_d(indel);
end

end
