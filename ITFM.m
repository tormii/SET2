function [Reconstruction,t] = ITFM(TFxi,fs,s,direction,tf_type)
%% 参数说明
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 程序版权归属(copyright)：
% 包文杰(邮箱：baowenjie@sjtu.edu.cn)
% Bao Wenjie(email：baowenjie@sjtu.edu.cn)
% 上海交通大学 机械系统与振动国家重点实验室（李富才团队）
% State Key Laboratory of Mechanical System and Vibration, Shanghai Jiao
% Tong University(Li Fucai Team)
% 上海市闵行区东川路800号 机械与动力工程学院B楼405室
% Room 405, Building B, School of Mechanical Engineering, 800 Dongchuan Road, Minhang District, Shanghai, 200240, P.R.China
% 程序使用请注明出处
% Please indicate the source of the program
% 参考论文(paper)：Second-Order Synchroextracting Transform with Application to Fault Diagnosis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 预处理
    [N,~] = size(TFxi);
    t = (0:N-1)/fs;
    dt = 1/fs;
    df = fs/N;
%% 时间方向压缩的变换重构
    if (strcmp(direction, 'Time') || strcmp(direction, 'T'))
%%%%%%%%%%%%%计算公共部分%%%%%%%%%%%%%%%%
        TimeSum = sum(TFxi,1);        
        mySpectrum = zeros(1,N);
        %频谱扩展
        if mod(N,2)==0      
            for i = 0:N/2
                mySpectrum(i+1) = TimeSum(i+1);
            end
            for i = N/2+1:N-1
                mySpectrum(i+1) = conj(TimeSum(N-i+1));
            end
        else
            for i = 0:(N-1)/2
                mySpectrum(i+1) = TimeSum(i+1);
            end
            for i = (N+1)/2:N-1
                mySpectrum(i+1) = conj(TimeSum(N-i+1));
            end
        end
%%%%%%%%%%%%%计算STFT%%%%%%%%%%%%%%%%
        if (strcmp(tf_type, 'STFT'))
            gf = @(Omega) sqrt(2*s)*pi^(1/4)*exp(-(s*Omega).^2/2);
            g0 = conj(gf(0));
            Reconstruction = ifft(mySpectrum)/g0*dt;
%%%%%%%%%%%%%计算MRM%%%%%%%%%%%%%%%%
        elseif (strcmp(tf_type, 'MRM'))
            gt = @(t) s^(-1/2)*pi^(-1/4).*exp(-t.^2/s^2/2);
            g0 = conj(gt(0));
            Reconstruction = ifft(mySpectrum)/g0;
%%%%%%%%%%%%%计算TSST1和TSST2%%%%%%%%%%%%%%%%
        elseif (strcmp(tf_type, 'TSST1')||strcmp(tf_type, 'TSST2'))
            gf = @(Omega) sqrt(2*s)*pi^(1/4)*exp(-(s*Omega).^2/2);
            g0 = conj(gf(0));
            Reconstruction = ifft(mySpectrum)/g0;
%%%%%%%%%%%%%计算TSET1%%%%%%%%%%%%%%%%            
        elseif (strcmp(tf_type, 'TSET1'))
            gt = @(t) s^(-1/2)*pi^(-1/4).*exp(-t.^2/s^2/2);
            g0 = conj(gt(0));
            Reconstruction = ifft(mySpectrum)/g0;
%%%%%%%%%%%%%计算TSET2%%%%%%%%%%%%%%%%            
        elseif (strcmp(tf_type, 'TSET2')||strcmp(tf_type, 'DET'))
            Reconstruction = ifft(mySpectrum);
%%%%%%%%%%%%%其它%%%%%%%%%%%%%%%%
        else
            error([direction,'不支持：',tf_type]);
        end        
%% 频率方向压缩的变换重构      
    else
%%%%%%%%%%%%%计算公共部分%%%%%%%%%%%%%%%% 
        mySpectrum = zeros(N,N);
        %频谱扩展
        if mod(N,2)==0      
            for i = 0:N/2
                mySpectrum(:,i+1) = TFxi(:,i+1);
            end
            for i = N/2+1:N-1
                mySpectrum(:,i+1) = conj(TFxi(:,N-i+1));
            end
        else
            for i = 0:(N-1)/2
                mySpectrum(:,i+1) = TFxi(:,i+1);
            end
            for i = (N+1)/2:N-1
                mySpectrum(:,i+1) = conj(TFxi(:,N-i+1));
            end
        end
        FrequencySum = real(sum(mySpectrum,2));
%%%%%%%%%%%%%计算STFT%%%%%%%%%%%%%%%%
        if (strcmp(tf_type, 'STFT'))
            gt = @(t) s^(-1/2)*pi^(-1/4).*exp(-t.^2/s^2/2);
            g0 = conj(gt(0));
            Reconstruction = FrequencySum/g0*df;
%%%%%%%%%%%%%计算MRM%%%%%%%%%%%%%%%%
        elseif (strcmp(tf_type, 'MRM'))
            gf = @(Omega) sqrt(2*s)*pi^(1/4)*exp(-(s*Omega).^2/2);
            g0 = conj(gf(0));
            Reconstruction = FrequencySum/g0;
%%%%%%%%%%%%%计算SST1和SST2%%%%%%%%%%%%%%%%
        elseif (strcmp(tf_type, 'SST1')||strcmp(tf_type, 'SST2'))
            gt = @(t) s^(-1/2)*pi^(-1/4).*exp(-t.^2/s^2/2);
            g0 = conj(gt(0));
            Reconstruction = FrequencySum/g0;
%%%%%%%%%%%%%计算SET1%%%%%%%%%%%%%%%%            
        elseif (strcmp(tf_type, 'SET1'))
            gf = @(Omega) sqrt(2*s)*pi^(1/4)*exp(-(s*Omega).^2/2);
            g0 = conj(gf(0));
            Reconstruction = FrequencySum/g0;
%%%%%%%%%%%%%计算SET2%%%%%%%%%%%%%%%%            
        elseif (strcmp(tf_type, 'SET2')||strcmp(tf_type, 'DET'))
            Reconstruction = FrequencySum;
%%%%%%%%%%%%%其它%%%%%%%%%%%%%%%%
        else
            error([direction,'不支持：',tf_type]);
        end  
    end
end