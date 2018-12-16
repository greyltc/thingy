function [foobarsBought, change] = task_1(budget)
% to solve task 1, run this function like this:
% [bought, change] = task_1(200)

increaseFactor = 1.2;

foobarsBought = 0;
spent = 0;
currentPrice = 1;

% start an infinite loop
while true
    % break out of the infinite loop if we're about to go over budget
    if (spent + currentPrice) > budget
        break
    end
    foobarsBought = foobarsBought + 1; % buy a foobar
    spent = spent + currentPrice; % pay for the foobbar
    currentPrice = round(currentPrice*increaseFactor,2); % calcualte the price for the next foobar
end

% see how much money we have left over
change = budget - spent;

end