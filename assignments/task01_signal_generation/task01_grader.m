%% Автопроверка — Задание 1: Базовые сигналы
fprintf('\n╔══════════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 1: Генерация базовых сигналов ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n\n');
score=0; r={};

fs_r=1000; T_r=1; t_r=0:1/fs_r:T_r-1/fs_r;
f0_r=5; A_r=2;

%% x_sin
try
    assert(exist('x_sin','var')==1,'x_sin не найдена');
    x_sin_ref = A_r*sin(2*pi*f0_r*t_r);
    assert(max(abs(x_sin(:)'-x_sin_ref))<1e-9,'x_sin не совпадает с эталоном');
    score=score+3; r{end+1}='✅ [+3] x_sin: A·sin(2πf₀t) — ВЕРНО';
catch ME; r{end+1}=sprintf('❌ [+0] x_sin: %s',ME.message); end

%% x_rect
try
    assert(exist('x_rect','var')==1,'x_rect не найдена');
    x_rect_ref = A_r*square(2*pi*f0_r*t_r);
    assert(max(abs(x_rect(:)'-x_rect_ref))<1e-9,'x_rect не совпадает');
    score=score+2; r{end+1}='✅ [+2] x_rect: A·square(2πf₀t) — ВЕРНО';
catch ME; r{end+1}=sprintf('❌ [+0] x_rect: %s',ME.message); end

%% x_saw
try
    assert(exist('x_saw','var')==1,'x_saw не найдена');
    x_saw_ref = A_r*sawtooth(2*pi*f0_r*t_r);
    assert(max(abs(x_saw(:)'-x_saw_ref))<1e-9,'x_saw не совпадает');
    score=score+2; r{end+1}='✅ [+2] x_saw: A·sawtooth(2πf₀t) — ВЕРНО';
catch ME; r{end+1}=sprintf('❌ [+0] x_saw: %s',ME.message); end

%% x_step
try
    assert(exist('x_step','var')==1,'x_step не найдена');
    x_step_ref = A_r*double(t_r >= 0.3);
    assert(max(abs(x_step(:)'-x_step_ref))<1e-9,'x_step не совпадает');
    score=score+3; r{end+1}='✅ [+3] x_step: A·u(t-0.3) — ВЕРНО';
catch ME; r{end+1}=sprintf('❌ [+0] x_step: %s',ME.message); end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════\n\n',g);
