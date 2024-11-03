
% Sigle vehicle, SAU Availability
pareto_nr = [1];
pareto_utility = [0];
pareto_cost = [1000000000];

for i=1:length(Design)
    x(i) = Design(i).cost;
    %y(i) = Design(i).SAU_availability;
    %topic = "SAU_availability"
    y(i) = Design(i).SAU_Peak_Passenger_Throughput;
    topic = "SAU_Peak_Passenger_Throughput: ";

    
    %design is dominated
    dominated = 0;
    for j=1:length(pareto_nr)
        if y(i)<pareto_utility(j)
            if x(i) > pareto_cost(j)
                dominated = 1;
            end
        end
    end
    %design dominats
    for j=1:length(pareto_nr)
        if y(i)>pareto_utility(j)
            if x(i) <= pareto_cost(j)
                pareto_nr(j)=i;
                pareto_utility(j)=y(i);
                pareto_cost(j)=x(i);
                dominated == 1;
            end
        end
    end
    if dominated == 0
        pareto_nr = cat(1, pareto_nr, i);
        pareto_utility = cat(1,pareto_utility, y(i));
        pareto_cost = cat(1, pareto_cost, x(i));

    end


    %Design variable
    color(1,i)=Design(i).Battery_capacity;
    Design_variable_names = "Battery capacity";
    color(2,i)= Design(i).Chassis_pax;
    Design_variable_names = cat(1, Design_variable_names, ["Chassis_pax"]);
    color(3,i)=Design(i).Battery_charger_power;
    Design_variable_names = cat(1, Design_variable_names, ["Battery_charger_power"]);
    color(4,i)=Design(i).autonomy_level;
    Design_variable_names = cat(1, Design_variable_names, ["Authonomy Level"]);
    color(5,i)=Design(i).Motor_power;
    Design_variable_names = cat(1, Design_variable_names, ["Motor_power"]);
    color(6,i)=Design(i).Number_of_vehicles;
    Design_variable_names = cat(1, Design_variable_names, ["Number_of_vehicles"]);
end
 size=zeros(length(color),1)+20;
 shape=[];
    for k =1:length(length(color))
        shape = cat(1,shape, 'o');
    end
 %shape=zeros(length(color),1)+20;
 for i=pareto_nr
     size(pareto_nr)=160;
     shape(pareto_nr)='o';
 end

%SAU Fleet Figure
for i=1:6
    figure
    %idea for more plots on one figures
    % t = tiledlayout(2,2);
    % nexttile
    scatter(x,y, size, color(i,:), shape);

    c = colorbar; 
    
    %Tickst are not working yet
    %c.Ticks = [50000 190000 600000];
    %unit = '[kWh]';
    % cellArray = cell(1, 3);
    % cellArray{1} = '50000\[kW]';
    % cellArray{2} = '190000\[kW]';
    % cellArray{3} = '600000\[kW]';
    % c.TickLabels = cellArray;
    %c.TickLabels = {'50000\[kW]','190000\[kW]','600000\[kW]'};
    
    colormap(jet);
    xlabel('Vehicle Cost [$]');
    ylim([0 1]);
    ylabel('Utility');
    ylabel(colorbar,Design_variable_names(i));
    %topic = 'One vehicle Availability: ';
    title(append(topic, Design_variable_names(i)));
end


%idea for more plots on one figures
% nexttile
% scatter(x,y, 20, color);

j=0;
unique_pareto = unique(pareto_nr)
for i=1:length(unique_pareto)
    Design(unique_pareto(i))
end