function [value] = DAQSingle(a,sec,volt,delayy,rate)
%{
    - Script Authors: Paymon Shirazi and David L. Tran
    - Description: Takes a single reading from the DAQ device.

    - INPUTS:
        - a: DAQ device object
        - sec: Time to read for in [sec]
        - volt: Voltage step size
        - delayy: Measurement Delay in [sec]
        - rate: Measurement rate in [Hz]

    - OUTPUTS:
        - value: Averaged value of the differential voltage reading

    - Please configure everything according to the setup you are using.
%}

vout = linspace(volt, volt, (sec+delayy)*rate);
queueOutputData(a,vout');

data = startForeground(a);

value = mean(data);
 
end