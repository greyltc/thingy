function task_2
weights = [
    0.14; % Brce Norton
    0.10; % Herstmonceux
    0.30; % Heathrow
    0.13; % Nottingham
    0.20; % Shawbury
    0.13];% Waddington

IN = readtable('UK-Temperatures.csv');
TT = table2timetable(IN);

TT.Properties.DimensionNames(1) = {'Date'};

filled = fillmissing(TT,'linear');
filled.Weighted = filled.Variables*weights;
dailyMeansTT = retime(filled, 'daily', 'mean');
dailyMeansTT(1:5,end)
