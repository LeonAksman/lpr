function testBeta()

x               = 0:.01:1;

hold on; 

for i = 1:10
    for j = 1:10
        y       = regularizedBeta(x, i, j);
        plot(x, y/y(end));
    end
end