function tests = newEmittersTest
%NEWEMITTERSTEST UnitTests for newEmitters()
%
%   To run the tests: 
%   >> run(newEmittersTest)
%
%   see https://www.mathworks.com/help/matlab/matlab_prog/write-function-based-unit-tests-.html
tests = functiontests(localfunctions);
end

function testCreateEmittersNoArgs(testCase)
% Call Emitters with no args

x = newEmitters();

% Check that fiels exist

testCase.assertTrue(isfield(x,'HTM'));
testCase.assertTrue(isfield(x,'Pb'));
testCase.assertTrue(isfield(x,'Ps'));
testCase.assertTrue(isfield(x,'m'));

end

function testCreateEmittersOneArg(testCase)
% Call Emitters with one arg
% Single arg should be the number of elements

n = 3;

x = newEmitters(n);

% Check that fiels exist
testCase.assertTrue(isfield(x,'HTM'));
testCase.assertTrue(isfield(x,'Pb'));
testCase.assertTrue(isfield(x,'Ps'));
testCase.assertTrue(isfield(x,'m'));

% Check that array of proper size was created
testCase.assertEqual(numel(x),n);

% Check that HTM is correct
for i=1:n
  testCase.assertEqual(x(i).HTM,eye(4));
end

end

function testCreateEmittersThreeArgs(testCase)
% Call newEmitters with 3 arguments
% Arguments must be: Pb, Ps, m

% Should return an array of Emitters with a single element and the fields
% initialized to the argument values

Pb_test = 0.1;
Ps_test = 0.05;
m_test = 5;

x = newEmitters(Pb_test, Ps_test, m_test);

% Assert number of elements created
testCase.assertEqual(numel(x),1);

% Assert field values
testCase.assertEqual(x.Pb, Pb_test);
testCase.assertEqual(x.Ps, Ps_test);
testCase.assertEqual(x.m, m_test);
testCase.assertEqual(x.HTM,eye(4));

end


function testCreateEmittersFourArgs(testCase)
% Call newEmitters with 4 arguments
% Arguments must be: n_Emitters, Pb, Ps, m

% Should return an array of Emitters with n_Emitters and the fields
% initialized to the remaining argument values: Pb, Ps, m

nEmit_test = 4;
Pb_test = 0.1;
Ps_test = 0.05;
m_test = 5;

x = newEmitters(nEmit_test, Pb_test, Ps_test, m_test);

% Assert number of elements created
testCase.assertEqual(numel(x),nEmit_test);

% Assert field values
for i=1:nEmit_test
  testCase.assertEqual(x(i).Pb, Pb_test);
  testCase.assertEqual(x(i).Ps, Ps_test);
  testCase.assertEqual(x(i).m, m_test);
  testCase.assertEqual(x(i).HTM,eye(4));
end


end
