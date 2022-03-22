function [] = PlaybackBeamBreak()

Dir = pwd; %sets up current directory for creating files
a = arduino; %connects to arduino
BirdNum = input('Enter bird ID and session number (ID_Sesh.No.): ', 's'); %Collects trial information for storing data
DT = datestr(now);
T1 = datetime('now', 'format', 'HH:mm');
filename = DT(1:11) + "_" + BirdNum + ".txt";
Fid = fopen(filename,'w');
pretraining = input('30 min acclimitisation period y/n? ', 's'); %Does this bird require 30 mins to acclimate to the cage?

Sensor0 = 'A5'; % Determining which pin to use as sensor
configurePin(a, 'D2', 'DigitalOutput') %Define digital pin for 5 volts to photo diode
writeDigitalPin(a, 'D2', 1) %setting IR led as always on
Counter0 = 1;
count = 0; %to count number of beam breaks

%Decide which video to play depending on identity of bird
Bird = str2num(BirdNum(5:7));
if Bird == 059
    script = 'python short_final_vid.py';
elseif Bird == 071
    script = 'python final_vid.py';
elseif Bird == 073
    script = 'python short_final_vid.py';
elseif Bird == 080
    script = 'python short_final_vid.py';
elseif Bird == 060
    script = 'python short_final_vid.py';
elseif Bird == 030
    script = 'python final_vid.py';
end

for k = 1:inf
    Fid = fopen(filename,'a');
    VoltVal0 = readVoltage(a, Sensor0); % Voltage for perch
    % ----- check voltage for perch -------------------------    
    if VoltVal0 >= 2
        Counter0 = Counter0 +1;
        if Counter0 == 2
            if pretraining == 'y'
                T2 = datetime('now', 'format', 'HH:mm');
                dt = T2 - T1;
                if minutes(dt) < 30
                    system("python male_habit.py");
                else
                    if count <= 20
                        system(script);
                        pause(5)
                        count = count + 1;
                        fprintf(Fid,'%s  %s\n', DT(13:end), "final_vid")       
                    end
                end
            elseif pretraining == 'n'
                if count <= 20
                    system(script);
                    pause(5)
                    count = count + 1;
                    DT1 = datestr(now);
                    fprintf(Fid,'%s  %s\n', DT1(13:end), "final_vid")              
                elseif count >= 20
                    print("Maximum number of playbacks completed")
                end
            end           
            Counter0 = Counter0 +1;          
        end
    else
        Counter0 = 1;
    end    
fclose(Fid)
end