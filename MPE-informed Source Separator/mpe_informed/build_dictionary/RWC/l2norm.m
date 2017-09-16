function x = l2norm(x)
n = size(x, 1);
for i=1:n
    ratio = sqrt(x(i,:)*x(i,:)');
    x(i,:) = x(i,:)./ratio;
end
x(isnan(x)) = 0;
x(isinf(x)) = 0;