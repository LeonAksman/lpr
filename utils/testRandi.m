function testRandi()

perms   = 3;
classes = 20;

classMat = [];

%rng('default');
rng('shuffle');

for i = 1:perms
    classes_i                     	= randi(2, classes, 1);

    pause(5);
   
    %parfor j = 1:10
    %    temp = classes_i;
    %end
    
    classMat = [classMat classes_i];
end

disp(classMat);
disp(sum(classMat));

