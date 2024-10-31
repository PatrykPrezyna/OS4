for i=1:length(Design)
    x(i) = Design(i).cost;
    y(i) = Design(i).Availability;
end

scatter(x,y)
