close all;
clear all;
clc;

%%Part 1 - Binomial Random Variables 

N = 1;    %number of trials
p = 0.5;  %probability of success
n = 1;
m = 1000;

%MSE will take in the square errors from each iteration and find the
%average
mseML = zeros(n,m);
mseCP = zeros(n,m);
iterations = 100;

%hyperparameters if a and b are both 0, cp would work the same as ml
%Good Guess
a = 3;
b = 3;
%{
Bad Guess
a = 10
b = 3
%}

x=0:0.01:1;
prior = betapdf(x,a,b);
figure
plot(prior)
title('Conjugate Prior');
ylabel('Likelihood');
xlabel('Number of Measurements');

for i = 1:iterations
    %generate random variables from binomial distribution.
    z = binornd(N,p,[n,m]);
    %create variable to count number of ones
    num1 = 0;
    %create empty arrays that would give the mean of the numbers until the current
    %number(for ML) or the mean using the formula(for CP)
    %indexj 1 2  3   4  5
    %     z 0 0  1   1  0
    % avgML 0 0 .33 .5 .4
    avgML = ones(n,m);
    avgCP = ones(n,m);
    for j = 1:m
        %See if the number is a one
        if z(j) == 1
            num1 = num1 + 1;
        end
        %Maximum Likelihood
        if j ~= 1
            avgML(j) = (avgML(j-1)*(j-1)+z(j))/j;
        else
            avgML(j) = z(j);
        end
        %THIS IS A FASTER WAY BUT I FIGURED IT OUT LATER
        %avgML(j) = mean(z(1:j));
        %Conjugate Prior
        avgCP(j) = (num1+a)/(j+a+b);
    end
    %create an array that keeps track of the square of the difference 
    ...of each element and the real average. the average should get close to the real average 
    seML = (N*p-avgML).^2; %.^ takes each element from avgML and squares it. without the '.' , the matrix would multiply itself
    mseML = mseML + seML;
    
    seCP = (N*p-avgCP).^2;
    mseCP = mseCP + seCP;
end

%divide each element by the number of iterations to get the mean square
%error
mseML = mseML./iterations;
mseCP = mseCP./iterations;

%Integrate the plotting posteriors into the for loop
figure
x=0:1:100;
posterior1 = prior.*binopdf(x,100,avgCP(1));
plot(posterior1)
title('Posterior After 1 Sample');
ylabel('Likelihood');
xlabel('Mean');

figure
x=0:1:100;
posterior10 = prior.*binopdf(x,100,avgCP(10));
plot(posterior10)
title('Posterior After 10 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
x=0:1:100;
posterior50 = prior.*binopdf(x,100,avgCP(50));
plot(posterior50)
title('Posterior After 50 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
likelihood = binopdf(x,100,avgCP(m));
posteriorM = prior.*likelihood;
plot(posteriorM)
title('Final Posterior');
ylabel('Likelihood');
xlabel('Mean');

figure
plot(mseCP)
title('Binomial Distribution CP');
ylabel('Mean Square Error');
xlabel('Number of Measurements');

figure
plot(mseML)
title('Binomial Distribution ML');
ylabel('Mean Square Error');
xlabel('Number of Measurements');