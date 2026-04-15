%% lab2_7_validator.m
%% Автоматическая проверка — Лабораторная 2.7: Импульсно-модулированные сигналы

fprintf('\n╔═══════════════════════════════════════════════════════════════╗\n');
fprintf('║     ВАЛИДАТОР — ЛАБ 2.7: Импульсно-модулированные сигналы   ║\n');
fprintf('╚═══════════════════════════════════════════════════════════════╝\n\n');

score = 0; results = {};

%% === Раздел А: PAM ===

%% А1: snr_fs1, snr_fs2, snr_fs3
try
    vars = {'snr_fs1','snr_fs2','snr_fs3'};
    for vi=1:3
        assert(exist(vars{vi},'var')==1, sprintf('%s не найдена', vars{vi}));
        assert(isnumeric(eval(vars{vi})) && isscalar(eval(vars{vi})), ...
            sprintf('%s должна быть числом',vars{vi}));
    end
    
    % Ключевое: при алиасинге SNR должен быть существенно ниже
    % snr_fs1 (50 Гц, теорема выполнена) > snr_fs2 (30 Гц, алиасинг)
    assert(snr_fs1 > snr_fs2 + 5, ...
        sprintf('При f_s=50 SNR=%.1f дБ, при f_s=30 SNR=%.1f дБ — разница < 5 дБ, алиасинг не показан', ...
        snr_fs1, snr_fs2));
    
    score=score+15;
    results{end+1}=sprintf('✅ [+15] SNR: fs50=%.1f дБ, fs30=%.1f дБ, fs100=%.1f дБ — алиасинг корректно показан', ...
        snr_fs1, snr_fs2, snr_fs3);
catch ME; results{end+1}=sprintf('❌ [+0] snr_fs: %s',ME.message); end

%% А2: x_PAM
try
    assert(exist('x_PAM','var')==1,'x_PAM не найдена');
    assert(isvector(x_PAM),'x_PAM должна быть вектором');
    assert(length(x_PAM) > 100,'x_PAM слишком короткий');
    % PAM сигнал не должен быть непрерывным — проверяем наличие нулей
    zero_ratio = sum(x_PAM == 0) / length(x_PAM);
    assert(zero_ratio > 0.3 && zero_ratio < 0.9, ...
        sprintf('PAM: доля нулей = %.1f%% — должна быть 30-90%% (скважность)', zero_ratio*100));
    score=score+10;
    results{end+1}=sprintf('✅ [+10] x_PAM: длина=%d, доля нулей=%.1f%%', length(x_PAM), zero_ratio*100);
catch ME; results{end+1}=sprintf('❌ [+0] x_PAM: %s',ME.message); end

%% === Раздел Б: ШИМ ===

%% Б1: pwm_signal
try
    assert(exist('pwm_signal','var')==1,'pwm_signal не найдена');
    % ШИМ — бинарный сигнал (только 0 и 1)
    unique_vals = unique(pwm_signal);
    assert(length(unique_vals) <= 2, 'pwm_signal должен быть бинарным (0 и 1)');
    assert(max(pwm_signal) == 1 && min(pwm_signal) == 0, 'pwm_signal: значения должны быть 0 и 1');
    score=score+10;
    results{end+1}='✅ [+10] pwm_signal: бинарный ШИМ сигнал корректен';
catch ME; results{end+1}=sprintf('❌ [+0] pwm_signal: %s',ME.message); end

%% Б1: m_restored_pwm
try
    assert(exist('m_restored_pwm','var')==1,'m_restored_pwm не найдена');
    assert(isvector(m_restored_pwm),'m_restored_pwm должна быть вектором');
    % Восстановленный сигнал должен быть в диапазоне [-1, 1]
    assert(max(abs(m_restored_pwm)) < 2, 'Восстановленный сигнал имеет слишком большую амплитуду');
    score=score+5;
    results{end+1}='✅ [+5] m_restored_pwm: сигнал восстановлен через ФНЧ';
catch ME; results{end+1}=sprintf('❌ [+0] m_restored_pwm: %s',ME.message); end

%% Б2: THD_pwm
try
    assert(exist('THD_pwm','var')==1,'THD_pwm не найдена');
    assert(isnumeric(THD_pwm) && isscalar(THD_pwm),'THD_pwm должна быть числом');
    assert(THD_pwm > 0 && THD_pwm < 200, sprintf('THD=%.2f%% — вне допустимого диапазона',THD_pwm));
    score=score+10;
    results{end+1}=sprintf('✅ [+10] THD_pwm = %.2f%%', THD_pwm);
catch ME; results{end+1}=sprintf('❌ [+0] THD_pwm: %s',ME.message); end

%% === Раздел В: ФИМ ===

%% В: ppm_times
try
    assert(exist('ppm_times','var')==1,'ppm_times не найдена');
    assert(isvector(ppm_times),'ppm_times должна быть вектором');
    assert(length(ppm_times) >= 4,'ppm_times: должно быть не менее 4 импульсов');
    % Импульсы должны быть равномерно распределены с небольшими отклонениями
    diffs = diff(ppm_times);
    mean_T = mean(diffs);
    var_T  = std(diffs)/mean_T;
    assert(var_T > 0.01 && var_T < 0.6, ...
        sprintf('ppm_times: вариация межимпульсных интервалов = %.2f — не соответствует ФИМ', var_T));
    score=score+10;
    results{end+1}=sprintf('✅ [+10] ppm_times: %d импульсов, вариация = %.2f', length(ppm_times), var_T);
catch ME; results{end+1}=sprintf('❌ [+0] ppm_times: %s',ME.message); end

%% === Раздел Г: Канал с шумом ===

%% Г: rmse_snr20, rmse_snr10, rmse_snr5
try
    vars_g = {'rmse_snr20','rmse_snr10','rmse_snr5'};
    for vi=1:3
        assert(exist(vars_g{vi},'var')==1, sprintf('%s не найдена',vars_g{vi}));
    end
    rmse_vals = [rmse_snr20, rmse_snr10, rmse_snr5];
    assert(all(rmse_vals > 0), 'RMSE должны быть положительными');
    assert(rmse_snr20 < rmse_snr5, ...
        'При SNR=20 дБ ошибка должна быть меньше, чем при SNR=5 дБ');
    score=score+10;
    results{end+1}=sprintf('✅ [+10] RMSE: snr20=%.4f, snr10=%.4f, snr5=%.4f', ...
        rmse_snr20, rmse_snr10, rmse_snr5);
catch ME; results{end+1}=sprintf('❌ [+0] rmse_snrXX: %s',ME.message); end

%% === ИТОГ ===

max_auto = 70;
fprintf('────────────────────────────────────────────────────────────\n');
for i=1:length(results); fprintf('  %s\n',results{i}); end
fprintf('\n  АВТОМАТИЧЕСКИЕ БАЛЛЫ: %d / %d\n', score, max_auto);
fprintf('  (+ до 30 баллов за выводы и ответы — вручную)\n');
if score>=61; g='ОТЛИЧНО'; elseif score>=50; g='ХОРОШО'; elseif score>=39; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ПРЕДВАРИТЕЛЬНАЯ ОЦЕНКА: %s\n', g);
fprintf('════════════════════════════════════════════════════════════\n\n');
