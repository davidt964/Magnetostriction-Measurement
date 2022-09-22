function [value, stdErr] = runDAQ(sec,volt,delayy)
%{
    - Description: 
        Runs the DAQ device and further processes the data.


    - INPUTS:
        - sec: measurement time in secs
        - volt: the step voltage obtained from ZeroMagnet
        - delayy: measurement delay in secs


    - OUTPUTS:
        - value: average of the lowpass (LP) filtered data
        - stdErr: standard error of the lowpass (LP) filtered data

    - Please configure everything according to the setup you are using.
%}

% DAQ device setup
d = daq.getDevices();

s = daq.createSession('ni');
addAnalogOutputChannel(s, "cDAQ1Mod1", 0, "Voltage");
addAnalogInputChannel(s,'cDAQ1Mod3', [0,1,2,3], 'Voltage'); %voltage

rate = 1e3;             %Measurement Rate (Hz)

s.Rate = rate;          %Measurement Rate (Hz)

vout = linspace(volt, volt, (sec+delayy)*rate); %continuously plot data
queueOutputData(s,vout');               %queues data 

% Begin data acquisition process and save data from 's' (DAQ device) into 'data'
data = startForeground(s);

if (delayy ~= 0)
    data = data([delayy*rate : (sec+delayy)*rate],:);
end

[r,c] = size(data);     %rows and columns of data
%disp(r);       %uncomment in case of MATLAB errors to find source of error
%disp(c);

value = [];
stdErr = [];

% lowpass filter at a passband frequency and rate
f_pass = 5;         %passband frequency [Hz]
filtered = lowpass(data,f_pass,rate);

% further average and process the data
for i=1:c
    value(i) = mean(filtered(:,i));             %take average of LP filtered data
    stdErr(i) = std(filtered(:,i))/sqrt(r);     %obtain std. err. of LP filtered data a
end

end