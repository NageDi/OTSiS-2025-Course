%% Автоматический проверщик — Пр 1.6
%% Запускать ПОСЛЕ pr1_6_student.m (переменные должны быть в workspace)
%%
%% Использование:
%%   1. Запустите pr1_6_student.m (заполненный студентом)
%%   2. Запустите pr1_6_grader.m
%%   3. Прочитайте итоговый отчёт

clear_grader = false; % true — очистить workspace перед проверкой (если нужно)

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║   АВТОМАТИЧЕСКАЯ ПРОВЕРКА — ПР 1.6: Корреляционный анализ ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

score = 0;
max_score = 10;
results = {};

%% ================================================================
%% ПРОВЕРКА 1. Переменная period_acf
%% ================================================================
check_name = 'Часть 1: Определение периода (period_acf)';
try
    assert(exist('period_acf', 'var') == 1, ...
        'Переменная period_acf не найдена в workspace');
    
    true_period = 1/50;  % 0.02 с
    tolerance   = 0.005; % ±5 мс допуск
    
    err = abs(period_acf - true_period);
    assert(err <= tolerance, ...
        sprintf('Ошибка: period_acf = %.4f с, истина = %.4f с, допуск = ±%.4f с', ...
        period_acf, true_period, tolerance));
    
    score = score + 2;
    results{end+1} = sprintf('✅ [+2] %s — ПРОЙДЕНО (%.4f с)', check_name, period_acf);
catch ME
    results{end+1} = sprintf('❌ [+0] %s — ОШИБКА: %s', check_name, ME.message);
end

%% ================================================================
%% ПРОВЕРКА 2. Нормированная АКФ R_norm
%% ================================================================
check_name = 'Часть 1: Нормированная АКФ (R_norm)';
try
    assert(exist('R_norm', 'var') == 1, ...
        'Переменная R_norm не найдена');
    
    % Должна быть = 1 при tau = 0
    mid = ceil(length(R_norm)/2);
    assert(abs(R_norm(mid) - 1.0) < 0.05, ...
        sprintf('R_norm в нуле = %.3f, ожидалось ≈ 1.0', R_norm(mid)));
    
    % Не должна превышать 1
    assert(max(abs(R_norm)) <= 1.05, ...
        'R_norm превышает 1 — вероятно, не нормированная');
    
    score = score + 1;
    results{end+1} = sprintf('✅ [+1] %s — ПРОЙДЕНО', check_name);
catch ME
    results{end+1} = sprintf('❌ [+0] %s — ОШИБКА: %s', check_name, ME.message);
end

%% ================================================================
%% ПРОВЕРКА 3. Задержка delay_found
%% ================================================================
check_name = 'Часть 2: Определение задержки (delay_found)';
try
    assert(exist('delay_found', 'var') == 1, ...
        'Переменная delay_found не найдена');
    
    true_delay  = 0.05;   % с
    tolerance_d = 0.002;  % ±2 мс
    
    err_d = abs(delay_found - true_delay);
    assert(err_d <= tolerance_d, ...
        sprintf('Ошибка: delay_found = %.4f с, истина = %.4f с, допуск = ±%.4f с', ...
        delay_found, true_delay, tolerance_d));
    
    score = score + 3;
    results{end+1} = sprintf('✅ [+3] %s — ПРОЙДЕНО (%.4f с, погрешность %.4f с)', ...
        check_name, delay_found, err_d);
catch ME
    results{end+1} = sprintf('❌ [+0] %s — ОШИБКА: %s', check_name, ME.message);
end

%% ================================================================
%% ПРОВЕРКА 4. ВКФ (xcorr) — R_xy существует и симметрична
%% ================================================================
check_name = 'Часть 2: Вычисление ВКФ (R_xy)';
try
    assert(exist('R_xy', 'var') == 1, 'Переменная R_xy не найдена');
    assert(length(R_xy) > 100, 'R_xy слишком короткий — xcorr не вызвана?');
    assert(max(R_xy) > 0, 'Максимум R_xy ≤ 0');
    
    score = score + 1;
    results{end+1} = sprintf('✅ [+1] %s — ПРОЙДЕНО', check_name);
catch ME
    results{end+1} = sprintf('❌ [+0] %s — ОШИБКА: %s', check_name, ME.message);
end

%% ================================================================
%% ПРОВЕРКА 5. ВСП — Pxy существует
%% ================================================================
check_name = 'Часть 3: ВСП через cpsd (Pxy, f_cpsd)';
try
    assert(exist('Pxy', 'var') == 1, 'Переменная Pxy не найдена');
    assert(exist('f_cpsd', 'var') == 1, 'Переменная f_cpsd не найдена');
    assert(length(Pxy) > 10, 'Pxy слишком короткий — cpsd не вызвана?');
    assert(~isreal(Pxy), 'Pxy вещественный — cpsd должна возвращать комплексный результат');
    
    % Проверка линейности фазы (грубая)
    phase = unwrap(angle(Pxy));
    f_valid = f_cpsd(f_cpsd > 1 & f_cpsd < fs/4);
    ph_valid = phase(f_cpsd > 1 & f_cpsd < fs/4);
    p = polyfit(f_valid, ph_valid, 1);
    tau_from_phase = -p(1) / (2*pi);
    
    if abs(tau_from_phase - 0.05) < 0.01
        score = score + 3;
        results{end+1} = sprintf('✅ [+3] %s — ПРОЙДЕНО (τ из фазы = %.4f с)', ...
            check_name, tau_from_phase);
    else
        score = score + 1;  % частичный балл
        results{end+1} = sprintf('⚠️ [+1] %s — ЧАСТИЧНО (Pxy вычислена, но τ из фазы = %.4f с ≠ 0.0500 с)', ...
            check_name, tau_from_phase);
    end
catch ME
    results{end+1} = sprintf('❌ [+0] %s — ОШИБКА: %s', check_name, ME.message);
end

%% ================================================================
%% ИТОГОВЫЙ ОТЧЁТ
%% ================================================================
fprintf('────────────────────────────────────────────────────────────\n');
fprintf('РЕЗУЛЬТАТЫ ПРОВЕРКИ:\n\n');
for i = 1:length(results)
    fprintf('  %s\n', results{i});
end

fprintf('\n────────────────────────────────────────────────────────────\n');
fprintf('  ИТОГОВЫЙ БАЛЛ: %d / %d\n', score, max_score);
fprintf('────────────────────────────────────────────────────────────\n');

if     score >= 9; grade = 'ОТЛИЧНО (5)';
elseif score >= 7; grade = 'ХОРОШО (4)';
elseif score >= 5; grade = 'УДОВЛЕТВОРИТЕЛЬНО (3)';
else;              grade = 'НЕУДОВЛЕТВОРИТЕЛЬНО (2)';
end
fprintf('  ОЦЕНКА: %s\n', grade);
fprintf('════════════════════════════════════════════════════════════\n\n');
