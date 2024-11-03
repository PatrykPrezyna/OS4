function utility = MAU(SAU_Avail,SAU_Wait,SAU_Volume,SAU_Peak)
p1=0.15;
p2=0.25;
p3=0.35;
p4=0.25;
utility=(p1*SAU_Volume)+(p2*SAU_Peak)+(p3*SAU_Wait)+(p4*SAU_Avail);
end