%% Автопроверка — Задание 12: Канал с шумом, BER
fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  ПРОВЕРКА — ЗАДАНИЕ 12: BPSK канал с шумом (BER)        ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');
score=0; r={};

%% bits
try
    assert(exist('bits','var')==1,'bits не найдена');
    assert(length(bits)==1000,'Длина bits должна быть 1000');
    assert(all(bits==0|bits==1),'bits должна содержать только 0 и 1');
    score=score+1; r{end+1}='✅ [+1] bits: бинарный вектор 1000 бит';
catch ME; r{end+1}=sprintf('❌ [+0] bits: %s',ME.message); end

%% x_bpsk — проверить мощность и наличие
try
    assert(exist('x_bpsk','var')==1,'x_bpsk не найдена');
    P_bpsk = mean(x_bpsk.^2);
    assert(abs(P_bpsk - 0.5) < 0.1, sprintf('Мощность x_bpsk=%.3f, ожидалось ≈0.5',P_bpsk));
    score=score+2; r{end+1}=sprintf('✅ [+2] x_bpsk: мощность = %.3f',P_bpsk);
catch ME; r{end+1}=sprintf('❌ [+0] x_bpsk: %s',ME.message); end

%% BER_measured — должен убывать с ростом Eb/N0
try
    assert(exist('BER_measured','var')==1,'BER_measured не найдена');
    assert(length(BER_measured)==6,'BER_measured должна иметь 6 элементов');
    assert(BER_measured(end) < BER_measured(1), ...
        'BER должен убывать с ростом Eb/N0');
    assert(BER_measured(end) < 0.1, sprintf('BER при 10 дБ=%.4f — слишком высокий', BER_measured(end)));
    score=score+3; r{end+1}=sprintf('✅ [+3] BER_measured убывает: [%.3f → %.5f]', ...
        BER_measured(1), BER_measured(end));
catch ME; r{end+1}=sprintf('❌ [+0] BER_measured: %s',ME.message); end

%% BER_theory — erfc формула
try
    assert(exist('BER_theory','var')==1,'BER_theory не найдена');
    EbN0_list = [0,2,4,6,8,10];
    for i=1:6
        BER_t_ref = erfc(sqrt(10^(EbN0_list(i)/10)))/2;
        assert(abs(BER_theory(i)-BER_t_ref)/BER_t_ref < 0.01, ...
            sprintf('BER_theory(%d дБ)=%.4e, эталон=%.4e',EbN0_list(i),BER_theory(i),BER_t_ref));
    end
    score=score+2; r{end+1}='✅ [+2] BER_theory: формула erfc верна';
catch ME; r{end+1}=sprintf('❌ [+0] BER_theory: %s',ME.message); end

%% BER_simulink (бонус — если есть)
if exist('BER_simulink','var')==1
    BER_sim_ref = erfc(sqrt(10^(6/10)))/2;
    if abs(BER_simulink - BER_sim_ref)/BER_sim_ref < 0.5
        score=score+2; r{end+1}=sprintf('✅ [+2 бонус] BER_simulink = %.4e (Simulink)',BER_simulink);
    else
        r{end+1}=sprintf('⚠ BER_simulink = %.4e (расхождение с теорией %.0f%%)', ...
            BER_simulink, abs(BER_simulink-BER_sim_ref)/BER_sim_ref*100);
    end
else
    r{end+1}='ℹ BER_simulink не найдена (Simulink часть не выполнена — потеря 2 баллов)';
end

fprintf('────────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',min(score,10));
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n══════════════════════════════════════════════════════════\n\n',g);
