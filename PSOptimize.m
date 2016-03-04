function [ bestvector, bestcost ] = PSOptimize( Signal, Fs, atr, domain )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
stablecnt = 20;
totalcnt = 100;
particnt = 50;

[ paracnt, ~ ] = size( domain );
particles = zeros( particnt, paracnt );
for iter = 1:paracnt    
    tempvec = domain(iter,1) + rand( particnt, 1 ) * ( domain(iter,2) - domain(iter,1) );
    particles(:,iter) = tempvec;
    velocities = 0.05 * ones( particnt, paracnt );
end

c1 = 0.4;
c2 = 0.6;
w = 0.5;
lamda = 0.1;

pbest = particles;
pbestcost = zeros( particnt, 1 );
gbest = zeros( paracnt, 1 );
gbestcost = 0;

%% Initial particles
for iter = 1:particnt
    fprintf( 'Initial particles:%d\n',iter );
    vector = particles( iter,: );
    Rpeak = KNNdetected( Signal, Fs, vector );
    pbestcost( iter ) = costf( Rpeak, Fs, atr );
    if pbestcost(iter) > gbestcost
        gbestcost = pbestcost(iter);
        gbest = vector;
    end
end

%% Funtion main part
stableiter = 1;
for iter = 1:totalcnt
    
    for jter = 1:particnt
%         clc;
        %% Update the particles
        fprintf( 'totalcnt = %d\t,rightiter = %d\n',totalcnt, iter );
        fprintf( 'ParticlesCnt = %d\t,rightiter = %d\n', particnt, jter );
        velocities(jter,:) = velocities(jter,:) + c1 * rand() * ( pbest(jter) - particles(jter) ) + ...
            c2 * rand() * ( gbest - particles(jter) );
        particles(jter,:) = particles(jter,:) + lamda * velocities(jter,:);
        
       %% edge control
        for kter = 1:paracnt
            if particles(jter,kter) < domain(kter,1)
                particles(jter,kter) = domain(kter,1);
            elseif particles(jter,kter) > domain(kter,2)
                    particles(jter,kter) = domain( kter,2 );
            end
        end
       
        %% Update the gbest and pbest
        vector = particles(jter,:);
        Rpeak = KNNdetected( Signal, Fs, vector );
        cost = costf( Rpeak, Fs, atr );
        fprintf( 'cost = %d\n', cost );
        if cost > pbestcost(jter)
            pbestcost(jter) = cost;
            pbest(jter,:) = vector;
            if cost > gbestcost
                gbestcost = cost;
                gbest = vector;
                gbestcost
                gbest
                stableiter = 1;
            end
        end
    end
    
    if stableiter > stablecnt
        break;
    end
    stableiter = stableiter + 1;

end

bestvector = gbest;
bestcost = gbestcost;

end

