disp(' '); disp('clear all, close all');
clear all, close all
disp(' ');

disp('meanfunc = {@meanSum, {@meanLinear, @meanConst}}; hyp.mean = [0.5; 1];');
meanfunc = {@meanSum, {@meanLinear, @meanConst}}; hyp.mean = [0.5; 1];
disp('covfunc = {@covMaterniso, 3}; ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);');
covfunc = {@covMaterniso, 3}; ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);
disp('likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn);');
likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn);
disp(' ');

disp('n = 20;');
n = 20;
disp('x = gpml_randn(0.3, n, 1);');
x = gpml_randn(0.3, n, 1);
disp('K = feval(covfunc{:}, hyp.cov, x);');
K = feval(covfunc{:}, hyp.cov, x);
disp('mu = feval(meanfunc{:}, hyp.mean, x);');
mu = feval(meanfunc{:}, hyp.mean, x);
disp('y = chol(K)''*gpml_randn(0.15, n, 1) + mu + exp(hyp.lik)*gpml_randn(0.2, n, 1);');
y = chol(K)'*gpml_randn(0.15, n, 1) + mu + exp(hyp.lik)*gpml_randn(0.2, n, 1);
 
figure(1)
set(gca, 'FontSize', 24)
disp(' '); disp('plot(x, y, ''+'')');
plot(x, y, '+', 'MarkerSize', 12)
axis([-1.9 1.9 -0.9 3.9])
grid on
xlabel('input, x')
ylabel('output, y')

%print -depsc f0.eps
%disp(' '); disp('Hit any key to continue...'); pause

%***********************************************************************

disp(' ');
disp('nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)');
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)
disp(' ')

disp('z = linspace(-1.9, 1.9, 101)'';');
z = linspace(-1.9, 1.9, 101)';
disp('[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);');
[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);

figure(2)
set(gca, 'FontSize', 24);
disp(' ');
disp('f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];'); 
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)]; 
disp('fill([z; flipdim(z,1)], f, [7 7 7]/8);');
fill([z; flipdim(z,1)], f, [7 7 7]/8);

disp('hold on; plot(z, m); plot(x, y, ''+'')')
hold on; plot(z, m, 'LineWidth', 2); plot(x, y, '+', 'MarkerSize', 12)
axis([-1.9 1.9 -0.9 3.9])
grid on
xlabel('input, x')
ylabel('output, y')

%print -depsc f1.eps
%disp(' '); disp('Hit any key to continue...'); pause


%***********************************************************************

disp(' ');
disp('covfunc = @covSEiso; hyp2.cov = [0; 0]; hyp2.lik = log(0.1);');
covfunc = @covSEiso; hyp2.cov = [0; 0]; hyp2.lik = log(0.1);

% Minimize a differentiable multivariate function using conjugate gradients.
%
% Usage: [X, fX, i] = minimize(X, f, length, P1, P2, P3, ... )
% 
% X       initial guess; may be of any type, including struct and cell array
% f       the name or pointer to the function to be minimized. The function
%         f must return two arguments, the value of the function, and it's
%         partial derivatives wrt the elements of X. The partial derivative  
%         must have the same type as X.
% length  length of the run; if it is positive, it gives the maximum number of
%         line searches, if negative its absolute gives the maximum allowed
%         number of function evaluations. Optionally, length can have a second
%         component, which will indicate the reduction in function value to be
%         expected in the first line-search (defaults to 1.0).
% P1, P2, ... parameters are passed to the function f.
%
% X       the returned solution
% fX      vector of function values indicating progress made
% i       number of iterations (line searches or function evaluations, 
%         depending on the sign of "length") used at termination.

disp('hyp2 = minimize(hyp2, @gp, -100, @infExact, [], covfunc, likfunc, x, y)');
hyp2 = minimize(hyp2, @gp, -100, @infExact, [], covfunc, likfunc, x, y);
disp(' ');

disp('exp(hyp2.lik)');
exp(hyp2.lik)
disp('nlml2 = gp(hyp2, @infExact, [], covfunc, likfunc, x, y)');
nlml2 = gp(hyp2, @infExact, [], covfunc, likfunc, x, y)
disp('[m s2] = gp(hyp2, @infExact, [], covfunc, likfunc, x, y, z);');
[m s2] = gp(hyp2, @infExact, [], covfunc, likfunc, x, y, z);

disp(' ')
figure(3)
set(gca, 'FontSize', 24)
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
disp('fill([z; flipdim(z,1)], f, [7 7 7]/8)');
fill([z; flipdim(z,1)], f, [7 7 7]/8)
disp('hold on; plot(z, m); plot(x, y, ''+'')');
hold on; plot(z, m, 'LineWidth', 2); plot(x, y, '+', 'MarkerSize', 12)
grid on
xlabel('input, x')
ylabel('output, y')
axis([-1.9 1.9 -0.9 3.9])
%print -depsc f2.eps
%disp(' '); disp('Hit any key to continue...'); pause


%***********************************************************************

disp(' ');
disp('hyp.cov = [0; 0]; hyp.mean = [0; 0]; hyp.lik = log(0.1);');
hyp.cov = [0; 0]; hyp.mean = [0; 0]; hyp.lik = log(0.1);

disp('hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x, y);');
hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, x, y);


disp('[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);');
[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);

figure(4)
set(gca, 'FontSize', 24)
disp(' ');
disp('f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];');
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
disp('fill([z; flipdim(z,1)], f, [7 7 7]/8)');
fill([z; flipdim(z,1)], f, [7 7 7]/8)
disp('hold on; plot(z, m); plot(x, y, ''+'');');
hold on; plot(z, m, 'LineWidth', 2); plot(x, y, '+', 'MarkerSize', 12)
grid on
xlabel('input, x')
ylabel('output, y')
axis([-1.9 1.9 -0.9 3.9])

%print -depsc f3.eps
%disp(' '); disp('Hit any key to continue...'); pause

%***********************************************************************

disp('large scale regression using the FITC approximation')
disp('nu = fix(n/2); u = linspace(-1.3,1.3,nu)'';')
nu = fix(n/2); u = linspace(-1.3,1.3,nu)';
disp('covfuncF = {@covFITC, {covfunc}, u};')
covfuncF = {@covFITC, {covfunc}, u};
disp('[mF s2F] = gp(hyp, @infFITC, meanfunc, covfuncF, likfunc, x, y, z);')
[mF s2F] = gp(hyp, @infFITC, meanfunc, covfuncF, likfunc, x, y, z);

figure(5)
set(gca, 'FontSize', 24)
disp(' ');
disp('f = [mF+2*sqrt(s2F); flipdim(mF-2*sqrt(s2F),1)];');
f = [mF+2*sqrt(s2F); flipdim(mF-2*sqrt(s2F),1)];
disp('fill([z; flipdim(z,1)], f, [7 7 7]/8)');
fill([z; flipdim(z,1)], f, [7 7 7]/8)
disp('hold on; plot(z, mF); plot(x, y, ''+'');');
hold on; plot(z, mF, 'LineWidth', 2); plot(x, y, '+', 'MarkerSize', 12)
disp('plot(u,1,''o'')')
plot(u,1,'ko', 'MarkerSize', 12)
grid on
xlabel('input, x')
ylabel('output, y')
axis([-1.9 1.9 -0.9 3.9])
print -depsc f4.eps
disp(' ');