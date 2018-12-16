function task_3

IN_temp = readtable('Temperatures-South-Carolina.csv');
IN_demand = readtable('Residential-Demand-South-Carolina.csv');

dates_dem = IN_demand{:,1};
demand = IN_demand{:,2};
[yd,md] = ymd(dates_dem);
yd = string(yd);
yd(strlength(yd)==1) = strcat('0',yd(strlength(yd)==1));
md =  string(md);
md(strlength(md)==1) = strcat('0',md(strlength(md)==1));
Dd = strcat(yd,'/',md);
u_d_d = unique(Dd);

dates_temp = IN_temp{:,1};
temperatures = IN_temp{:,2};

[y,m] = ymd(dates_temp);
y = string(y);
y(strlength(y)==1) = strcat('0',y(strlength(y)==1));
m =  string(m);
m(strlength(m)==1) = strcat('0',m(strlength(m)==1));

D = strcat(y,'/',m);
u_d = unique(D);

means = nan([numel(u_d),size(temperatures,2)]);
for i=1:numel(u_d)
    id = strcmp(D,u_d(i));
    means(i,:) = nanmean(temperatures(id,:),1);
end
overall_mean = [u_d,string(means)];

[index_temp,index_dem] = ismember(u_d,u_d_d);
data = [means(index_temp),demand(index_dem(index_dem>0))];

p = polyfit(data(:,1),data(:,2),2);

plot(data(:,1),data(:,2),'x')
hold on
plot(linspace(min(data(:,1)),max(data(:,1)),1000),polyval(p,linspace(min(data(:,1)),max(data(:,1)),1000)))
xlabel('Monthly Average Temperature')
ylabel('Demand')


predictions = polyval(p,means(~index_temp)); % predictions for January-April 2017

%% daily analysis
demand_daily = polyval(p,temperatures)./(365/12); % daily demand for gas (based on average number of days in a month)
