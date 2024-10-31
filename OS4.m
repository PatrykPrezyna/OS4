run('Data.m')
run("Constants.m")


%Functions
% Calculate availability

%Apply constraints
% I not sure how/where in the code to skip this designs that do not
% fullfiled the constraints


%road vehicle design generation
iteration=1;
for b=1:length(Battery)
    for c=1:length(Chassis)
        for bc=1:length(Battery_charger)
            for a=1:length(Autonomous_system)
                for m=1:length(Motor)
                    %Cost
                    Design(iteration).cost = Battery(b).cost+Chassis(c).cost+Battery_charger(bc).cost+Autonomous_system(a).cost+Motor(m).cost;
                    %SAU Availability
                    Design(iteration).Battery_charge_time = Battery(b).capacity/Battery_charger(bc).power;  
                    Design(iteration).Total_weight = Battery(b).weight+Chassis(c).weight+Battery_charger(bc).weight+Autonomous_system(a).weight+Chassis(c).pax*PASSENGERS_WEIGHT*Motor(m).weight;
                    Design(iteration).Power_consumption = Chassis(c).power_consumption + 0.1*(Design(iteration).Total_weight-Chassis(c).weight) + Autonomous_system(a).power_consumption;
                    Design(iteration).Range = Battery(b).capacity/Design(iteration).Power_consumption;
                    Design(iteration).Average_speed = 700 * Motor(m).power/Design(iteration).Total_weight;
                    if Design(iteration).Average_speed > SPEED_LIMIT
                        Design(iteration).Average_speed = SPEED_LIMIT;
                    end
                    Design(iteration).Up_time=Design(iteration).Range/Design(iteration).Average_speed;
                    Design(iteration).Bettery_charge_time=Battery(b).capacity*Battery_charger(bc).power;
                    Design(iteration).Down_time=Design(iteration).Bettery_charge_time+25;
                    Design(iteration).Availability=Design(iteration).Up_time/(Design(iteration).Up_time+Design(iteration).Down_time);
                    %SAU Passenger trips/hour
                    %SAU Passenger trips/day
                    %SAU Average waiting time
                    %Additional attributes
                    Design(iteration).autonomy_level = Autonomous_system(a).level;
                    %Validity check
                    Design(iteration).valid = 1;% simpe idea how to select dasigns ?
                    if Battery(b).weight > Chassis(c).weight/3
                        Design(iteration).valid = 0;
                    end
                    
                    iteration=iteration+1;
                end
            end
        end
    end
end

%Calculate SAU 
SAU_availability = 1;