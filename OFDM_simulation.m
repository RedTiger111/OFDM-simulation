% Student ID : 2019314131
% Date       : 2023/07/12


%********************************1*****************************************
%*************************png to binary************************************
% SNR = input("Enter SNR : )";
% Enter SNR
SNR = 10;


data = imread('C:\Users\user\Desktop\OFDM\bapoon.png');
bin=dec2bin(data);
bin_data =[];

for i = 1:length(bin)
    bin_data=[bin_data,bin(i,:)];
end

%********************************2*****************************************
%****************************Modulation************************************

%r = input("Enter Modulation Order : "); 
%Enter Modulation Order
r = 4; % 16-QAM
M = r^2;
data_mod=[];

for i = 1:length(bin_data)/r
    data_mod(i) = bin2dec(bin_data(1+r*(i-1):r*i)); 
end
I_Q_Tx = qammod(data_mod,M,UnitAveragePower=true);

%********************************3*****************************************
%*************************serial-to-parallel*******************************
RB_Tx = [];
p=1;
i=1;
symbol_length=1200;

while p < length(I_Q_Tx)
    for j = 1:symbol_length
        if j == 1  % at 1st sub-carrier = reference signal
            RB_Tx(j,i) = 1; % Refrence signal = 1
        else 
            RB_Tx(j,i) = I_Q_Tx(p);
            p=p+1;
        end
    end
    i=i+1;
end

%********************************4*****************************************
%********************CP & AWGN & Rayleigh fading***************************
RB_Tx_1 = RB_Tx(:);

for i = 1:length(RB_Tx_1)
    if RB_Tx_1(i)==0
        cnt=i;
        break
    end
end
RB_Tx_2 = RB_Tx_1(1:cnt-1);
RB_IFFT_Tx = RB_Tx_2;



RB_CP_Tx=[];
Tcp_1 = 160; % CP for 1st symbol 
Tcp_2 = 144; % CP for others symbol

for i = 1:ceil(length(RB_IFFT_Tx(:))/symbol_length)-1
    if rem(i,7)==1 % 1st symbol
        CP = RB_IFFT_Tx(i*symbol_length+1-Tcp_1:i*symbol_length);
    else           % others symbol
        CP = RB_IFFT_Tx(i*symbol_length+1-Tcp_2:i*symbol_length);
    end
    symbol = [CP;RB_IFFT_Tx((i-1)*symbol_length+1:i*symbol_length)];
    RB_CP_Tx = [RB_CP_Tx;symbol];
end

RB_CP_Tx = [RB_CP_Tx;RB_Tx(1:208,148)];

% 마지막 cp는 안들어감
% 총 # of CP = 147






H_Tx =[];
for i = 1:148
    H_Tx(i) = randn(1,'like',1i);
end

% Rayleigh channel for RB


data_Tx = [];
p=0;
for i = 1:length(H_Tx)
    if rem(i,7) == 1
        for j = 1:symbol_length+Tcp_1
            p=p+1;
            data_Tx(p) = awgn(conv(H_Tx(i),RB_CP_Tx(p)),SNR,'measured');
        end
    else
        for j = 1:symbol_length+Tcp_2
            p=p+1;
            data_Tx(p) = awgn(conv(H_Tx(i),RB_CP_Tx(p)),SNR,'measured');
        end
    end
    if p == length(RB_CP_Tx)
        break
    end
end




%**************************************************************************
%*****  
% Rx
%*****
%********************************5*****************************************
%***************************Eliminate CP **********************************
symbol_length = 1200;
Tcp_1 = 160;
Tcp_2 = 144;

% # of CP = 147 

k=1;
i=1;
while k < 148
    if rem(k,7) == 1
        data_Tx(i:i+Tcp_1-1) =[]; 
        i=i+symbol_length;
        k=k+1;
    else
        data_Tx(i:i+Tcp_2-1) =[];
        i=i+symbol_length;
        k=k+1;
    end
end

data_Rx = data_Tx;

%********************************6*****************************************
%********************** Channel Reconstruction ****************************


for i =1:ceil(length(data_Rx)/(symbol_length))
    H_Rx(i) = data_Rx((i-1)*(symbol_length)+1)/1; % 1 = reference signal
end

i=1;
p=1;
while i<length(H_Rx)
    for j =1:symbol_length
        data_Rx(p) = data_Rx(p)./H_Rx(i);
        p=p+1;
    end
    i=i+1;
end



%********************************7*****************************************
%********************** Remove Refrence signal ****************************


i=1;
while i < length(data_Rx)
    data_Rx(i)=[];
    i=i+symbol_length-1;
end

I_Q_Rx = data_Rx;

%********************************8*****************************************
%********************** 16-QAM Demodulation *******************************


r=4;
M=r^2;
bin_data_Rx = qamdemod(I_Q_Rx,M,UnitAveragePower=true);


for i = 1:length(bin_data_Rx)
    if length(dec2bin(bin_data_Rx(i))) == 4
        data_demod(i,:) = dec2bin(bin_data_Rx(i));
    elseif length(dec2bin(bin_data_Rx(i))) == 3
        data_demod(i,:) = strcat('0',dec2bin(bin_data_Rx(i)));
    elseif length(dec2bin(bin_data_Rx(i))) == 2
        data_demod(i,:) = strcat('00',dec2bin(bin_data_Rx(i)));
    elseif length(dec2bin(bin_data_Rx(i))) == 1
        data_demod(i,:) = strcat('000',dec2bin(bin_data_Rx(i)));
    end
end

bin_Rx =[];
for i =1:length(data_demod)/2
    bin_Rx(i) = 16*bin2dec(data_demod((i-1)*2+1,:))+bin2dec(data_demod(2*i,:));
end

%********************************9*****************************************
%********************** Reconstruction image ******************************

p=1;
pixel_Rx =[];
for i = 1:3
    for j = 1:170
        for q = 1:173
            pixel_Rx(q,j,i) = bin_Rx(p);
            p=p+1;
        end
    end
end

pixel_Rx = cast(pixel_Rx,'uint8');

figure(1),image(data);
figure(2),image(pixel_Rx);

