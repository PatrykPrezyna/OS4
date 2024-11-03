function utility = SAU_Volume(pass_vol)
    a1=-1.33*(10^-10);
    b1=4.57*10^-7;
    c1=1.1905*10^-4;
    d1=8.571*10^-3;
    x1=pass_vol;
    if x1>=2000
        x1=2000;
    end
    utility=(a1*x1^3)+(b1*x1^2)+(c1*x1)+d1;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end