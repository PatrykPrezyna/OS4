clear
%run('Data.m')
run('Data_min_max.m')
run("Constants.m")



%design generation
iteration=1;
Number_of_vehicles = [1 2 3];
for d=1:length(Number_of_vehicles)
    for b=1:length(Battery)
        for c=1:length(Chassis)
            for bc=1:length(Battery_charger)
                for a=1:length(Autonomous_system)
                    for m=1:length(Motor)
                        %Main indentification for each design variable
                        Design(iteration).Number_of_vehicles = Number_of_vehicles(d);
                        Design(iteration).Battery_capacity = Battery(b).capacity;
                        Design(iteration).Chassis_pax = Chassis(c).pax;
                        Design(iteration).Battery_charger_power = Battery_charger(bc).power;
                        Design(iteration).Autonomous_system_level = Autonomous_system(a).level;
                        Design(iteration).Motor_power = Motor(m).power;
                        %Cost
                        Design(iteration).cost = Battery(b).cost+Chassis(c).cost+Battery_charger(bc).cost+Autonomous_system(a).cost+Motor(m).cost;
                        %SAU Availability
                        Design(iteration).Battery_charge_time = Battery(b).capacity/Battery_charger(bc).power; 
                        Design(iteration).Total_weight = Battery(b).weight+Chassis(c).weight+Battery_charger(bc).weight+Autonomous_system(a).weight+(Chassis(c).pax*PASSENGERS_WEIGHT*0.75)+Motor(m).weight;
                        Design(iteration).Power_consumption = Chassis(c).power_consumption + 0.1*(Design(iteration).Total_weight-Chassis(c).weight) + Autonomous_system(a).power_consumption;
                        Design(iteration).Range = Battery(b).capacity/Design(iteration).Power_consumption;
                        Design(iteration).Average_speed = 700 * Motor(m).power/Design(iteration).Total_weight;
                        if Design(iteration).Average_speed > SPEED_LIMIT
                            Design(iteration).Average_speed = SPEED_LIMIT;
                        end
                        Design(iteration).Up_time=Design(iteration).Range/Design(iteration).Average_speed;
                        Design(iteration).Down_time=Design(iteration).Battery_charge_time+0.25;
                        Design(iteration).Availability=Design(iteration).Up_time/(Design(iteration).Up_time+Design(iteration).Down_time);
                        Design(iteration).Availability;
                        Design(iteration).SAU_availability = SAU_Availability(Design(iteration).Availability);
                        Design(iteration).SAU_availability;
                        %SAU Passenger trips/hour
                        Design(iteration).loop_time = NUMBER_OF_STOPS*(DWELL_TIME+(DISTANCE_BETWEEN_STOPS/Design(iteration).Average_speed));
                        Design(iteration).Peak_Passenger_Throughput  = (Chassis(c).pax*Number_of_vehicles(d)*Design(iteration).Availability)/Design(iteration).loop_time; 
                        Design(iteration).SAU_Peak_Passenger_Throughput= SAU_Peak(Design(iteration).Peak_Passenger_Throughput);
                        %SAU Passenger trips/day
                        Design(iteration).SAU_passenger_trip_day = 1;
                        %SAU Average waiting time
                        Design(iteration).SAU_average_waiting_time = 1;
                        %Additional attributes
                        Design(iteration).autonomy_level = Autonomous_system(a).level;
                        %Validity check
                        Design(iteration).valid = 1;% simple idea how to select dasigns ?
                        if Battery(b).weight > Chassis(c).weight/3
                            Design(iteration).valid = 0;
                        end
                        %MAU
                        Design(iteration).MAU = MAU_value(Design(iteration).SAU_availability,Design(iteration).SAU_Peak_Passenger_Throughput,Design(iteration).SAU_passenger_trip_day,Design(iteration).SAU_average_waiting_time);
                        iteration=iteration+1;
                    end
                end
            end
        end
    end
end