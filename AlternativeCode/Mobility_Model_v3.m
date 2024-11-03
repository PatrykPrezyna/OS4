clc
clear
close all

%% Constants %%

%Provided%
pax_weight=100;             %[kg] Average passenger weight
avail_comp=0.75;            % Availability of competing transportation systems
factor_weight_power=0.1;    %[Wh/(km*kg)] Weight power consumption factor
efficiency_drivetrain=700;  %[(km*kg)/kWh] Drivetrain efficiency
speed_limit=40.2;           %[km/h] Speed limit of area
dwell=60;                   %[s] Dwell time at each stop
factor_load=0.75;           % Average Load Factor per Trip
down_time=0.25;             %[hr] Down time buffer period

%Requirements
req_volume=1500;            %[passenger trips/day] L0 requirement - Daily Passenger Volume
req_peak_throughput=150;    %[passenger trips/hour] L0 requirement - Peak Passenger Throughput
req_off_throughput=50;      %[passenger trips/hour] L0 requirement - Off-Peak Passenger Throughput
max_wait_within=5;          %[mins] L0 requirement - Max wait time within boundary
max_wait_outside=20;         %[mins] L0 requirement - Max wait time outside of boundary
max_travel=7;               %[mins] L0 requirement - Max travel time across boundary

%% Inputs %%
%Fleet Variables
RV_count=[1 5 10 25 50];
EB_count=[1 25 50 75 100];

%Operational Inputs
operating_hours=24;         %[hr] Number of operating hours per day
max_dist=3.9;                 %[km] Max distance within system boundary 
avg_trip=3.5;                   %[km] Average RV travel distance

%% DESIGN OPTIONS FOR THE ROAD VEHICLE (RV) %%
%Battery Options%
%column1=option column2=capacity[kWh] column3=cost[$1000] column4=weight[kg]
P1=[1 50 6 110];
P2=[2 100 11 220];
P3=[3 150 15 340];
P4=[4 190 19 450];
P5=[5 250 25 570];
P6=[6 310 30 680];
P7=[7 600 57 1400];
RV_Battery=[P1;P2;P3;P4;P5;P6;P7];

%Chassis Options%
%column1=option column2=pax column3=weight[kg] column4=cost[$1000]
%column5=nominal power concumption[Wh/km]
C1=[1 2 1350 12 140];
C2=[2 4 1600 17 135];
C3=[3 6 1800 21 145];
C4=[4 8 2000 29 150];
C5=[5 10 2200 31 160];
C6=[6 16 2500 33 165];
C7=[7 20 4000 38 180];
C8=[8 30 7000 47 210];
RV_Chassis=[C1;C2;C3;C4;C5;C6;C7;C8];

%Charger Options%
%column1=power[kW] column2=cost[$1000] column3=weight[kg]
G1=[1 10 1 1];
G2=[2 20 2.5 1.8];
G3=[3 60 7 5];
RV_Charger=[G1;G2;G3];

%Motor & Inverter Options%
%column1=option column2=weight[kg] column3=power[kW] column4=cost[$]
M1=[1 35 50 4200];
M2=[2 80 100 9800];
M3=[3 110 210 13650];
M4=[4 200 350 20600];
RV_MotorInv=[M1;M2;M3;M4];

%SAE Autonomy Level Options%
%column1=option column2=weight[kg] column3=added power consumption[Wh/km] column4=cost[$1000]
SAE_A3=[1 30 1.5 15];
SAE_A4=[2 60 2.5 35];
SAE_A5=[3 120 5 60];
RV_SAE=[SAE_A3;SAE_A4;SAE_A5];

%% DESIGN OPTIONS FOR THE ELECTRIC BICYCLE (EB) %%

%Battery Options%
%column1=option column2=capacity[kWh] column3=cost[$1000] column4=weight[kg]
E1=[1 0.5 0.6 5];
E2=[2 1.5 1.5 11];
E3=[3 3 2.6 17];
EB_Battery=[E1;E2;E3];

%Frame Options%
%column1=option column2=pax column3=weight[kg] column4=cost[$1000]
%column5=nominal power consumption[Wh/km]
B1=[1 1 20 2 30];
B2=[2 1 17 3 25];
B3=[3 2 35 3.5 40];
EB_Frame=[B1;B2;B3];

%Charger Options%
%column1=option column2=power[kW] column3=cost[$1000] column4=weight[kg]
EB_G1=[1 0.2 0.3 0.5];
EB_G2=[2 0.6 0.5 1.2];
EB_Charger=[EB_G1;EB_G2];

%Motor & Inverter Options%
%column1=option column2=weight[kg] column3=power[kW] column4=cost[$]
K1=[1 5 0.35 300];
K2=[2 4 0.5 400];
K3=[3 7 1.5 600];
EB_MotorInv=[K1;K2;K3];

%% Architecture Combinations %%
%Number of options for each RV decision
RV_Battery_row=RV_Battery(:,1)';
RV_Charger_row=RV_Charger(:,1)';
RV_Chassis_row=RV_Chassis(:,1)';
RV_MotorInv_row=RV_MotorInv(:,1)';
RV_SAE_row=RV_SAE(:,1)';

%Number of options for each EB decision
EB_Battery_row=EB_Battery(:,1)';
EB_Charger_row=EB_Charger(:,1)';
EB_Frame_row=EB_Frame(:,1)';
EB_MotorInv_row=EB_MotorInv(:,1)';

%Matrix of All Fleet Combinations
[A,B,C,D,E,F,G,H,I,J,K]=ndgrid(RV_Battery_row,RV_Charger_row,RV_Chassis_row,RV_MotorInv_row,RV_SAE_row,RV_count,EB_Battery_row,EB_Charger_row,EB_Frame_row,EB_MotorInv_row,EB_count);
combos_fleet=[A(:),B(:),C(:),D(:),E(:),F(:),G(:),H(:),I(:),J(:),K(:)];

%% Architecture Outputs %%

%Fleet Architecture Outputs
options_fleet=size(combos_fleet,2);
outputs_fleet=zeros(size(combos_fleet,1),113);
for i=1:size(combos_fleet,1)
    for j=1:options_fleet
        outputs_fleet(i,j)=combos_fleet(i,j);
    end
    %% RV Calculations %%
    for k=12:14
        lookup=outputs_fleet(i,1);
        index=find(RV_Battery(:,1)==lookup);
        outputs_fleet(i,k)=RV_Battery(index,k-10);
    end
    
    for L=15:17
        lookup=outputs_fleet(i,2);
        index=find(RV_Charger(:,1)==lookup);
        outputs_fleet(i,L)=RV_Charger(index,L-13);
    end
    
    for m=18:21
        lookup=outputs_fleet(i,3);
        index=find(RV_Chassis(:,1)==lookup);
        outputs_fleet(i,m)=RV_Chassis(index,m-16);
    end
    
    for n=22:24
        lookup=outputs_fleet(i,4);
        index=find(RV_MotorInv(:,1)==lookup);
        outputs_fleet(i,n)=RV_MotorInv(index,n-20);
    end
    
    for o=25:27
        lookup=outputs_fleet(i,5);
        index=find(RV_SAE(:,1)==lookup);
        outputs_fleet(i,o)=RV_SAE(index,o-23);
    end
    
    %Total Vehicle Cost Calculation
    outputs_fleet(i,28)=(outputs_fleet(i,13)*1000)+(outputs_fleet(i,16)*1000)+(outputs_fleet(i,20)*1000)+outputs_fleet(i,24)+(outputs_fleet(i,27)*1000);
    
    %Total Fleet Cost Calculation
    outputs_fleet(i,29)=outputs_fleet(i,28)*outputs_fleet(i,6);
    
    %Total Passenger Weight Calculation
    outputs_fleet(i,30)=factor_load*outputs_fleet(i,18)*pax_weight;
    
    %Total Vehicle Weight Calculation
    outputs_fleet(i,31)=outputs_fleet(i,14)+outputs_fleet(i,17)+outputs_fleet(i,19)+outputs_fleet(i,22)+outputs_fleet(i,25)+outputs_fleet(i,30);
    
    %Battery Weight Percentage
    outputs_fleet(i,32)=100*(outputs_fleet(i,14)/outputs_fleet(i,31));
    
    %Weight Percentage Validation
    if outputs_fleet(i,32)>(100/3)
        outputs_fleet(i,33)=0;
    else
        outputs_fleet(i,33)=1;
    end
    
    %Battery Charge Time Calculation
    outputs_fleet(i,34)=outputs_fleet(i,12)/outputs_fleet(i,15);
    
    %Total Power Consumption Calculation
    outputs_fleet(i,35)=outputs_fleet(i,21)+outputs_fleet(i,26)+(factor_weight_power*(outputs_fleet(i,31)-outputs_fleet(i,19)));
    
    %Range Calculation
    outputs_fleet(i,36)=1000*(outputs_fleet(i,12)/outputs_fleet(i,35));
    
    %Potential Average Speed Calculation
    outputs_fleet(i,37)=efficiency_drivetrain*(outputs_fleet(i,23)/outputs_fleet(i,31));
    
    %Speed Limit Compliance Check
    if outputs_fleet(i,37)>speed_limit
        outputs_fleet(i,38)=0;
    else
        outputs_fleet(i,38)=1;
    end
    
    %Actual Average Speed Calculation
    if outputs_fleet(i,38)==0
        outputs_fleet(i,39)=speed_limit;
    else
        outputs_fleet(i,39)=outputs_fleet(i,37);
    end
    
    %Up-Time Calculation
    outputs_fleet(i,40)=outputs_fleet(i,36)/outputs_fleet(i,39);
    
    %Down-Time Calculation
    outputs_fleet(i,41)=outputs_fleet(i,34)+down_time;
    
    %Availability Calculation
    outputs_fleet(i,42)=outputs_fleet(i,40)/(outputs_fleet(i,40)+outputs_fleet(i,41));
      
    
    %% EB Calcuations %%
    for j=43:45
        lookup=outputs_fleet(i,7);
        index=find(EB_Battery(:,1)==lookup);
        outputs_fleet(i,j)=EB_Battery(index,j-41);
    end
    
    for k=46:48
        lookup=outputs_fleet(i,8);
        index=find(EB_Charger(:,1)==lookup);
        outputs_fleet(i,k)=EB_Charger(index,k-44);
    end
    
    for L=49:52
        lookup=outputs_fleet(i,9);
        index=find(EB_Frame(:,1)==lookup);
        outputs_fleet(i,L)=EB_Frame(index,L-47);
    end
    
    for m=53:55
        lookup=outputs_fleet(i,10);
        index=find(EB_MotorInv(:,1)==lookup);
        outputs_fleet(i,m)=EB_MotorInv(index,m-51);
    end
    
    %Total Vehicle Cost Calculation
    outputs_fleet(i,56)=(outputs_fleet(i,44)*1000)+(outputs_fleet(i,47)*1000)+(outputs_fleet(i,51)*1000)+outputs_fleet(i,55);
    
    %Total Fleet Cost Calculation
    outputs_fleet(i,57)=outputs_fleet(i,56)*outputs_fleet(i,11);
    
    %Total Passenger Weight Calculation
    outputs_fleet(i,58)=factor_load*outputs_fleet(i,49)*pax_weight;
    
    %Total Vehicle Weight Calculation
    outputs_fleet(i,59)=outputs_fleet(i,45)+outputs_fleet(i,48)+outputs_fleet(i,50)+outputs_fleet(i,53)+outputs_fleet(i,58);
    
    %Battery Weight Percentage
    outputs_fleet(i,60)=100*(outputs_fleet(i,45)/outputs_fleet(i,59));
    
    %Weight Percentage Validation
    if outputs_fleet(i,60)>(100/3)
        outputs_fleet(i,61)=0;
    else
        outputs_fleet(i,61)=1;
    end
    
    %Battery Charge Time Calculation
    outputs_fleet(i,62)=outputs_fleet(i,43)/outputs_fleet(i,46);
    
    %Total Power Consumption Calculation
    outputs_fleet(i,63)=outputs_fleet(i,52)+(factor_weight_power*(outputs_fleet(i,59)-outputs_fleet(i,50)));
    
    %Range Calculation
    outputs_fleet(i,64)=1000*(outputs_fleet(i,43)/outputs_fleet(i,63));
    
    %Potential Average Speed Calculation
    outputs_fleet(i,65)=efficiency_drivetrain*(outputs_fleet(i,54)/outputs_fleet(i,59));
    
    %Speed Limit Compliance Check
    if outputs_fleet(i,65)>speed_limit
        outputs_fleet(i,66)=0;
    else
        outputs_fleet(i,66)=1;
    end
    
    %Actual Average Speed Calculation
    if outputs_fleet(i,66)==0
        outputs_fleet(i,67)=speed_limit;
    else
        outputs_fleet(i,67)=outputs_fleet(i,65);
    end
    
    %Up-Time Calculation
    outputs_fleet(i,68)=outputs_fleet(i,64)/outputs_fleet(i,67);
    
    %Down-Time Calculation
    outputs_fleet(i,69)=outputs_fleet(i,62)+down_time;
    
    %Availability Calculation
    outputs_fleet(i,70)=outputs_fleet(i,68)/(outputs_fleet(i,68)+outputs_fleet(i,69));
    
    %% Fleet Calculations %%
    %Baseline RV v Competition Comparison
    if outputs_fleet(i,42)<avail_comp
        outputs_fleet(i,71)=0;
    else
        outputs_fleet(i,71)=1;
    end
    
    %Baseline EB v Competition Comparison
    if outputs_fleet(i,70)<avail_comp
        outputs_fleet(i,72)=0;
    else
        outputs_fleet(i,72)=1;
    end
    
    %RV Fleet Availability
    
    
end

outputs_fleet_unfiltered=outputs_fleet;

%% Remove Non-compliant Architectures %%
%Battery Weight RV%
valuetodelete=0;
columindex=33;
rowstodelete_RV_Bat=outputs_fleet(:,columindex)==valuetodelete;
outputs_fleet(rowstodelete_RV_Bat,:)=[];

outputs_fleet_RV_Bat=outputs_fleet;

%Battery Weight EB%
valuetodelete=0;
columindex=61;
rowstodelete_EB_Bat=outputs_fleet(:,columindex)==valuetodelete;
outputs_fleet(rowstodelete_EB_Bat,:)=[];

outputs_fleet_EB_Bat=outputs_fleet;

% %Availability RV
% valuetodelete=0;
% columindex=71;
% rowstodelete_RV_Avail=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_RV_Avail,:)=[];
% 
% outputs_fleet_RV_Avail=outputs_fleet;
% 
% %Availability EB
% valuetodelete=0;
% columindex=72;
% rowstodelete_EB_Avail=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_EB_Avail,:)=[];
% 
% outputs_fleet_EB_Avail=outputs_fleet;

for i=1:size(outputs_fleet,1)
    %Time to get across boundary for RV
    outputs_fleet(i,73)=max_dist/outputs_fleet(i,39);
    %Time to get across boundary for EB
    outputs_fleet(i,74)=max_dist/outputs_fleet(i,67);
    
    if outputs_fleet(i,73)>(max_travel/60)
        outputs_fleet(i,75)=0;
    else
        outputs_fleet(i,75)=1;
    end
    
    if outputs_fleet(i,74)>(max_travel/60)
        outputs_fleet(i,76)=0;
    else
        outputs_fleet(i,76)=1;
    end
end

% %Max Time RV
% valuetodelete=0;
% columindex=75;
% rowstodelete_RV_MaxT=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_RV_MaxT,:)=[];
% 
% outputs_fleet_RV_Time=outputs_fleet;

% %Max Travel Time EB
% valuetodelete=0;
% columindex=76;
% rowstodelete_EB_MaxTT=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_EB_MaxTT,:)=[];
% 
% outputs_fleet_EB_Time=outputs_fleet;
% 
% %Remove Max Travel Time EB Filter
% outputs_fleet=outputs_fleet_RV_Time;

for i=1:size(outputs_fleet,1)
    %Individual RV Headway
    % outputs_fleet(i,77)=((route_length_RV/outputs_fleet(i,39))+(stops_RV*dwell*(1/3600)))/stops_RV;
    outputs_fleet(i,77)=(avg_trip/outputs_fleet(i,39))+(dwell*(1/3600));
    
    %Fleet RV Ideal Headway (minimum)
    outputs_fleet(i,78)=outputs_fleet(i,77)/outputs_fleet(i,6);

    %Fleet RV Average Headway
    outputs_fleet(i,79)=outputs_fleet(i,77)/(outputs_fleet(i,6)*outputs_fleet(i,42));
    
    %Average RV Wait Time
    outputs_fleet(i,80)=outputs_fleet(i,79)/2;

    %Peak RV Passenger Throughput
    outputs_fleet(i,81)=(1/outputs_fleet(i,78))*outputs_fleet(i,18);

    %Daily RV Passenger Volume
    outputs_fleet(i,82)=operating_hours*outputs_fleet(i,81)*outputs_fleet(i,42);

    %Individaul EB Headway
    % outputs_fleet(i,83)=((route_length_EB/outputs_fleet(i,67))+(stops_EB*dwell*(1/3600)))/stops_EB;
    outputs_fleet(i,83)=(avg_trip/outputs_fleet(i,67))+(dwell*(1/3600));

    %Fleet EB Ideal Headway (minimum)
    outputs_fleet(i,84)=outputs_fleet(i,83)/outputs_fleet(i,11);

    %Fleet EB Average Headway
    outputs_fleet(i,85)=outputs_fleet(i,83)/(outputs_fleet(i,11)*outputs_fleet(i,70));

    %Average EB Wait Time
    outputs_fleet(i,86)=outputs_fleet(i,85)/2;

    %Peak EB Passenger Throughput
    outputs_fleet(i,87)=(1/outputs_fleet(i,84))*outputs_fleet(i,49);

    %Daily EB Passenger Volume
    outputs_fleet(i,88)=operating_hours*outputs_fleet(i,87)*outputs_fleet(i,70);

    %Fleet Peak Passenger Throughput
    outputs_fleet(i,89)=outputs_fleet(i,81)+outputs_fleet(i,87);
    
    %Fleet Passenger Volume
    outputs_fleet(i,90)=outputs_fleet(i,82)+outputs_fleet(i,88);


    %RV v L0 Req Wait Time
    if outputs_fleet(i,80)>(max_wait_within/60)
        outputs_fleet(i,91)=0;
    else
        outputs_fleet(i,91)=1;
    end

    %EB v L0 Req Wait Time
    if outputs_fleet(i,86)>(max_wait_within/60)
        outputs_fleet(i,92)=0;
    else
        outputs_fleet(i,92)=1;
    end
    
    %Fleet v L0 Passenger Volume
    if outputs_fleet(i,90)>req_volume
        outputs_fleet(i,93)=1;
    else
        outputs_fleet(i,93)=0;
    end

    %Fleet v L0 Off-Peak Passenger Throughput
    if outputs_fleet(i,89)>req_off_throughput
        outputs_fleet(i,94)=1;
    else
        outputs_fleet(i,94)=0;
    end

    %Fleet v L0 Peak Passenger Throughput
    if outputs_fleet(i,89)>req_peak_throughput
        outputs_fleet(i,95)=1;
    else
        outputs_fleet(i,95)=0;
    end


end

% %Wait Time RV
% valuetodelete=0;
% columindex=91;
% rowstodelete_RV_Wait=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_RV_Wait,:)=[];
% 
% outputs_fleet_RV_Wait=outputs_fleet;
% 
% %Wait Time EB
% valuetodelete=0;
% columindex=92;
% rowstodelete_EB_Wait=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_EB_Wait,:)=[];
% 
% outputs_fleet_EB_Wait=outputs_fleet;

% %Passenger Volume
% valuetodelete=0;
% columindex=93;
% rowstodelete_vol=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_vol,:)=[];
% 
% outputs_fleet_vol=outputs_fleet;
% 
% %Off Peak Throughput
% valuetodelete=0;
% columindex=94;
% rowstodelete_off=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_off,:)=[];
% 
% outputs_fleet_off=outputs_fleet;
% 
% %Peak Throughput
% valuetodelete=0;
% columindex=95;
% rowstodelete_peak=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_peak,:)=[];
% 
% outputs_fleet_peak=outputs_fleet;


for i=1:size(outputs_fleet,1)
    %Fleet Wait Time
    outputs_fleet(i,96)=((outputs_fleet(i,6)/(outputs_fleet(i,6)+outputs_fleet(i,11)))*outputs_fleet(i,80)+(outputs_fleet(i,11)/(outputs_fleet(i,6)+outputs_fleet(i,11)))*outputs_fleet(i,86));

    %Fleet Availability
    outputs_fleet(i,97)=((outputs_fleet(i,6)/(outputs_fleet(i,6)+outputs_fleet(i,11)))*outputs_fleet(i,42)+(outputs_fleet(i,11)/(outputs_fleet(i,6)+outputs_fleet(i,11)))*outputs_fleet(i,70));
   
    %SAU RV Passenger Volume
    outputs_fleet(i,98)=SAU_Volume(outputs_fleet(i,82));
    
    %SAU RV Peak Throughput
    outputs_fleet(i,99)=SAU_Peak(outputs_fleet(i,81));
    
    %SAU RV Wait Time
    outputs_fleet(i,100)=SAU_Wait(outputs_fleet(i,80));
    
    %SAU RV Availability
    outputs_fleet(i,101)=SAU_Avail(outputs_fleet(i,42));
    
    %MAU RV
    outputs_fleet(i,102)=MAU(outputs_fleet(i,101),outputs_fleet(i,100),outputs_fleet(i,98),outputs_fleet(i,99));
    
    %SAU EB Passenger Volume
    outputs_fleet(i,103)=SAU_Volume(outputs_fleet(i,88));
    
    %SAU EB Peak Throughput
    outputs_fleet(i,104)=SAU_Peak(outputs_fleet(i,87));
    
    %SAU EB Wait Time
    outputs_fleet(i,105)=SAU_Wait(outputs_fleet(i,86));
    
    %SAU EB Availability
    outputs_fleet(i,106)=SAU_Avail(outputs_fleet(i,70));
    
    %MAU EB
    outputs_fleet(i,107)=MAU(outputs_fleet(i,106),outputs_fleet(i,105),outputs_fleet(i,103),outputs_fleet(i,104));
    
    %SAU Fleet Passenger Volume
    outputs_fleet(i,108)=SAU_Volume(outputs_fleet(i,90));
    
    %SAU Fleet Peak Throughput
    outputs_fleet(i,109)=SAU_Peak(outputs_fleet(i,89));
    
    %SAU Fleet Wait Time
    outputs_fleet(i,110)=SAU_Wait(outputs_fleet(i,96));
    
    %SAU Fleet Availability
    outputs_fleet(i,111)=SAU_Avail(outputs_fleet(i,97));
    
    %MAU Fleet
    outputs_fleet(i,112)=MAU(outputs_fleet(i,111),outputs_fleet(i,110),outputs_fleet(i,108),outputs_fleet(i,109));
    
    %Total Fleet Cost
    outputs_fleet(i,113)=outputs_fleet(i,29)+outputs_fleet(i,57);
    
%     %Fleet Composition
%     if outputs_fleet(i,6)==0 && outputs_fleet(i,11)==0
%         outputs_fleet(i,106)=0;
%     else
%         outputs_fleet(i,106)=100*(outputs_fleet(i,6)/(outputs_fleet(i,6)+outputs_fleet(i,11)));
%     end
    
end

% % Utility Filtering %%
% Volume Utility Filter
% valuetodelete=0;
% columindex=104;
% rowstodelete_vol_util=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_vol_util,:)=[];
% 
% outputs_fleet_vol_util=outputs_fleet;

% %Throughput Utility Filter
% valuetodelete=0;
% columindex=105;
% rowstodelete_thru_util=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_thru_util,:)=[];
% 
% outputs_fleet_thru_util=outputs_fleet;
% 
% %Wait Time
% valuetodelete=0;
% columindex=107;
% rowstodelete_wait_util=outputs_fleet(:,columindex)==valuetodelete;
% outputs_fleet(rowstodelete_wait_util,:)=[];
% 
% outputs_fleet_wait_util=outputs_fleet;


%% Plots %%
%MAU RV Fleet Figure - Battery
figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,1);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Battery Option');
title('Kendall Square Road Vehicle Fleet Tradespace [Battery]');

%MAU RV Fleet Figure - Charger
figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,2);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Charger Option');
title('Kendall Square Road Vehicle Fleet Tradespace [Charger]');

%MAU RV Fleet Figure - Chassis
figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,3);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Chassis Option');
title('Kendall Square Road Vehicle Fleet Tradespace [Chassis]');

%MAU RV Fleet Figure - Motor & Inverter
figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,4);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Motor & Inverter Option');
title('Kendall Square Road Vehicle Fleet Tradespace [Motor & Inverter]');

%MAU RV Fleet Figure - SAE Level
figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,5);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Autonomy Level Option');
title('Kendall Square Road Vehicle Fleet Tradespace [SAE Autonomy Level]');

%MAU RV Fleet Figure
x=outputs_fleet(:,102);
y=outputs_fleet(:,29);
colorData=outputs_fleet(:,6);
scatter(x,y,50,colorData,'filled');
% caxis([0 50]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Fleet Size of Road Vehicles');
title('Kendall Square Road Vehicle Fleet Tradespace [Fleet Number]');

%MAU EB Fleet Figure - Battery
figure
x=outputs_fleet(:,107);
y=outputs_fleet(:,57);
colorData=outputs_fleet(:,7);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Battery Option');
title('Kendall Square E-Bike Fleet Tradespace [Battery]');

%MAU EB Fleet Figure - Charger
figure
x=outputs_fleet(:,107);
y=outputs_fleet(:,57);
colorData=outputs_fleet(:,8);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Charger Option');
title('Kendall Square E-Bike Fleet Tradespace [Charger]');

%MAU EB Fleet Figure - Frame
figure
x=outputs_fleet(:,107);
y=outputs_fleet(:,57);
colorData=outputs_fleet(:,9);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Frame Options');
title('Kendall Square E-Bike Fleet Tradespace [Frame]');

%MAU EB Fleet Figure - Motor & Inverter
figure
x=outputs_fleet(:,107);
y=outputs_fleet(:,57);
colorData=outputs_fleet(:,10);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Motor & Inverter Option');
title('Kendall Square E-Bike Fleet Tradespace [Motor & Inverter]');

%MAU EB Fleet Figure - Fleet Count
figure
x=outputs_fleet(:,107);
y=outputs_fleet(:,57);
colorData=outputs_fleet(:,11);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Fleet Size');
title('Kendall Square E-Bike Fleet Tradespace [Fleet Count]');


%MAU Fleet Figure
figure
x=outputs_fleet(:,112);
y=outputs_fleet(:,113);
colorData=outputs_fleet(:,1);
scatter(x,y,50,colorData,'filled');
% caxis([0 100]);
colorbar;
colormap(jet);
xlabel('Utility');
xlim([0 1]);
ylabel('Fleet Cost [$]');
% ylabel(colorbar,'Percent of Fleet that are Road Vehicles');
title('Kendall Square Mixed Fleet Tradespace [E Bike Fleet Number]');

outputs_readable=outputs_fleet;

outputs_readable(:,[1:6 12:102 108:113])=[];
