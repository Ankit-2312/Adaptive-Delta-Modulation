clc;
clear all;
[x, Fs] = audioread('G:\Music\ADELE\Skyfall - Single\01 Skyfall.mp3');
y1=x(44100*1:44100*6);
sound(y1, Fs);
figure;
plot(y1);
pause(5);
 [x, Fs] = audioread('G:\Music\AC-DC\AC_DC\14 Dirty Deeds.mp3');
y1=x(44100*1:44100*6);
sound(y1, Fs);
figure;
plot(y1);
pause(5);
[x, Fs] = audioread('G:\Music\AC-DC\AC_DC Live\01 Thunderstruck.mp3');
y1=x(44100*1:44100*6);
sound(y1, Fs);
figure;
plot(y1);
pause(5);
in = input('Choose audio on which you need to TEST ADM code = ');
if(in == 1)
[x1, Fs] = audioread('G:\Music\ADELE\Skyfall - Single\01 Skyfall.mp3');
x=x1(44100*1:44100*6);
elseif in == 2
[x1, Fs] = audioread('G:\Music\AC-DC\AC_DC\14 Dirty Deeds.mp3');
 x=x1(44100*1:44100*6);
elseif in == 3
[x1, Fs] = audioread('G:\Music\AC-DC\AC_DC Live\01 Thunderstruck.mp3');
x=x1(44100*1:44100*6);
end
T=1/Fs; nmax=length(x); t=[0:nmax-1]*T; 
Vmin=-0.1; Vmax=0.1; N=2;
delta_min=(Vmax-Vmin)/(2^N);
delta(1) = delta_min;
[B,A] = fir1(50,10000/(Fs/2),'low');
lowpass = @(S) filter(B,A,S);
n_snr= input('Enter 1 if you need to add AWGN CHANNEL NOISE else enter 0 ');
if (n_snr == 1)
snr= input ('Enter signal to noise ratio = '); % SNR value
end
for n=1:nmax
if n == 1
d(1) = x(1);
dq(1)= delta(1)*sign(d(1));
mq(1)=dq(1);
else
d(n) = x(n)-mq(n-1);
dq(n)= sign(d(n));
delta(n) = delta(n-1)*(1.5^(dq(n)*dq(n-1))); % Width of the quantization interval = To avoid slope overload distortion
eq2(n) = delta(n)*dq(n); % step- size control
mq(n) = mq(n-1)+eq2(n);
end
end 
%Channel noise AWGN 
 
if (n_snr == 1)
s = awgn(dq,snr);
end 
% ADM Receiver system 
if n_snr == 1
Yn = s.*delta; 
Xn(1) = Yn(1);
for k=2:length(x),
Xn(k) = Yn(k)+Xn(k-1);
end
else Yn = dq.*delta;
Xn(1) = Yn(1);
for k=2:length(x),
Xn(k) = Yn(k)+Xn(k-1);
end
end
%Received information in the receiver
xn = lowpass(Xn); sound(xn, Fs);
%Plots of signals to observe 
figure;
subplot(221), plot(t,x,'k-'), title('input signal (black)'), subplot(222), stairs(t,xn,'r-'), title('received signal (red)'),
subplot(223), stairs(t,d,'k-'), title('transmitted side error signal (black)'), 
for n= 1:nmax
err(n) = x(n) - xn(n); end
subplot(224), plot(t,err,'r-'), title('receiver side error signal (red)'),
figure, stairs(t,dq,'b-'), title('Quantiser output / Transmitted signal'), 
powersum_of_squared_error1=err*err' % (1 cross nmax) * (nmax cross 1) = 1 cross 1
