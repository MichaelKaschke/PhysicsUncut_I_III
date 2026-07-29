clc; clear all; close all; clf;
cputime=0;
tic;
%%%%%%%%%%%%
ln=1;
%%%%%%%%%%%%
i=sqrt(-1);
s=-1;
alpha=0; % Fiber loss value in dB/km
alph=alpha/(4.343); %Ref page#55 eqn 2.5.3
g=0.003; %fiber non linearity in /W/m
N=1; %soliton order
to=125e-12; %initial pulse width in second
pi=3.1415926535;
Po=0.00064; %input pwr in watts
Ao=sqrt(Po); %Amplitude
Ld=(N^2)/(g*Po);%dispersion length for corresponding soliton order
b2=-(to)^2/Ld; %2nd order disp. (s2/m)
tau =- 4096e-12:1e-12: 4095e-12;%  dt=t/to
 dt=1e-12/to;
 h1=1000;% step size
for ii=0.1:0.1:1.0
z=ii*Ld;
 u=N*sech(tau/to);%fundamental soliton pulse
    figure(1)
   plot(abs(u),'r');
grid on;
hold on;
h=h1/Ld;%soliton conditions
Z=z/Ld;%soliton conditions
l=max(size(u));  
%%%%%%%%%%%%%%%%%%%%%%%
fwhm1=find(abs(u)>abs(max(u)/2));
fwhm1=length(fwhm1);
spectrum=fft(fftshift(u)); %Pulse spectrum
dw=(1/l)/dt*2*pi;
w=(-1*l/2:1:l/2-1)*dw;
 w=fftshift(w);
d=0;
for jj=h:h:Z
spectrum=spectrum.*exp(-alph*(h/2)+i*s/2*w.^2*(h/2)) ; 
f=ifft(spectrum);
f=f.*exp(i*(N^2)*((abs(f)).^2)*(h));
% f=fftshift(f);
spectrum=fft(f);
spectrum=spectrum.*exp(-alph*(h/2)+i*s/2*w.^2*(h/2)) ; 
d=d+1;
end
f=ifft(spectrum);
f=fftshift(f);
op_pulse(ln,:)=abs(f);%saving output pulse at all intervals
fwhm=find(abs(f)>abs(max(f)/2));
fwhm=length(fwhm);
ratio=fwhm/fwhm1 %PBR at every value
pbratio(ln)=ratio;%saving PBR at every step size
dd=atand((abs(imag(f)))/(abs(real(f))));
phadisp(ln)=dd;%saving pulse phase
ln=ln+1;
end
toc;
cputime=toc;
figure(2);
mesh(op_pulse(1:1:ln-1,:));
figure(3)
plot(pbratio(1:1:ln-1),'k');
xlabel('Number of steps');
ylabel('Pulse broadening ratio');
grid on;
hold on;
figure(4)
plot(phadisp(1:1:ln-1),'k');
xlabel('distance travelled');
ylabel('phase change');
grid on;
hold on;
disp('CPU time:'), disp(cputime);