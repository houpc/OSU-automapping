function osuDataInput = getOsuDataInput(Ts,songfile,localfilters)

% This function is for generating the inputs to the neural network, as a
% formatized data of the songfile.
% 
% Specially designed for convolution NN "FrostNova" Ver1
% -----------Input------------ 
% Ts: the rhythm poitns of the song, Ts=Ts=getRhythmPoints(s), where s
% is the osu structure.
% songfile: the path of the music file.
% -----------Output------------
% osuDataInput:
% 
% -----------------------
% By Dongqi Han, OIST


t_reso=2; % temporal resolution (in milisecond)
N=30;

if ~exist('filters','var')
%     filterdata=load('frostnova_filters.mat');
    x=1:(2*N+1);
    for i=1:10
        localfilters{i}=exp(-(x-N-1).^2/(N/(i/2)));
    end
    for i=11:20
        localfilters{i}=sign(x-N-1).*abs((x-N-1)/N).^((i-10)/4);
    end
    for i=21:30
        localfilters{i}=cos((x-N-1)/(i-20));
    end
    
    
    
    
end

%----------- read data -------------
[data0,fs]=audioread(songfile);
data=data0(:,1);


% Nfft=floor(fs/(1000/(2*t_reso))); 
% [S,F,T]=spectrogram(data,Nfft,Nfft/2,Nfft,fs);
% T=T*1000; %convert to ms
% 
% S = abs(S);
% S_t=sum(S,1)';


Nfft=floor(fs/(1000/(t_reso))); 
S=zeros(Nfft,floor(length(data)/Nfft));
for i = 1 : floor(length(data)/Nfft)
    S(:,i)=data(((i-1)*Nfft+1):(i*Nfft));
end

dt=Nfft/fs*1000;

T=linspace(dt/2,(floor(length(data)/Nfft)-1/2)*dt,floor(length(data)/Nfft));
S_t=abs(sum(S.^2,1));




data_t=zeros(2*N+1,length(Ts)-2);  %the amplitute of sound strength around t=Ts(n) (after Ts(i-1) and before Ts(n+1), divided input 101 parts with fixed interval)

for n=2:length(Ts)-1 %drop the first and last timing points.
    
    tq(1:N+1)=linspace(Ts(n-1),Ts(n),N+1);
    tq(N+1:2*N+1)=linspace(Ts(n),Ts(n+1),N+1);

    tmp=interp1(T,S_t,tq);
    
    data_t(:,n-1)=tmp/max(tmp);
    n
end


% for n=2:length(Ts)-1 %drop the first and last timing points.
%     
%     tq(1:N+1)=linspace(Ts(max(n-3,2)),Ts(n),N+1);
%     tq(N+1:2*N+1)=linspace(Ts(n),Ts(min(n+3,length(Ts)-1)),N+1);
% 
%     tmp=interp1(T,S_t,tq);
%     
%     data_t(:,n-1)=tmp/max(tmp);
%     n
% end


% Nfft=floor(fs/(1000/(2*5))); 
% [S,F,T]=spectrogram(data,Nfft,Nfft/2,Nfft,fs);
% T=T*1000; %convert to ms
% 
% S = log(1+abs(S))/mean(mean(log(1+abs(S))));
% 
% data_f=zeros(length(F),length(Ts)-2);


% for n=2:length(Ts)-1
% 
%     data_f(:,n-1)=interp1(T,S',Ts(n));
%     n
% end


%----------- process data -------------


osuDataInput.data_t=data_t;
% osuDataInput.data_f=data_f;
% osuDataInput.F=F;


input=zeros(length(localfilters),size(data_t,2));

for n=1:size(data_t,2)
    for i=1:length(localfilters)
        input(i,n)=dot(localfilters{i},data_t(:,n));
    end
end

osuDataInput.input=input;

end


