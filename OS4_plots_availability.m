
% Sigle vehicle, SAU Availability
for i=1:length(Design)
    x(i) = Design(i).cost;
    y(i) = Design(i).Availability;
    color(1,i)=Design(i).Battery_capacity;
    design_variable = ["Battery capacity"];
    color(2,i)=Design(i).Chassis_pax;
    design_variable = cat(1, design_variable, ["Chassis_pax"])
    color(3,i)=Design(i).Battery_charger_power;
    design_variable = cat(1, design_variable, ["Battery_charger_power"])
    color(4,i)=Design(i).autonomy_level;
    design_variable = cat(1, design_variable, ["Authonomy Level"])
    color(5,i)=Design(i).Motor_power;
    design_variable = cat(1, design_variable, ["Motor_power"])
end

%SAU Fleet Figure
for i=1:5
    figure
    %idea for more plots on one figures
    % t = tiledlayout(2,2);
    % nexttile
    scatter(x,y, 20, color(i,:));
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
    ylabel(colorbar,design_variable(i));
    topic = 'One vehicle Availability: ';
    title(append(topic, design_variable(i)));
end


%idea for more plots on one figures
% nexttile
% scatter(x,y, 20, color);