function [ bestvector, bestcost ] = PSOptimize( Record, Method, domain )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
stablecnt = 10;
totalcnt = 30;
particnt = 50;

[ paracnt, ~ ] = size( domain );
particles = zeros( particnt, paracnt );
% Set five reasonable initial particles.
particles( 1,: ) = [ 0.4650, 0.7813, 4.2711, 6.6101, 9.8262 ];
particles( 2,: ) = [ 0.6919, 0.6025, 1.6657, 8.8079, 10 ];
particles( 3,: ) = [ 0.6919, 0.6025, 1.6657, 8.8079, 12 ];
particles( 4,: ) = [ 0.6919, 0.6025, 3.6657, 8.8079, 10 ];
particles( 5,: ) = [ 0.8919, 0.4025, 1.6657, 8.8079, 8 ];

for iter = 1:paracnt    
    tempvec = domain(iter,1) + rand( particnt - 5, 1 ) * ( domain(iter,2) - domain(iter,1) );
    particles(6:end,iter) = tempvec;
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
    pbestcost( iter ) = costf( Record, Method, vector );
    if pbestcost(iter) > gbestcost
        gbestcost = pbestcost(iter);
        gbest = vector;
        fprintf( 'Initial bestcost = %d\n', gbestcost );
        vector
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
        cost = costf( Record, Method, vector );
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
    
    fprintf( 'For this paticles update loop, the best cost is %d.\n', gbestcost );
    gbest
    fprintf( 'A paticles update loop finished.\n' );
    
    if stableiter > stablecnt
        break;
    end
    stableiter = stableiter + 1;

end

bestvector = gbest;
bestcost = gbestcost;

end

