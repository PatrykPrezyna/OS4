function SAU = SAU_Availability(x)
    Y=[0,0.2,0.4,0.8,1];
    X=[0,500,1000,1500,2000];
    %some magic with polyval and ...
    SAU = x/2000; 
    if SAU > 1
       SAU = 1; 
    end
end
