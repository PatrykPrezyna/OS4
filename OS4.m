run('Data.m')

%Functions
% Calculate availability

%Apply constraints
% I not sure how/where in the code to skip this designs that do not
% fullfiled the constraints


%design generation
iteration=1;
for b=1:length(Battery)
    for c=1:length(Chassis)
        for bc=1:length(Battery_charger)
            for a=1:length(Autonomous_system)
                %Cost
                Design(iteration).cost = Battery(b).cost+Chassis(c).cost+Battery_charger(bc).cost+Autonomous_system(a).cost;
                %SAU Availability
                Design(iteration).Battery_charge_time = Battery(b).capacity/Battery_charger(bc).power;  
                Design(iteration).Power_consumption = Chassis(c).power_consumption + Autonomous_system(a).power_consumption;
                %SAU Passenger trips/hour
                %SAU Passenger trips/day
                %SAU Average waiting time
                %Additional attributes
                Design(iteration).autonomy_level = Autonomous_system(a).level;
                Design(iteration).valid = 1;% simpe idea how to select dasigns ?
                iteration=iteration+1;
            end
        end
    end
end

