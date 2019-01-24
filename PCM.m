clc;
close all;
clear all;
f=input('Enter your message frequency ');
fs=input('Enter your sampling Frequency ');
A=input('Enter your max Amplitude ');
%time domain
t=1/fs:1/fs:1;
%message signal
x=A*sin(2*pi*t*f);
%keep the signal for future requirment
x_keep=x;
n=input('Enter the bits per integer ');

%% Modulation

%for uniform quantization
x_max=max(x);
x_min=min(x);
delta=(x_max-x_min)/((2^n)-1);
u_quant=x_min:delta:x_max;
encode=zeros(size(x));

%the logic below is simple do the 'round' operation on matlab not exactly
% the message signal is shifted to that quantized level wich is near to it. 
%And for the encoding, as we need a binary data at the output of transmitter 
%and we can't convert a fractional value to its corresponding binary value we
%just send the index of the quantization level where the message signal
%shifted for quantization
for i=1:numel(t)
    for j=1:numel(u_quant)
        if(abs(x(i)-u_quant(j)) < delta/2)
            x(i)=u_quant(j);
            encode(i)=j-1;  %'-1' for keep the index in the range (0, (2^n)-1)
        end
    end
end

%the following code simple convert the binary value to the corresponding
%index of quantization level. And if our bit size is 8 and the binary
%representation of a number is required less than 8 bit like if number <
%(2^(8-1))-1 then we pad a zero array to the left of the binary array so
%that for every time bit size is same equals to 'n'.
x_encoded=[];
for i=1:numel(encode)
    test=de2bi(encode(i),'left-msb');
    if numel(test)<n
        a=n-numel(test);
        pad_array=zeros(1,a);
        test=[pad_array test];
    end
    x_encoded=[x_encoded test];
end
%quantization error
q_error=x_keep-x;
figure(1)
plot(t,x_keep);
hold on;
plot(t,x)
title('Original signal and quantized signal');
xlabel('t');
ylabel('Magnitude');
grid on;
figure(2)
plot(t,q_error)
title('Quantization error');
xlabel('t');
ylabel('Magnitude');
grid on;
figure(3)
plot(t,encode)
title('Encoded signal');
xlabel('t');
ylabel('Magnitude');
grid on;
figure(4)
stem(x_encoded)
title('Encoded signal in binary format');
xlabel('t');
ylabel('Magnitude');
grid on;
%% demodulation
% the logic is similar to the modulation. here first we group the binary
% value such that no. of element in one group is n(bits); then we find the
% decimal value correspond to the binary value and keep them in 'x_decoded'
% array; as we discussed before that the 'x_encoded' contain the index of
% quantization level corresponding to messege signal so the reconstructed
% signal is simple the accumulation of quantization level correspond to
% 'x_decoded' index.
x_decoded=[];
x_final=zeros(size(x));
for i=1:n:numel(x_encoded)
    c=x_encoded(i:i+n-1);
    c1=bi2de(c,'left-msb');
    x_decoded=[x_decoded c1];
    k=((i-1)/n)+1;
    x_final(k)=u_quant(x_decoded(k)+1);
end
figure(5)
plot(t,x_final)
title('Signal received at receiver');
xlabel('t');
ylabel('Magnitude');
grid on;
errors=x_keep-x_final;
figure(6)
plot(t,errors)

% reconstruction
% [p,q]=butter(7,1.2*f/fs,'low');
% q1=filter(p,q,x_final);
% figure(7)
% plot(t,q1)
% title('Signal received at receiver');
% xlabel('t');
% ylabel('Magnitude');
% grid on;

