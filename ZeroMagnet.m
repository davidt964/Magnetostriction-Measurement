function [ZeroValue,stepVolt] = ZeroMagnet(fieldCH,zeroV)
%{
    - Script Authors: Paymon Shirazi and David L. Tran
    - Description: 
        This function obtains the current reading of the magnet
        and zeros it by taking steps toward the 0. Additionally, this function
        takes step at sizes that is dependent on the field value's distance 
        from 0.

    - INPUTS:
        - fieldCH: DAQ channel used for the applied field readings
        - zeroV: Voltage step size

    - OUTPUTS:
        - ZeroValue: Final "zero" value of magnet within reasonable
        tolerance
        - stepVolt: Step voltage change used to zero the magnet

    - Please configure everything according to the setup you are using.
%}

%% Acquisition Parameters

%Channel Setup
sensorChannel = fieldCH;
outputChannel = 0;

%DAQ Parameters
rate = 1e3;      % measurement rate in [Hz]
sec = 1;         % seconds to read
delayy = 0;      % Delay measurement;

%Sensor Parameters
SensorZero = 2.535; %Volts

%% DAQ Setup
d = daq.getDevices();

a = daq.createSession('ni');
addAnalogOutputChannel(a, "cDAQ1Mod1", outputChannel, "Voltage");
addAnalogInputChannel(a,'cDAQ1Mod3', sensorChannel, 'Voltage'); %voltage

a.Rate = rate; %Measurement Rate (Hz)

diffField = 1;
stepVolt = zeroV;
fprintf('%=======================Beginning Magnet Reset=======================\n');
FieldVal = DAQSingle(a,sec,stepVolt,delayy,rate); %take measurement

%Begin the zero process
while (1)
    diffField = SensorZero-FieldVal; %Take difference b/w sensor reading & target
    
    if (FieldVal < SensorZero && FieldVal > 0.01)
        
        if (diffField > 1)
            stepVolt = stepVolt + 1; 
        elseif (diffField > 0.5 && diffField < 1)
            stepVolt = stepVolt + 0.5;
        elseif (diffField > 0.1 && diffField < 0.5)
            stepVolt = stepVolt + 0.1;
        elseif (diffField > 0.05 && diffField < 0.1)
            stepVolt = stepVolt + 0.02;
        elseif (diffField > 0.005 && diffField < 0.05)
            stepVolt = stepVolt + 0.005;
        elseif (diffField > 0.002 && diffField < 0.005)
            stepVolt = stepVolt + 0.002;
        elseif (diffField < 0.002)
            fprintf('Field: ');
            disp((diffField*1E3)/3.125);
            fprintf(' (Oe)\n');
            ZeroValue = (diffField*1E3)/3.125;
            break;
        end
        fprintf('Field: ');
        disp((diffField*1E3)/3.125);
        fprintf(' (Oe)\n');
        
    elseif (FieldVal > SensorZero && FieldVal < SensorZero*2 )
        
        if (diffField < -1)
            stepVolt = stepVolt - 1;
        elseif (diffField < -0.5 && diffField > -1)
            stepVolt = stepVolt - 0.5;
        elseif (diffField < -0.1 && diffField > -0.5)
            stepVolt = stepVolt - 0.1;
        elseif (diffField < -0.05 && diffField > -0.1)
            stepVolt = stepVolt - 0.01;
        elseif (diffField < -0.005 && diffField > -0.5)
            stepVolt = stepVolt - 0.005;
        elseif (diffField < -0.002 && diffField > -0.005)
            stepVolt = stepVolt - 0.002;
        elseif (diffField > -0.002)
            fprintf('Field: ');
            disp((diffField*1E3)/3.125);
            fprintf(' (Oe)\n');
            ZeroValue = (diffField*1E3)/3.125;
            break;
        end
        fprintf('Field: ');
        disp((diffField*1E3)/3.125);
        fprintf(' (Oe)\n');
    else
        fprintf('Sensor out of Range Manually Adjust :D \n');
        break;
    end
    FieldVal = DAQSingle(a,sec,stepVolt,delayy,rate);
    fprintf('FieldVal: ');
    disp(FieldVal);
end

end