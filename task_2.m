function task_2

% weights for weighted average these MUST sum to unity
weights = [
    0.14; % Brice Norton
    0.10; % Herstmonceux
    0.30; % Heathrow
    0.13; % Nottingham
    0.20; % Shawbury
    0.13];% Waddington

% check that weights add to one
assert(sum(weights) == 1)

% read in temperature data into table
IN = readtable('data/UK-Temperatures.csv');
TT = table2timetable(IN); % convert to timetable

TT.Properties.DimensionNames(1) = {'Date'}; % change time header because OCD

filled = fillmissing(TT,'linear'); % use linear interpolation (& extrapolation) to replace missing data
filled.Weighted = filled.Variables*weights; % calculate weighted averages for each row in the table
dailyMeansTT = retime(filled, 'daily', 'mean'); % Calculate the mean for each reading over daily time bins
dailyMeansTT(1:5,end) % print the first five rows of the last column (the weighted average) of the solution table
