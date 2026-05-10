% Fast linear interpolation routine
% Usage:
% yi = interp1_scal(x,y,xi)
% where x and y are column vectors with n elements, xi is a scalar 
% and yi is a scalar
% Input Arguments
% x - Sample points
%   column vector
% Y - Sample data
%   column vector
% xi - Query point
%   scalar
function yi = interp1_scal(x,y,xi)

n = size(x,1);
j = locate(x,xi);
j = max(min(j,n-1),1);

slope = (y(j+1)-y(j))/(x(j+1)-x(j));
yi = y(j)+(xi-x(j))*slope;

end %end function interp1_scal

function jl = locate(xx,x)
%function jl = locate(xx,x)
%
% x is between xx(jl) and xx(jl+1)
%
% jl = 0 and jl = n means x is out of range
%
% xx is assumed to be monotone increasing

n = length(xx);
if x<xx(1)
    jl = 0;
elseif x>xx(n)
    jl = n;
else
    jl = 1;
    ju = n;
    while (ju-jl>1)
        jm = floor((ju+jl)/2);
        if x>=xx(jm)
            jl = jm;
        else
            ju=jm;
        end
    end
end

end %end function locate




