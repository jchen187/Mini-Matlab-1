%%Part 2 - Gaussian Random Variable
%Set mu and sigma to generate data
n = 1;
m = 100; 
mu = 50;
sigma = 5;

mseML2 = zeros(n,m);
mseCP2 = zeros(n,m);
iterations = 100;

%hyperparameters
%Good Guess
sigmaN = 6;
mu0 = 40;
sigma0 = 10;
%{ 
Bad Guess
sigmaN = 6;
mu0 = 10;
sigma0 = 20;
%}
x=0:1:100;
prior2 = normpdf(x,mu0,sigma0);
figure
plot(prior2)
title('Conjugate Prior');
ylabel('Likelihood');
xlabel('Mean');

for i = 1:iterations
    %generate random variables from normal distribution.
    zg = normrnd(mu,sigma,[n,m]);
    
    avgML2 = ones(n,m);
    avgCP2 = ones(n,m);
    for j = 1:m
        %Maximum Likelihood
        if j ~= 1
            avgML2(j) = (avgML2(j-1)*(j-1)+zg(j))/j;
        else
            avgML2(j) = zg(j);
        end
        %avgML(j2) = mean(z2(1:j2));
        
        %Conjugate Prior
        %N is the number of data points so it should equal j?
        N = j;
        avgCP2(j) = ((mu0*sigmaN)+(N*sigma0*avgML2(j)))/(N*sigma0+sigmaN);        
    end
    seML2 = (mu-avgML2).^2;
    mseML2 = mseML2 + seML2;
    
    seCP2 = (mu-avgCP2).^2;
    mseCP2 = mseCP2 + seCP2;
end

mseML2 = mseML2./iterations;
mseCP2 = mseCP2./iterations;

%For the posteriod use equation 2.142 from the textbook and rearrange
%variables
figure
x = 0:1:100;
N = 1;
posterior1 = normpdf(x,avgCP2(1),((sigmaN*sigma0)^2)/(sigmaN^2+ N*sigma0^2));
plot(posterior1)
title('Posterior After 1 Sample');
ylabel('Likelihood');
xlabel('Mean');

figure
N = 10;
posterior10 = normpdf(x,avgCP2(10),((sigmaN*sigma0)^2)/(sigmaN^2+ N*sigma0^2));
plot(posterior10)
title('Posterior After 10 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
N = 50;
posterior50 = normpdf(x,avgCP2(50),((sigmaN*sigma0)^2)/(sigmaN^2+ N*sigma0^2));
plot(posterior50)
title('Posterior After 50 Samples');
ylabel('Likelihood');
xlabel('Mean');

figure
N = m;
posteriorM = normpdf(x,avgCP2(m),((sigmaN*sigma0)^2)/(sigmaN^2+ N*sigma0^2));
plot(posteriorM)
title('Final Posterior');
ylabel('Likelihood');
xlabel('Mean');

figure
plot(mseCP2)
title('Gaussian Distribution CP2');
ylabel('Mean Square Error');
xlabel('Number of Measurements');

figure
plot(mseML2)
title('Gaussian Distribution ML2');
ylabel('Mean Square Error');
xlabel('Number of Measurements');






 