function utility = SAU_Peak(peak_thru)
    % the polinomian coeficints are calculate in the attached csv file
    a=-2.67*(10^-7);
    b=7.714*10^-5;
    c=2.381*10^-4;
    d=5.71*10^-3;

    utility=(a*peak_thru^3)+(b*peak_thru^2)+(c*peak_thru)+d;
    if utility>1
        utility=1;
    elseif utility<0
        utility=0;
    end
end