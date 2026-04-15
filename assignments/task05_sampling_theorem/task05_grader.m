%% Автопроверка — Задание 5: Теорема Котельникова
fprintf('\n╔════════════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 5: Дискретизация и алиасинг     ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');
score=0; r={};

%% snr_fs1 — должен быть > 20 дБ (теорема выполнена)
try
    assert(exist('snr_fs1','var')==1,'snr_fs1 не найдена');
    assert(snr_fs1 > 20, sprintf('snr_fs1=%.1f дБ — слишком мал (fs=250 > 200 Гц, ожидалось >20 дБ)',snr_fs1));
    score=score+3; r{end+1}=sprintf('✅ [+3] snr_fs1 = %.1f дБ (теорема выполнена)',snr_fs1);
catch ME; r{end+1}=sprintf('❌ [+0] snr_fs1: %s',ME.message); end

%% snr_fs2 — должен быть << snr_fs1 (алиасинг)
try
    assert(exist('snr_fs2','var')==1,'snr_fs2 не найдена');
    assert(exist('snr_fs1','var')==1);
    assert(snr_fs2 < snr_fs1 - 10, ...
        sprintf('snr_fs2=%.1f дБ — должен быть как минимум на 10 дБ меньше snr_fs1=%.1f дБ',snr_fs2,snr_fs1));
    score=score+4; r{end+1}=sprintf('✅ [+4] snr_fs2 = %.1f дБ — алиасинг показан (разница %.1f дБ)',...
        snr_fs2, snr_fs1-snr_fs2);
catch ME; r{end+1}=sprintf('❌ [+0] snr_fs2: %s',ME.message); end

%% snr_fs3 — должен быть > snr_fs1
try
    assert(exist('snr_fs3','var')==1,'snr_fs3 не найдена');
    assert(snr_fs3 > 20, sprintf('snr_fs3=%.1f дБ — должен быть высоким (fs=500 Гц)',snr_fs3));
    score=score+1; r{end+1}=sprintf('✅ [+1] snr_fs3 = %.1f дБ (перекрытие)',snr_fs3);
catch ME; r{end+1}=sprintf('❌ [+0] snr_fs3: %s',ME.message); end

%% f_alias
try
    assert(exist('f_alias','var')==1,'f_alias не найдена');
    % При fs2=120, f=100: alias = |100 - 120| = 20 Гц
    f_alias_ref = 20;
    assert(abs(f_alias - f_alias_ref) < 2, ...
        sprintf('f_alias=%.1f Гц, ожидалось %.1f Гц',f_alias,f_alias_ref));
    score=score+2; r{end+1}=sprintf('✅ [+2] f_alias = %.1f Гц (верно)',f_alias);
catch ME; r{end+1}=sprintf('❌ [+0] f_alias: %s',ME.message); end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════\n\n',g);
