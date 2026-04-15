%% Автоматический проверщик — Пр 2.6
%% ДПФ, Z-преобразование, дискретная свёртка

fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║   ПРОВЕРКА — ПР 2.6: ДПФ, Z-преобразование, свёртка     ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

score = 0; results = {};

%% Проверка 1: X_dft
try
    assert(exist('X_dft','var')==1,'X_dft не найдена');
    N_r=64; n_r=0:N_r-1;
    x_r=cos(2*pi*0.1*n_r)+0.5*cos(2*pi*0.3*n_r);
    X_r=fft(x_r, N_r);
    rmse_dft=sqrt(mean(abs(X_dft(:)'-X_r).^2));
    assert(rmse_dft<1e-6, sprintf('X_dft: RMSE=%.2e',rmse_dft));
    score=score+2; results{end+1}='✅ [+2] X_dft: ДПФ вычислен верно';
catch ME; results{end+1}=sprintf('❌ [+0] X_dft: %s',ME.message); end

%% Проверка 2: X_padded (zero-padding)
try
    assert(exist('X_padded','var')==1,'X_padded не найдена');
    assert(length(X_padded)==512,'Длина X_padded должна быть 512');
    N_r=64; n_r=0:N_r-1;
    x_r=cos(2*pi*0.1*n_r)+0.5*cos(2*pi*0.3*n_r);
    X_p_ref=fft(x_r, 512);
    rmse_p=sqrt(mean(abs(X_padded(:)'-X_p_ref).^2));
    assert(rmse_p<1e-6,'X_padded не совпадает с эталоном');
    score=score+1; results{end+1}='✅ [+1] X_padded: zero-padding корректен';
catch ME; results{end+1}=sprintf('❌ [+0] X_padded: %s',ME.message); end

%% Проверка 3: b_filt, a_filt (Баттерворт)
try
    assert(exist('b_filt','var')==1 && exist('a_filt','var')==1,'b_filt/a_filt не найдены');
    [b_r,a_r]=butter(3,0.2);
    assert(max(abs(b_filt(:)-b_r(:)))<1e-8,'b_filt не совпадает');
    assert(max(abs(a_filt(:)-a_r(:)))<1e-8,'a_filt не совпадает');
    score=score+2; results{end+1}='✅ [+2] b_filt/a_filt: фильтр Баттерворта верен';
catch ME; results{end+1}=sprintf('❌ [+0] b_filt/a_filt: %s',ME.message); end

%% Проверка 4: y_dig (применение фильтра)
try
    assert(exist('y_dig','var')==1,'y_dig не найдена');
    fs_d=1000; t_d=0:1/fs_d:0.5-1/fs_d;
    x_n=sin(2*pi*80*t_d)+sin(2*pi*400*t_d);
    [b_r,a_r]=butter(3,0.2);
    y_r=filter(b_r,a_r,x_n);
    rmse_y=sqrt(mean((y_dig(:)'-y_r).^2));
    assert(rmse_y<0.01, sprintf('y_dig: RMSE=%.4f',rmse_y));
    % Убедиться, что 400 Гц подавлена: амплитуда в конце сигнала мала
    assert(max(abs(y_dig(end-100:end)))<0.15,'400 Гц не подавлена должным образом');
    score=score+2; results{end+1}=sprintf('✅ [+2] y_dig: фильтрация верна (RMSE=%.5f)',rmse_y);
catch ME; results{end+1}=sprintf('❌ [+0] y_dig: %s',ME.message); end

%% Проверка 5: conv_result (свёртка)
try
    assert(exist('conv_result','var')==1,'conv_result не найдена');
    x1_r=[1,2,3,2,1]; x2_r=[1,-1,1,-1];
    y_ref_c=conv(x1_r,x2_r);
    assert(isequal(size(conv_result(:)',size(y_ref_c(:)')), 1) || ...
           length(conv_result)==length(y_ref_c), 'Longth mismatch');
    assert(max(abs(conv_result(:)'-y_ref_c))<1e-10,'Свёртка не совпадает с эталоном');
    score=score+2; results{end+1}='✅ [+2] conv_result: свёртка верна';
catch ME; results{end+1}=sprintf('❌ [+0] conv_result: %s',ME.message); end

%% Проверка 6: y_manual (ручная свёртка)
try
    assert(exist('y_manual','var')==1,'y_manual не найдена');
    x1_r=[1,2,3,2,1]; x2_r=[1,-1,1,-1];
    y_ref_m=conv(x1_r,x2_r);
    assert(max(abs(y_manual(:)'-y_ref_m))<1e-6,'y_manual не совпадает с conv()');
    score=score+1; results{end+1}='✅ [+1] y_manual: ручная свёртка верна';
catch ME; results{end+1}=sprintf('❌ [+0] y_manual: %s',ME.message); end

%% Итог
fprintf('────────────────────────────────────────────────────────────\n');
for i=1:length(results); fprintf('  %s\n',results{i}); end
fprintf('\n  ИТОГОВЫЙ БАЛЛ: %d / 10\n', score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════════════\n\n',g);
