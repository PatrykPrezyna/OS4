function utility = SAU_Wait(wait_time)
    a3=1.116*(10^-4);
    b3=-4.76*10^-3;
    c3=8.98*10^-3;
    d3=1.00455;
    x3=wait_time;
    if x3>=0.5
        x3=30;
    else
        x3=x3*60;
    end
    utility=(a3*x3^3)+(b3*x3^2)+(c3*x3)+d3;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end