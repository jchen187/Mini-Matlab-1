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

%Prior hyperparameters - if a and b are both 0, cp would work the same as ml
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
title('Binomial Prior');
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
            %the first element is always a 1 or 0
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
%the posterior is the prior times the liklihood
posterior1 = prior.*binopdf(x,100,avgCP(1));
plot(posterior1)
title('Binomial Posterior After 1 Sample');
ylabel('Likelihood');
xlabel('Mean');

figure
x=0:1:100;
posterior10 = prior.*binopdf(x,100,avgCP(10));
plot(posterior10)
title('Binomial Posterior After 10 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
x=0:1:100;
posterior50 = prior.*binopdf(x,100,avgCP(50));
plot(posterior50)
title('Binomial Posterior After 50 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
likelihood = binopdf(x,100,avgCP(m));
posteriorM = prior.*likelihood;
plot(posteriorM)
title('Binomial Final Posterior');
ylabel('Likelihood');
xlabel('Mean');

figure
plot(mseCP)
title('Binomial Error Using CP');
ylabel('Mean Square Error');
xlabel('Number of Measurements');

figure
plot(mseML)
title('Binomial Error Using ML');
ylabel('Mean Square Error');
xlabel('Number of Measurements');


%%Part 2 - Gaussian Random Variable
%We have a liklihood that is a normal distribution with unknown mean and variance
%model parameters = mu and t(precision)

%Set mu and sigma of the right distribution
mu = 50;
sigma = 5;
%we could create a pdf 

%set hyperparameters for prior
%Good Guess
mu0 = 40;
lambda = 5; % number of observations
alpha = 5; 
beta = 20; 

%x and t are the supports(where the bounds are?)
[x,t] = meshgrid(0:1:100, 0:0.1:2);

%the conjugate prior for this liklihood is a normal inverse gamma
part1 = (beta.^alpha).*sqrt(lambda)./(gamma(alpha).*sqrt(2.*pi));
part2 = t.^gamma(alpha-0.5);
part3 = exp(-beta.*t);
part4 = exp((-lambda*t.*(x-mu0).^2)./2);
prior = part1.*part2.*part3.*part4;

figure
mesh(x,t,prior)
title('Gaussian Prior');
zlabel('Likelihood');
xlabel('Mean');
ylabel('T')

%We will eventually have the mean square error in these two arrays, one from maximum liklihood and one from conjugate priors They
%both contain 100 elements
n = 1;
m = 100;
mseML = zeros(n,m);
mseCP = zeros(n,m);

iterations = 100;
%Which Ones Do I want to Print
indexPrint = [1,10,50,100];
for i = 1:iterations
        %generate random variables from normal distribution.
    zg = normrnd(mu,sigma,[n,m]);
    
    %create an array the same size as zg. they will contain the average of
    %all the previous numbers including itself for this ONE iteration
    avgML = ones(n,m);
    avgCP = ones(n,m);
    for j = 1:m
        %Maximum Likelihood
        avgML(j) = mean(zg(1:j)); 
        
        %Posterior Hyperparameters
        mu0_NEW = (lambda*mu0+j*avgML(j))/(lambda+j);
        lambda_NEW = lambda+j; % number of observations
        alpha_NEW = alpha+j/2; 
        beta_NEW = beta+0.5*sum(zg(1:j)-avgML(j))+((j*lambda)/(j+lambda))*((avgML(j)-mu0)^2)/2;
        avgCP(j) = mu0_NEW;
        
        if (i==1 && isMember(j,indexPrint))
            likelihood = normpdf(x,mu0_NEW,beta_NEW/alpha_NEW);
            part1 = (beta_NEW.^alpha_NEW).*sqrt(lambda_NEW)./(gamma(alpha_NEW).*sqrt(2.*pi));
            part2 = t.^gamma(alpha_NEW-0.5);
            part3 = exp(-beta_NEW.*t);
            part4 = exp((-lambda_NEW*t.*(x-mu0_NEW).^2)./2);
            prior = part1.*part2.*part3.*part4; 
            posterior = prior.*likelihood;
            figure
            mesh(x,t,posterior);
            title(strcat('Gaussian Posterior After ',num2str(j),' Samples'));
            zlabel('Likelihood');
            xlabel('Mean');
            ylabel('T');
        end
    end
    
    %create an array that stores the square error for this ONE iteration
    seML2 = (mu-avgML2).^2;
    %add up all square errors for ALL iterations
    mseML2 = mseML2 + seML2;
      
    seCP2 = (mu-avgCP2).^2;
    mseCP2 = mseCP2 + seCP2;
end

%We have to divide by iterations to get the mean error for each 
mseML2 = mseML2./iterations;
mseCP2 = mseCP2./iterations;

figure
plot(mseML2)
title('Gaussian Error Using ML');
ylabel('Mean Square Error');
xlabel('Number of Measurements');

figure
plot(mseCP2)
title('Gaussian Error Using CP');
ylabel('Mean Square Error');
xlabel('Number of Measurements');




