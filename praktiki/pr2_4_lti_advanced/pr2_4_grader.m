%% Автоматический проверщик — Пр 2.4
%% ЛДС: импульсная/переходная характеристика, Боде, пространство состояний

fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║      ПРОВЕРКА — ПР 2.4: ЛДС (2-й порядок)               ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

score = 0; results = {};

% Эталонные параметры
zeta_r = 0.3; wn_r = 2*pi*10;
H_ref  = tf(wn_r^2, [1, 2*zeta_r*wn_r, wn_r^2]);
[g_r, t_r] = step(H_ref);
g_ss_r = g_r(end);
[g_max_r,~] = max(g_r);
overshoot_ref  = (g_max_r/g_ss_r - 1)*100;
i10 = find(g_r>=0.1*g_ss_r,1,'first');
i90 = find(g_r>=0.9*g_ss_r,1,'first');
rise_ref = t_r(i90) - t_r(i10);

%% Проверка 1: overshoot
try
    assert(exist('overshoot','var')==1,'overshoot не найдена');
    assert(abs(overshoot - overshoot_ref) < 2, ...
        sprintf('overshoot=%.2f%%, эталон=%.2f%%', overshoot, overshoot_ref));
    score=score+2; results{end+1}=sprintf('✅ [+2] overshoot = %.2f%%', overshoot);
catch ME; results{end+1}=sprintf('❌ [+0] overshoot: %s',ME.message); end

%% Проверка 2: rise_time
try
    assert(exist('rise_time','var')==1,'rise_time не найдена');
    assert(abs(rise_time - rise_ref) < 0.01, ...
        sprintf('rise_time=%.4f с, эталон=%.4f с', rise_time, rise_ref));
    score=score+2; results{end+1}=sprintf('✅ [+2] rise_time = %.4f с', rise_time);
catch ME; results{end+1}=sprintf('❌ [+0] rise_time: %s',ME.message); end

%% Проверка 3: sys_ss существует и матрицы корректны
try
    assert(exist('sys_ss','var')==1,'sys_ss не найдена');
    assert(isa(sys_ss,'ss'),'sys_ss должна быть ss-объектом');
    A_r = sys_ss.A; eig_r = eig(A_r);
    assert(all(real(eig_r)<0),'Собственные числа A должны быть в левой полуплоскости');
    score=score+3; results{end+1}='✅ [+3] sys_ss: ss-объект, собственные числа верны';
catch ME; results{end+1}=sprintf('❌ [+0] sys_ss: %s',ME.message); end

%% Проверка 4: eig_A
try
    assert(exist('eig_A','var')==1,'eig_A не найдена');
    eig_ref_val = eig(H_ref);  % tf→ss внутри
    assert(length(eig_A)==2,'Должно быть 2 собственных числа');
    assert(all(real(eig_A)<0),'Все собственные числа должны быть с Re<0');
    score=score+1; results{end+1}='✅ [+1] eig_A: размерность и знаки верны';
catch ME; results{end+1}=sprintf('❌ [+0] eig_A: %s',ME.message); end

%% Проверка 5: mag_check_vec (АЧХ при ζ=0.3)
try
    assert(exist('mag_check_vec','var')==1,'mag_check_vec не найдена');
    [m_r,~,w_r] = bode(H_ref);
    m_r_v = squeeze(m_r);
    assert(abs(length(mag_check_vec)-length(m_r_v))<5,'Длина mag_check_vec не совпадает');
    score=score+2; results{end+1}='✅ [+2] mag_check_vec: АЧХ вычислена';
catch ME; results{end+1}=sprintf('❌ [+0] mag_check_vec: %s',ME.message); end

%% Итог
fprintf('────────────────────────────────────────────────────────────\n');
for i=1:length(results); fprintf('  %s\n',results{i}); end
fprintf('\n  ИТОГОВЫЙ БАЛЛ: %d / 10\n', score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════════════\n\n',g);
