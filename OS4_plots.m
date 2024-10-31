for i=1:length(Design)
    x(i) = Design(i).cost;
    y(i) = Design(i).Battery_charge_time;
end

scatter(x,y)
