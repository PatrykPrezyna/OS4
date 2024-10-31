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
            Design(iteration).cost = Battery(b).cost+Chassis(c).cost+Battery_charger(bc).cost;
            Design(iteration).Battery_charge_time = Battery(b).capacity/Battery_charger(bc).power;  
            Design(iteration).valid = 1;% simpe idea how to select dasigns ?
            Design(iteration).Battery_charge_time
            iteration=iteration+1;
        end
    end
end

