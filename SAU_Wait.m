function utility = SAU_Wait(wait_time)
    a=1.116*(10^-4);
    b=-4.76*10^-3;
    c=8.98*10^-3;
    d=1.00455;

    utility=(a*wait_time^3)+(b*wait_time^2)+(c*wait_time)+d;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end