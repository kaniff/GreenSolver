clear;
%Need to run setup file which sets up the mex functions used in the code
setup

%Turn off this warning because it's not very important and wastes a lot of
%space
warning off MATLAB:nearlySingularMatrix

%inputs Z, alpha, R, muspace, and count which is edited at end to add to 
%count and remove the mu value that was just calculated
lastmu=false;
while lastmu==false
    
load('InputMu.mat');
lastmu = false;
musave = muspace(1);

if max(size(muspace)) == 1
    lastmu = true;
else
    muspace = muspace(2:end);
end

if ~lastmu
    count = count + 1;
    alpha=alpha;
    save('InputMu.mat','Z','muspace','count','alpha','fileOutName','R');
    count = count - 1;
end
disp(count)
muspace = musave;

%Metal fragment parameters
L=20; %Length of potential well in our simulation
s=5; %steepness parameter
V0=3.5; %Depth of potential step
    

%Can manually set one value for muspace and overwrite Z and alpha if you
%want to
% muspace = -.53;
% Z = 1;
% alpha = 0.2;
%You can set a range of R, but I choose to do individual R values for
%simplicity
% Rrange = (4.0:0.1:4.5); %Separation between M and A

Rrange = R;
NR=max(size(Rrange));

%Loop through all values of R
for j=1:NR
    R=Rrange(j);
    
    %Values to initialize the spatial grid
    start=15; %Specifies the maximum x value on the RHS of the simulation
    dx=0.1; %spatial step size
    xmin=-L-R; 
    xmax=start;

    x=(xmin:dx:xmax)'; %initialize spatial grid
    Nelem=max(size(x)); %Number of grid points
    
    %Initialize potential of metal fragment: A
    va=-V0+V0./(1+exp(-s*(x+R)));
    
    
    %initialize potential of atomic fragment: B
    vb = -Z*cosh(x*alpha).^-2;
    
    %Create fragment potentials along with the left & right BCs on fragments
    vi = [va,vb]; %Total fragment potential for [A,B]
    vLi = [-V0,0]; %LHS BC's for fragment [A,B]
    vRi = [0,0]; %RHS BC's for fragment [A,B]
    
    
    %Initialize functions
    solver = solver_fh(Nelem,dx);
    shoot=shoot_fh(Nelem,dx);
    bssolver = shootsolver_fh(Nelem,dx);
    evsolver = shooteigsolver_fh(Nelem,dx);
    
    %Setup variables which will store all final results
    Nmu = max(size(muspace));
    Nrec = zeros(Nmu,1); %N_atom for each mu value
    Hrec = zeros(Nmu,1); %dmu_atom/dN_atom for each mu value
    dNatom_dmu = zeros(Nmu,1);
    dNmetal_dmu = zeros(Nmu,1);
    dNtot_dmu = zeros(Nmu,1);
    mub = zeros(Nmu,1); %the system chemical potential
    vprec = zeros(Nelem,Nmu); %partition potential
    narec = zeros(Nelem,Nmu); %Metal fragment density
    nbrec = zeros(Nelem,Nmu); %Atomic fragment density
    nmrec = zeros(Nelem,Nmu); %Molecular/Reference density

    %Loop through all values of mu
    for i = 1:Nmu
        
        mu = muspace(i);
        %Calculate total system density & the isolated fragment densities
        %and use them to approximate an initial guess for N_atom
        nm = solver(mu,va+vb,sum(vLi),sum(vRi));
        n10 = solver(mu,va,vLi(1),vRi(1));
        MaxEval = nodecount(shoot(0,vb,0,0));
        [evals,evecs] = evsolver(MaxEval,vb);
        diffs = evals - mu;
        [~,index]=min(abs(diffs));
        if index == 1
            ncore = zeros(Nelem,1);
        else
            ncore = sum(evecs(:,1:index-1).^2,2);
        end
        nfuk = evecs(:,index).^2;
        Natom = sum((nm-n10-ncore).*nfuk)/sum(nfuk.^2);
        
%         Ntest = sum((nm-n10-ncore).*nfuk)/sum(nfuk.^2);
%         if Natom > 1
%             Natom = (index-1)+Natom;
%         else
%             Natom = (index-1)+max(min(Natom,1),0);
%         end
        %Natom above only gets the fractional piece, so we need to add the
        %any missing integer component
        Natom = (index-1) + max(Natom,0);
        n20 = bssolver(Natom,vb);
        
        %Initialize variables for vp, the predicted value for the next
        %iteration, and the proposed change in vp
        vp = zeros(size(nm));
        vp_pred = zeros(size(nm));
        dvp = zeros(size(nm));
        
        %Do Not Change. Used to fix errors arising from numerical inaccuracy 
        %where small metal fragment densities arise in the atomic region 
        msk1 = nm<1e-10;
        msk2 = nm>1e-15;
        
        %Initialize more values. Can change maxiter and tol, but not
        %recommended
        dN = 0;
        eval = 0;
        diffmu = 1;
        N_lowbound = -inf;
        N_upbound = inf;
        iter = 0;
        maxiter = 20;
        tol = eps;
        done = false;
        %Find a value of vp which gives fragment densities that add to the
        %total density, then see if the fragment chemical potentials
        %equalize and if they don't and it's not at an integer N, we change
        %N_atom and repeat the process
        while (~done && iter <= maxiter)
            vp_old = vp;
            eval_old = eval;
            
            vp_pred(msk1) = vp_pred(find(~msk1,1,'last'));
            vp_part = partialinvert({solver,bssolver},nm,[mu,Natom],vi,vLi,vRi,msk2,eps,vp_pred);
            vp(msk2) = vp_part;
            vp(~msk2) = vp_pred(find(~msk1,1,'last'));
         
            [na,chia] = solver(mu,va+vp,vLi(1),vRi(1));
            [nb,chib] = bssolver(Natom,vb+vp);

            nf = na+nb;

            if mod(Natom,1) ~= 0
                [eval,evec] = evsolver(Natom,vb+vp);
                fb = evec(:,end).^2;
                mu_atom = eval(ceil(Natom));
                mu_atom_plus = mu_atom;
                
                Epdft = sum(eval(1:floor(Natom))) + eval(end)*mod(Natom,1);
                E = Epdft - sum(vp.*nb)*dx;
            else
                [eval,evec] = evsolver(Natom+1,vb+vp);
                if Natom == 0
                    mu_atom = -inf;
                    fb = zeros(Nelem,1);
                else   
                    mu_atom = eval(Natom);
                    fb = evec(:,end-1).^2;
                end
                
                if max(size(eval))==Natom
                    mu_atom_plus = 0;
                else
                    mu_atom_plus = eval(Natom+1);
                end
                
                if mu_atom < mu && mu < mu_atom_plus
                    done = true;
                end
                
                Epdft = sum(eval(1:floor(Natom)));
                E = Epdft - sum(vp.*nb)*dx;
            end
                
            % differential for how vp changes for small changes in Natom with
            % total density fixed
            dvp_dNatom = -(chib+real(chia))\fb;
            % corresponding change in atom's chemical potential
            dmuatom_dN = (sum(dvp_dNatom.*fb)*dx);
            
            %dvp = -(chib+chia)\fb;
            
            diffmu = mu-mu_atom;
            
            %If the chemical potentials equalize then the inversion is done
            if (abs(diffmu) < tol)
                done = true;
            end

            dN = diffmu/dmuatom_dN;

            if dN > 0
                N_lowbound = Natom;
                % should we worry about crossing integer or bound on N?
                if N_upbound <= floor(Natom) + 1
                    if dN + Natom >= N_upbound
                        % then we bisect:
                        dN = (N_upbound + Natom)/2 - Natom;
                    end
                else
                    if dN + Natom >= floor(Natom) + 1
                        % then we go to upperbounding integer
                        dN = floor(Natom) + 1 - Natom;
                    end
                end
            else
                N_upbound = Natom;
                
                % should we worry about crossing integer or bound on N?
                if N_lowbound >= ceil(Natom) - 1
                    if dN + Natom <= N_lowbound
                        % then we bisect:
                        dN = (N_lowbound + Natom)/2 - Natom;
                    end
                else
                    if dN + Natom <= ceil(Natom) - 1
                        % then we go to lowbounding integer
                        dN = ceil(Natom) - 1 - Natom;
                    end
                end
            end
            
            % if upper and lower bounds are equal we are done
            if (N_lowbound == N_upbound) || done
                done = true;
            else
                Natom = Natom + dN;
            end
               

            dvp = dvp_dNatom*dN;
            vp_pred = vp + dvp;
            eval_pred = eval + dmuatom_dN*dN;
            
            iter = iter + 1;
        end
        
        % changes in densities w.r.t changes in total chemical potential
        dnm_dmu = -2*real(ldos(shoot(mu,va+vb,sum(vLi),sum(vRi))));
        dna_dmu = -2*real(ldos(shoot(mu,va+vp,sum(vLi),sum(vRi))));
        dNatom_dmu(i) = -(1-sum(fb.*((chia+chib)\(dnm_dmu-dna_dmu)))*dx)./(sum(fb.*((chia+chib)\fb))*dx);
        dNmetal_dmu(i) = sum(dna_dmu)*dx;
        dNtot_dmu(i) = sum(dnm_dmu)*dx;

        MaxEval = nodecount(shoot(0,vb+vp,0,0));
        [eval,evec]=evsolver(MaxEval,vb+vp);

        %If you reached the max number of iterations before getting the correct
        %result do not store the results and can put them into a failed output
        %file
        if iter>maxiter && diffmu>eps*1000 && mod(Natom,1)~= 0
            filename=sprintf('FailedOutput_%d_R%u.mat',count,R);
            save(filename,'eval','Natom','vp','na','nb','nm','E','Epdft','mu','mu_atom','dNatom_dmu','dmuatom_dN','dvp','dN');

        else
            %Use filename specified by input file
            load(fileOutName);

            dN_dmurec(count)=dNatom_dmu;
            Evalrec(1:max(size(eval)),count)=eval(:,1); %Store the e.values
            Erec(count) = E; %Fragment energy without vp
            Eprec(count) = Epdft; %Fragment energy with vp
            Nrec(count) = Natom;
            Hrec(count) = dmuatom_dN;
            mub(count) = mu; %system mu
            mua(count) = mu_atom; %atom fragment mu
            vprec(:,count) = vp;
            varec(:,count) = va; %metal fragment potential
            vbrec(:,count) = vb; %atomic fragment potential
            xrec(:,count) = x;

            %Fragment and reference densities
            narec(:,count) = na;
            nbrec(:,count) = nb;
            nmrec(:,count) = nm;

            save(fileOutName,'Erec','Evalrec','Eprec','dN_dmurec','Nrec','Hrec','mub','mua','vprec','varec','vbrec','xrec','narec','nbrec','nmrec');


        end
    end    
end
end