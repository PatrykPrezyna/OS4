function utility = SAU_Peak(peak_thru)
    a2=-2.67*(10^-7);
    b2=7.714*10^-5;
    c2=2.381*10^-4;
    d2=5.71*10^-3;
    x2=peak_thru;
    if x2>=200
        x2=200;
    end
    utility=(a2*x2^3)+(b2*x2^2)+(c2*x2)+d2;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end