
growth = 1; %growth rate of PSP filter
decay = 10; %decay rate of PSP filter



n = 0:.1:80;

g1 = 1-exp(-n/growth);
g2 = exp(-n/decay);

subplot(211)
plot(n, g1, 'r.-', n, g2, 'g.-')
subplot(212)
plot(n, g1.*g2, '.-')

gprod = g1.*g2;
g = 1000*gprod/sum(gprod);
hold on
plot(n, g, 'r')
plot(n, normalize(gprod), 'g')
hold off


% conv_start=0;
% 
% %the PSP function is pretty much back at zero by the time time=4*decay
% 
% conv_tot=4*decay;
% 
% temp = 0;
% for i=1:conv_tot+1
% 	convf(i)= 1 - exp(-(i/growth))*exp(-i/decay);
% 	temp = temp + convf(i);
% end
% 
% for i=1:conv_tot
% 	convf2(i) = 1000.0*convf(i)/temp;
% end
% 
% plot(convf2)