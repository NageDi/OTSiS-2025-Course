%% lab1_8_validator.m
%% Автоматическая проверка ключевых переменных — Лабораторная 1.8
%% Запускать ПОСЛЕ lab1_8_template.m

fprintf('\n╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║      ВАЛИДАТОР — ЛАБ 1.8: Спектральный анализ              ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

score = 0; results = {};

%% === Раздел А ===

%% А1: rmse_fourier
try
    assert(exist('rmse_fourier','var')==1,'rmse_fourier не найдена');
    assert(isvector(rmse_fourier),'rmse_fourier должна быть вектором');
    assert(length(rmse_fourier)==5,'Длина rmse_fourier должна быть 5 (для N=1,3,7,15,31)');
    % Погрешность должна убывать с ростом N
    assert(rmse_fourier(end) < rmse_fourier(1), ...
        'RMSE должна уменьшаться при росте числа гармоник');
    assert(all(rmse_fourier > 0), 'Все значения RMSE должны быть положительными');
    score=score+10;
    results{end+1}=sprintf('✅ [+10] rmse_fourier: 5 значений, монотонно убывает (min=%.4f)', min(rmse_fourier));
catch ME; results{end+1}=sprintf('❌ [+0] rmse_fourier: %s',ME.message); end

%% А2: X_dft (спектр прямоугольного/треугольного)
try
    assert(exist('X_dft','var')==1,'X_dft не найдена');
    assert(~isempty(X_dft),'X_dft пустой');
    assert(~isreal(X_dft),'X_dft должен быть комплексным (результат FFT)');
    score=score+10;
    results{end+1}='✅ [+10] X_dft: ДПФ вычислен';
catch ME; results{end+1}=sprintf('❌ [+0] X_dft: %s',ME.message); end

%% === Раздел Б ===

%% Б1: spectra_windows
try
    assert(exist('spectra_windows','var')==1,'spectra_windows не найдена');
    [r_sw, c_sw] = size(spectra_windows);
    assert(r_sw==4,'spectra_windows должна содержать 4 строки (4 окна)');
    assert(c_sw > 50,'spectra_windows должна иметь достаточно столбцов (N/2)');
    score=score+10;
    results{end+1}=sprintf('✅ [+10] spectra_windows: матрица %d×%d (4 окна)', r_sw, c_sw);
catch ME; results{end+1}=sprintf('❌ [+0] spectra_windows: %s',ME.message); end

%% === Раздел В ===

%% В1: x_restored + snr_db
try
    assert(exist('x_restored','var')==1,'x_restored не найдена');
    assert(exist('snr_db','var')==1,'snr_db не найдена');
    assert(isnumeric(snr_db) && isscalar(snr_db),'snr_db должна быть числом');
    assert(snr_db > 0, sprintf('SNR=%.2f дБ — слишком низкий, проверьте фильтрацию',snr_db));
    score=score+15;
    results{end+1}=sprintf('✅ [+15] x_restored: восстановлен | SNR = %.2f дБ', snr_db);
catch ME; results{end+1}=sprintf('❌ [+0] x_restored/snr_db: %s',ME.message); end

%% === Раздел Г ===

%% Г: freq_noise, snr_before, snr_after
try
    assert(exist('freq_noise','var')==1,'freq_noise не найдена');
    assert(exist('snr_before','var')==1,'snr_before не найдена');
    assert(exist('snr_after','var')==1,'snr_after не найдена');
    
    % Проверить, что найдены частоты 50 и 150 Гц (±5 Гц)
    found_50  = any(abs(freq_noise - 50)  < 5);
    found_150 = any(abs(freq_noise - 150) < 5);
    assert(found_50,  'Частота 50 Гц не обнаружена в freq_noise');
    assert(found_150, 'Частота 150 Гц не обнаружена в freq_noise');
    
    % SNR после фильтрации должен быть выше, чем до
    assert(snr_after > snr_before, ...
        sprintf('SNR_after=%.2f < SNR_before=%.2f — фильтр не улучшает сигнал', snr_after, snr_before));
    
    improvement = snr_after - snr_before;
    score=score+20;
    results{end+1}=sprintf('✅ [+20] Раздел Г: помехи найдены (50,150 Гц) | SNR: %.1f→%.1f дБ (+%.1f дБ)', ...
        snr_before, snr_after, improvement);
catch ME; results{end+1}=sprintf('❌ [+0] Раздел Г: %s',ME.message); end

%% === ИТОГ ===

max_auto = 65;  % 65 баллов автоматически, 35 — за выводы (вручную)
fprintf('────────────────────────────────────────────────────────────\n');
for i=1:length(results); fprintf('  %s\n',results{i}); end
fprintf('\n  АВТОМАТИЧЕСКИЕ БАЛЛЫ: %d / %d\n', score, max_auto);
fprintf('  (+ до 35 баллов за выводы и оформление — вручную)\n');
if score>=56; g='ОТЛИЧНО'; elseif score>=49; g='ХОРОШО'; elseif score>=36; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ПРЕДВАРИТЕЛЬНАЯ ОЦЕНКА: %s\n', g);
fprintf('════════════════════════════════════════════════════════════\n\n');
