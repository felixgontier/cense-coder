function x_c = delta_enc(x)

if isvector(x)
    x_c = zeros(size(x));
    prev = 0;
    for indel = 1:length(x)
        x_c(indel) = x(indel) - prev;
        prev = x(indel);
    end
else
    assert(ndims(x)<=2);
    x_c = zeros(size(x));
    prev = 0;
    for indel = 1:size(x, 2)
        x_c(:, indel) = x(:, indel) - prev;
        prev = x(:, indel);
    end
end

end
