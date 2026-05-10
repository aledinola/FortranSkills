function test_useful_m_codes()
%TEST_USEFUL_M_CODES Basic tests for MATLAB helpers in this folder.

test_locate();
test_interp1_scal();
test_golden();
test_goldenx();

fprintf('All useful_m_codes tests passed.\n');

end %end function

function test_locate()

xx = [1; 3; 5; 7];

assert_equal(locate(xx,0),0,'locate below grid');
assert_equal(locate(xx,1),1,'locate left endpoint');
assert_equal(locate(xx,4),2,'locate interior');
assert_equal(locate(xx,7),3,'locate right endpoint');
assert_equal(locate(xx,8),4,'locate above grid');

end %end function

function test_interp1_scal()

x = [1; 2; 4];
y = [10; 20; 60];

assert_close(interp1_scal(x,y,1.5),15,1e-12,'interp1_scal interior first interval');
assert_close(interp1_scal(x,y,3),40,1e-12,'interp1_scal interior second interval');
assert_close(interp1_scal(x,y,0),0,1e-12,'interp1_scal left extrapolation');
assert_close(interp1_scal(x,y,5),80,1e-12,'interp1_scal right extrapolation');

end %end function

function test_golden()

center = 1.234;
height = 7.5;
f = @(x,c,h) h - (x-c).^2;

[xmax,fmax] = golden(f,-2,4,1e-10,center,height);

assert_close(xmax,center,1e-5,'golden argmax');
assert_close(fmax,height,1e-10,'golden maximum value');

end %end function

function test_goldenx()

center = [0.25, 1.5, 2.75];
height = [2, 3, 4];
f = @(x,c,h) h - (x-c).^2;

[xmax,fmax] = goldenx(f,zeros(size(center)),3*ones(size(center)),1e-10,center,height);

assert_close(xmax,center,1e-5,'goldenx argmax');
assert_close(fmax,height,1e-10,'goldenx maximum value');

end %end function

function assert_equal(actual,expected,msg)

if ~isequal(actual,expected)
    error('%s: expected %s, got %s',msg,mat2str(expected),mat2str(actual));
end

end %end function

function assert_close(actual,expected,tol,msg)

if any(abs(actual-expected) > tol,'all')
    error('%s: expected %s, got %s',msg,mat2str(expected),mat2str(actual));
end

end %end function
