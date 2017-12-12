%%Inputs for the simulation
%These variables: Z, alpha, and R will be used to define the parameters of
%the whole simulation
Z = 3; %strength/depth of cosh well
alpha = .5; %width parameter multiplying x in cosh
R = 3;

dmu = .001; %step size between mu values to go through

%Don't need to use muspread, but you can use it to specify the mu values 
%based on the energies of the bound states
muspread = 0.2; %distance to go out to left and right of bound state energies

%%Equations below are from Landau&Lifshitz QM Book
%Finds the total number of bound states, don't need to use this part if
%setting n manually below
s = 0.5*(-1+sqrt(1+(8*Z/alpha^2)));
n = mod(s,1);

if n == 0
    n = s;
else
    n = round(s-n)+1;
end

%Or you can just set the value of n if you know how many bound states there
%are or you want to include only the lowest few
n=3;

%Use this if setting the muspace using the energies and muspread
% ind = round(2*muspread/dmu)+1;
% Nmu = n*(ind);
% muspace = zeros(Nmu,1);

%The energy levels of the isolated system will be stored here
E=zeros(1,n);

%Energy of the bound states and add to muspace
for i = 1:n
    En = -alpha^2/8*(-(1+2*(i-1))+sqrt(1+(8*Z/alpha^2)))^2;
    E(i) = En;
    
end

%Emin = -alpha^2/8*(-(1+2*(1-1))+sqrt(1+(2*8*Z/alpha^2)))^2;

%Set the counting variable which keeps track of the value of mu you are on
%in the main code
count = 1;

%%Set the values of mu you wish to calculate by either using specific
%values/ranges or using the calculated energy levels

%Set one range of values
%muspace=(-2.55:dmu:-.55);

%Set two separate ranges (useful when doing many values of mu over a small range
%in the areas where N switches between integer numbers
muspace = [-2.55:dmu:-2.35, -1.65:dmu:-1.35];

%Set the mu values using energy levels and the muspread value
% muspace=(E(1)-muspread:dmu:E(1)+muspread);
% muspace=[E(1)-muspread:dmu:E(1)+muspread , E(2)-muspread:dmu:E(2)+muspread];

%Initialize the variable which stores the eigenvalues of the atomic
%fragment for each mu value
Nmu=max(size(muspace));
Evalrec=zeros(n,Nmu);

%Specify the filename for storing the data, initialize the input file data
%and create the variable 
fileOutName=sprintf('OutputFile_%ucosh%u_R%u.mat',Z,10*alpha,R);

save('InputMu.mat','Z','alpha','muspace','count','fileOutName','R');

save(fileOutName,'Evalrec');