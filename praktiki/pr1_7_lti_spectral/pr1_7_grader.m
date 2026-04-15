%% Автоматический проверщик — Пр 1.7
%% ЛДС и спектральный метод

fprintf('\n');
fprintf('╔═══════════════════════════════════════════════════════════════╗\n');
fprintf('║  АВТОМАТИЧЕСКАЯ ПРОВЕРКА — ПР 1.7: ЛДС и спектральный метод  ║\n');
fprintf('╚═══════════════════════════════════════════════════════════════╝\n\n');

score = 0;
results = {};

%% --- ПРОВЕРКА 1: H_lpf ---
try
    assert(exist('H_lpf','var')==1, 'H_lpf не найдена');
    assert(isa(H_lpf,'tf'), 'H_lpf должна быть tf-объектом');
    
    wc_ref = 2*pi*100;
    [num_s, den_s] = tfdata(H_lpf, 'v');
    % Нормализуем: den(1) должен быть 1
    num_n = num_s / den_s(1);  den_n = den_s / den_s(1);
    
    assert(abs(num_n(end) - wc_ref) / wc_ref < 0.01, ...
        sprintf('Числитель H_lpf: ожидалось %.1f, получено %.1f', wc_ref, num_n(end)));
    assert(abs(den_n(end) - wc_ref) / wc_ref < 0.01, ...
        sprintf('Знаменатель H_lpf: ожидалось %.1f, получено %.1f', wc_ref, den_n(end)));
    
    score = score + 1;
    results{end+1} = '✅ [+1] H_lpf: передаточная функция корректна';
catch ME
    results{end+1} = sprintf('❌ [+0] H_lpf: %s', ME.message);
end

%% --- ПРОВЕРКА 2: y_lpf (реакция на импульс) ---
try
    assert(exist('y_lpf','var')==1, 'y_lpf не найдена');
    
    % Референсное решение
    fs_ref = 10000; T_ref = 0.1;
    t_ref = 0:1/fs_ref:T_ref-1/fs_ref;
    x_ref = double(t_ref >= 0.02 & t_ref < 0.03);
    wc_r  = 2*pi*100;
    H_ref = tf([wc_r],[1 wc_r]);
    y_ref = lsim(H_ref, x_ref, t_ref);
    y_ref = y_ref(:)';
    
    y_s = y_lpf(:)';
    assert(length(y_s) == length(y_ref), ...
        sprintf('Длина y_lpf = %d, ожидалось %d', length(y_s), length(y_ref)));
    
    rmse = sqrt(mean((y_s - y_ref).^2));
    assert(rmse < 0.05, sprintf('y_lpf отличается от эталона, RMSE = %.4f', rmse));
    
    score = score + 2;
    results{end+1} = sprintf('✅ [+2] y_lpf: реакция корректна (RMSE = %.5f)', rmse);
catch ME
    results{end+1} = sprintf('❌ [+0] y_lpf: %s', ME.message);
end

%% --- ПРОВЕРКА 3: Y_fft (спектральный метод) ---
try
    assert(exist('Y_fft','var')==1, 'Y_fft не найдена');
    
    % Эталон: составляющая 300 Гц должна быть подавлена относительно 50 Гц
    fs_r = 2000; T_r = 0.1; N_r = round(T_r*fs_r);
    t_r  = (0:N_r-1)/fs_r;
    x_r  = sin(2*pi*50*t_r) + 0.5*sin(2*pi*300*t_r);
    f_r  = (0:N_r-1)*fs_r/N_r;
    X_r  = fft(x_r, N_r);
    wc_r = 2*pi*100;
    H_r  = wc_r ./ (1j*2*pi*f_r + wc_r);
    Y_r  = X_r .* H_r;
    
    assert(length(Y_fft) == length(Y_r), 'Длина Y_fft не совпадает с ожидаемой');
    rmse_fft = sqrt(mean(abs(Y_fft - Y_r).^2));
    assert(rmse_fft < 50, sprintf('Y_fft сильно отличается от эталона'));
    
    score = score + 2;
    results{end+1} = '✅ [+2] Y_fft: спектральный метод применён корректно';
catch ME
    results{end+1} = sprintf('❌ [+0] Y_fft: %s', ME.message);
end

%% --- ПРОВЕРКА 4: y_filtered ---
try
    assert(exist('y_filtered','var')==1, 'y_filtered не найдена');
    
    fs_r = 2000; T_r = 0.1; N_r = round(T_r*fs_r);
    t_r  = (0:N_r-1)/fs_r;
    x_r  = sin(2*pi*50*t_r) + 0.5*sin(2*pi*300*t_r);
    f_r  = (0:N_r-1)*fs_r/N_r;
    wc_r = 2*pi*100;
    H_r  = wc_r ./ (1j*2*pi*f_r + wc_r);
    y_r  = real(ifft(fft(x_r).*H_r));
    
    y_f = y_filtered(:)';
    assert(length(y_f)==length(y_r), 'Длина y_filtered не совпадает');
    rmse_yf = sqrt(mean((y_f - y_r).^2));
    assert(rmse_yf < 0.1, sprintf('y_filtered RMSE = %.4f', rmse_yf));
    
    score = score + 2;
    results{end+1} = sprintf('✅ [+2] y_filtered: корректно (RMSE=%.5f)', rmse_yf);
catch ME
    results{end+1} = sprintf('❌ [+0] y_filtered: %s', ME.message);
end

%% --- ПРОВЕРКА 5: Полюса и устойчивость ---
try
    assert(exist('p1','var')==1, 'p1 не найдена');
    assert(exist('p2','var')==1, 'p2 не найдена');
    assert(exist('p3','var')==1, 'p3 не найдена');
    
    % Проверка полюсов H1: -1, -2
    p1_ref = sort([-1; -2]);
    p1_s   = sort(p1);
    assert(max(abs(p1_s - p1_ref)) < 0.01, 'p1 неверно');
    
    % Проверка H2: полюса с Re>0
    assert(any(real(p2) > 0), 'p2: неустойчивая система должна иметь полюса с Re>0');
    
    % Проверка устойчивости
    assert(exist('stable1','var')==1 && logical(stable1)==true,  'stable1 должна быть true');
    assert(exist('stable2','var')==1 && logical(stable2)==false, 'stable2 должна быть false');
    
    score = score + 3;
    results{end+1} = '✅ [+3] Полюса и флаги устойчивости верны';
catch ME
    results{end+1} = sprintf('❌ [+0] Полюса/устойчивость: %s', ME.message);
end

%% --- ИТОГ ---
fprintf('────────────────────────────────────────────────────────────\n');
for i = 1:length(results); fprintf('  %s\n', results{i}); end
fprintf('\n  ИТОГОВЫЙ БАЛЛ: %d / 10\n', score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n', g);
fprintf('════════════════════════════════════════════════════════════\n\n');
