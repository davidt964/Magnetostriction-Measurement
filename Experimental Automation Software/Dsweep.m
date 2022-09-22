%{
    - Script Authors: Paymon Shirazi and David L. Tran
    - Description:
        Run this script in the MATLAB Command Window when performing data
        collection. Nothing else needs to be done except monitoring the
        data.
    - Please configure everything according to the setup you are using.
%}

clear all; 
MagChannel = 2; %Hall IC
[MagnetZero,stepVolt] = ZeroMagnet(MagChannel,0.4); %Zero the magnet with step voltage of 0.4 V

%% set file name
filename = "Amor-Td-11-16-600Oe";

%% Measurement Settings

%zero the measurement; uncomment upon initialization
%ZeroSetting();

measureTime = 3;        %measuring time (secs)

%measurement delay (secs)
delayTime = 1;

%maximum field value (V)
vmax = 0.5;

%maximum field value (Oe)
Fmax = 700;

%StepSize (Oe)
StepSize = 20;

%Number of cycles
cycles = 1;

%% Channel Parameters

%channel data Numbers
suppCh = 1; %1, Voltage In
PDch = 3;
fieldCH = 2; %IC sensor


%Max devices on device = 4
suppVolt = 1;
fieldData = 3;
PDdata = 2;


%% Thin films parameters (used for calculations)
tf = 100E-9;                % film thickness in [m]
ts = 100E-6;                % substrate thickness in [m]
Ef = 70;                    % Film's Young Mod (GPa)
Es = 140;                   % Substrates's Young's Mod(GPa)
L = 4E-2;                   % Cantilever length (m)
vf = 0.3;                   % Film Poisson (-)
vs = 0.3;                   % Substrate Poisson (-)


%% DAQ Setup

%setup data vectors
fieldV = [];
distanceV = [];
suppV = [];
time = [];
distanceppm = [];

%Photodiode Vectors
delP = [];


fpos = linspace(StepSize,Fmax,floor(Fmax/StepSize));
fieldVector = [fpos, flip(fpos),-1.*fpos,-1.*flip(fpos)];
%fieldVector = [-1.*fpos,-1.*flip(fpos)];
fieldVector = ceil(-1.*fieldVector');

[r, c] = size(fieldVector);

% plot the differential voltage vs the applied field
figure
hold on;
ylabel('DiffV (V)');
%xlabel('Field (Oe)');
xlabel('Field (Oe)');
prevStepVolt = stepVolt;
ZeroValue=0;
for i=1:r
    %this is when magnetic field sensor is supplied
%     %set field to x Oe
%     stepVolt = MagnetPostion(fieldCH,fieldVector(i),prevStepVolt)
%     prevStepVolt=stepVolt;
    
    %With bias magnet
    stepVolt = (fieldVector(i)-0.0782)/447.32;
    
    %get the data from the function
    [data,stdErr] = runDAQ(measureTime,stepVolt,delayTime);
    %add data to respective vector
    
    % access data acccording to their channel numbers and store them
    fieldV(i) = data(fieldData); %fieldV(i,2) = stdErr(fieldCH);
    suppV(i) = data(suppVolt);
    delP(i) = data(PDdata);
    
    %fieldV(i,1) = data(fieldCH); fieldV(i,2) = stdErr(fieldCH);
    %distanceV(i,1) = data(distanceCH); distanceV(i,2) = stdErr(distanceCH);
    %suppV(i,1) = data(suppCh); suppV(i,2) = stdErr(suppCh);
    time(i) = i*(delayTime+measureTime); %update time vector
    
    %distanceppm(i) = distanceV(i,1)*(2./9)*((ts / L)^2) * (1/tf) * (Es / Ef);
    %scatter(((fieldV - 2.535)*1E3)/3.125, delP); hold on
    plot((fieldV-2.535).*1000./3.125, delP,'o-'); hold on
    plot((fieldV-2.535).*1000./3.125, movmean(delP,3)); hold on
    %scatter(suppV, P2);
end


AA = [time',suppV',fieldV',delP'];
%AA = data;

%Write to a csv file
csvwrite(append(filename,'.csv'),AA,1,1);
