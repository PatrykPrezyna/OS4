function utility = SAU_Volume(pass_vol)
    a=-1.33*(10^-10);
    b=4.57*10^-7;
    c=1.1905*10^-4;
    d=8.571*10^-3;

    utility=(a*pass_vol^3)+(b*pass_vol^2)+(c*pass_vol)+d;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end