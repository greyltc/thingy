clear all

IN_temp = readtable('data/Temperatures-South-Carolina.csv');
IN_demand = readtable('data/Residential-Demand-South-Carolina.csv');

tempTT = table2timetable(IN_temp);
demandTT = table2timetable(IN_demand);

% define time ranges for splitting up the dataset
TR2013 = timerange('13-01-01','14-01-01');
TR2014 = timerange('14-01-01','15-01-01');
TR2015 = timerange('15-01-01','16-01-01');
TR2016 = timerange('16-01-01','17-01-01');
TR2017 = timerange('17-01-01','18-01-01');

% split the big time data set up by year
tempTT2013 = tempTT(TR2013,:);
tempTT2014 = tempTT(TR2014,:);
tempTT2015 = tempTT(TR2015,:);
tempTT2016 = tempTT(TR2016,:);
tempTT2017 = tempTT(TR2017,:);

% shift each timeset to a common start time
tempTT2013.Var1 = tempTT2013.Var1 - tempTT2013.Var1(1);
tempTT2014.Var1 = tempTT2014.Var1 - tempTT2014.Var1(1);
tempTT2015.Var1 = tempTT2015.Var1 - tempTT2015.Var1(1);
tempTT2016.Var1 = tempTT2016.Var1 - tempTT2016.Var1(1);
tempTT2017.Var1 = tempTT2017.Var1 - tempTT2017.Var1(1);

% stack data sets on top of eachother tomake the analysis below possible
masterT = [tempTT2013; tempTT2014; tempTT2015; tempTT2016; tempTT2017];

% here's the input data to our temperature vs time model
t = hours(masterT.Var1);
y = masterT.Var2;

% here we define our model for the temperature over a year
%found on the world wide web:
%https://www.scipy-lectures.org/intro/scipy/auto_examples/solutions/plot_curvefit_temperature_data.html)
hoursInLeapYear = 366*24;
tmpModel = @(ampl,avg,time_offset,x) avg+ampl*cos((x+time_offset)*2*pi/hoursInLeapYear);

% fit the data to our model
fitobject = fit(t,y,tmpModel);

% visualize the fit
%figure
%plot(fitobject,t,y)

% these are the hours we need temperatures for (april 1 to may 1)
hoursToAprilFools = hours(datetime('00-03-31') - datetime('00-01-01'));
aprilHours = (0:24:(24*30)) + hoursToAprilFools;

% now we use the fit to our model to predict the april temperatures
aprilTemperatures = feval(fitobject,aprilHours);

days2017 = [hours(tempTT2017.Var1); aprilHours']/24;

% stack our temp predictions onto the known temp data for 2017
temps2017 = [tempTT2017.Var2; aprilTemperatures];

% visualize the temperature prediction
%figure
%plot(days2017,temps2017,'-*')
%xlabel('Days since start of 2017')
%ylabel('Temperature [Deg F]')
%grid on

% second part: start to consider the demand data
pre2017 = timerange('13-01-01','16-12-31'); %relevant period for demand data
pre2017TT = tempTT(pre2017,:); % pick out the temp data over this range

% combine temperature and demand data converting demand to a daily sampling
% interval by linear interpolation
tempAndDemand = synchronize(demandTT,pre2017TT,'daily','linear');

% here's the input data to our demand vs temperature model
T = tempAndDemand.Var2_pre2017TT; % temperatures
D = tempAndDemand.Var2_demandTT; % demands

% fit the data to a first order exponential function: D = a*exp(b*T)
% using the Least Absolute Residual robust linear least-squares fitting
% method (found to give best results in interactive fitting GUI)
fitobject2 = fit(T,D,'exp1','Robust','LAR');

% visualize the fit
%figure
%plot(fitobject2,T,D)

% use the fit to our exponential model to predict the daily demand given
% the temerature data for the first four months of 2017
demand2017 = feval(fitobject2,temps2017);

% figure out the dates that go along with the 2017 demand data we predicted
dates2017 = days(days2017) + datetime('17-01-01');

% form a timetable filled with the results of our analysis
resultTT = timetable(dates2017);
resultTT.Demand = demand2017;

% print the first five rows (days) of the answer table
resultTT(1:5,:)

%           dates2017         Demand
%     ____________________    ______
% 
%     01-Jan-0017 00:00:00    2599.9
%     02-Jan-0017 00:00:00    1473.3
%     03-Jan-0017 00:00:00    1726.2
%     04-Jan-0017 00:00:00    3212.5
%     05-Jan-0017 00:00:00    3473.9