clear
%run('Data.m')
run('Data_min_max.m')
run("Constants.m")



%design generation
iteration=1;
Number_of_vehicles = [10 20 30];
Number_of_bikes = [0];

skip_bikes = 0; 
for bk=1:length(Number_of_bikes)
    if Number_of_bikes(bk) == 0 %very simply way to allow for generation of vehicle only designs
        bk_b_i=1;
        bk_f_i=1;
        bk_bc_i=1;
        bk_m_i=1;
    else
        bk_b_i=length(Battery_EB);
        bk_f_i=length(Frame_EB);
        bk_bc_i=length(Battery_charger_EB);
        bk_m_i=length(Motor_EB);
    end
    for bk_b=1:bk_b_i
        for bk_f=1:bk_f_i
            for bk_bc=1:bk_bc_i
                for bk_m=1:bk_m_i
                    for d=1:length(Number_of_vehicles)
                            skip = 0; 
                            for b=1:length(Battery)
                                for c=1:length(Chassis)
                                    for bc=1:length(Battery_charger)
                                        for a=1:length(Autonomous_system)
                                            for m=1:length(Motor)
                                                if skip == 0
                                                    %Main indentification for each design variable
                                                    Design(iteration).Number_of_vehicles = Number_of_vehicles(d);
                                                    Design(iteration).Number_of_bikes = Number_of_bikes(bk);
            
                                                    Design(iteration).Battery_capacity = Battery(b).capacity;
                                                    Design(iteration).Battery_capacity_EB = Battery_EB(bk_b).capacity;
            
                                                    Design(iteration).Chassis_pax = Chassis(c).pax;
                                                    Design(iteration).Frame_weight_EB = Frame_EB(bk_f).weight;
            
                                                    Design(iteration).Battery_charger_power = Battery_charger(bc).power;
                                                    Design(iteration).Battery_charger_power_EB = Battery_charger_EB(bk_bc).power;
            
                                                    Design(iteration).Autonomous_system_level = Autonomous_system(a).level;
            
                                                    Design(iteration).Motor_power = Motor(m).power;
                                                    Design(iteration).Motor_power_EB = Motor_EB(bk_m).power;
                        
                        
                                                    %Cost
                                                    Design(iteration).cost_vehicles = (Battery(b).cost+Chassis(c).cost+Battery_charger(bc).cost+Autonomous_system(a).cost+Motor(m).cost)*Number_of_vehicles(d);
                                                    Design(iteration).cost_bikes = (Battery_EB(bk_b).cost+Frame_EB(bk_f).cost+Battery_charger_EB(bk_bc).cost+Motor_EB(bk_m).cost)*Design(iteration).Number_of_bikes;
                                                    Design(iteration).cost = Design(iteration).cost_vehicles + Design(iteration).cost_bikes;
                        
                        
                                                    %SAU Availability
                                                    Design(iteration).Battery_charge_time = Battery(b).capacity/Battery_charger(bc).power; 
                                                    Design(iteration).Battery_charge_time_EB = Battery_EB(bk_b).capacity/Battery_charger_EB(bk_bc).power;
        
                                                    Design(iteration).Total_weight = Battery(b).weight+Chassis(c).weight+Battery_charger(bc).weight+Autonomous_system(a).weight+(Chassis(c).pax*PASSENGERS_WEIGHT*0.75)+Motor(m).weight;
                                                    Design(iteration).Total_weight_EB = Battery_EB(bk_b).weight+Frame_EB(bk_f).weight+Battery_charger_EB(bk_bc).weight+(Frame_EB(bk_f).pax*PASSENGERS_WEIGHT*0.75)+Motor_EB(bk_m).weight;

                                                    Design(iteration).Power_consumption = Chassis(c).power_consumption + 0.1*(Design(iteration).Total_weight-Chassis(c).weight) + Autonomous_system(a).power_consumption;
                                                    Design(iteration).Power_consumption_EB = Frame_EB(bk_f).power_consumption + 0.1*(Design(iteration).Total_weight_EB-Frame_EB(bk_f).weight);
        
                                                    Design(iteration).Range = Battery(b).capacity/Design(iteration).Power_consumption;
                                                    Design(iteration).Range_EB = Battery_EB(bk_b).capacity/Design(iteration).Power_consumption_EB;
        
                                                    Design(iteration).Average_speed = 700 * Motor(m).power/1000/Design(iteration).Total_weight;
                                                    if Design(iteration).Average_speed > SPEED_LIMIT
                                                        Design(iteration).Average_speed = SPEED_LIMIT;
                                                    end
                                                    Design(iteration).Average_speed_EB = 700 * Motor_EB(bk_m).power/1000/Design(iteration).Total_weight_EB;
                                                    if Design(iteration).Average_speed_EB > SPEED_LIMIT
                                                        Design(iteration).Average_speed_EB = SPEED_LIMIT;
                                                    end
        
        
                                                    Design(iteration).Up_time=Design(iteration).Range/Design(iteration).Average_speed;
                                                    Design(iteration).Up_time_EB=Design(iteration).Range_EB/Design(iteration).Average_speed_EB;
        
                                                    Design(iteration).Down_time=Design(iteration).Battery_charge_time+0.25;
                                                    Design(iteration).Down_time_EB=Design(iteration).Battery_charge_time_EB+0.25;
        
        
                                                    Design(iteration).Availability=Design(iteration).Up_time/(Design(iteration).Up_time+Design(iteration).Down_time);
                                                    Design(iteration).Availability_EB=Design(iteration).Up_time_EB/(Design(iteration).Up_time_EB+Design(iteration).Down_time_EB);
                                                    
                                                    if Number_of_bikes(bk) == 0
                                                        Design(iteration).Availability_Average = Design(iteration).Availability; 
                                                    elseif Number_of_vehicles(d) ==0
                                                        Design(iteration).Availability_Average = Design(iteration).Availability_EB; 
                                                    else
                                                        Design(iteration).Availability_Average = (Design(iteration).Availability*Design(iteration).Number_of_vehicles + Design(iteration).Availability_EB*Design(iteration).Number_of_bikes)/(Design(iteration).Number_of_vehicles+Design(iteration).Number_of_bikes);
                                                    end

                                                    Design(iteration).SAU_availability = SAU_Availability(Design(iteration).Availability_Average);
                                                    %SAU Passenger trips/hour
                                                    Design(iteration).loop_time = NUMBER_OF_STOPS*(DWELL_TIME+(DISTANCE_BETWEEN_STOPS/Design(iteration).Average_speed));
                                                    Design(iteration).loop_time_EB = NUMBER_OF_STOPS*(DWELL_TIME+(DISTANCE_BETWEEN_STOPS/Design(iteration).Average_speed_EB));
        
                                                    Design(iteration).Peak_Passenger_Throughput  = (Chassis(c).pax*Number_of_vehicles(d)*Design(iteration).Availability)/Design(iteration).loop_time; 
                                                    Design(iteration).Peak_Passenger_Throughput_EB  = (Frame_EB(bk_f).pax*Design(iteration).Number_of_bikes*Design(iteration).Availability_EB)/Design(iteration).loop_time_EB;
                                                    Design(iteration).Peak_Passenger_Throughput_combined = Design(iteration).Peak_Passenger_Throughput+Design(iteration).Peak_Passenger_Throughput_EB;
        
                                                    Design(iteration).SAU_Peak_Passenger_Throughput= SAU_Peak(Design(iteration).Peak_Passenger_Throughput_combined);
                                                    %SAU Passenger trips/day
                                                    Design(iteration).Passenger_Volume = (Design(iteration).Peak_Passenger_Throughput_combined)*OPERATING_HOURS;
                                                    Design(iteration).SAU_Passenger_Volume = SAU_Volume(Design(iteration).Passenger_Volume);
                                                    %SAU Average waiting time
                                                    Design(iteration).Wait_Time=Design(iteration).Peak_Passenger_Throughput_combined/2;
                                                    Design(iteration).SAU_Wait_Time = SAU_Wait(Design(iteration).Wait_Time);
                                                    %Additional attributes
                                                    Design(iteration).autonomy_level = Autonomous_system(a).level;
                                                    %Validity check
                                                    Design(iteration).valid = 1;% simple idea how to select dasigns ?
                                                    if Battery(b).weight > Chassis(c).weight/3
                                                        Design(iteration).valid = 0;
                                                    end
                                                    %MAU
                                                    Design(iteration).MAU = MAU_value(Design(iteration).SAU_availability,Design(iteration).SAU_Peak_Passenger_Throughput,Design(iteration).SAU_Passenger_Volume,Design(iteration).SAU_Wait_Time);
                                                    iteration=iteration+1;
                                                    if Number_of_vehicles(d) == 0
                                                        skip = 1
                                                    end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
