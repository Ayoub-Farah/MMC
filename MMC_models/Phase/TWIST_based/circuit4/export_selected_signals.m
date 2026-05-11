%% Export ciblé MMC → CSV compact
% Fenêtre temporelle : 0 à 0.5 s
% Décimation : 1 point sur 20

filename = 'mmc_selected_signals_0p5s_decim15.csv';

t_full = out.tout(:);

t_max = 0.5;
decim_factor = 1;

idx_time = find(t_full <= t_max);
idx_export = idx_time(1:decim_factor:end);

t = t_full(idx_export);

data = t;
headers = {'time'};

%% =========================
%% 1. Capacitor voltages vc_1 → vc_10
%% =========================

for k = 1:10
    varName = sprintf('vc_%d', k);
    sig = out.get(varName);

    if isstruct(sig)
        y_full = sig.signals.values;
    elseif isa(sig,'timeseries')
        y_full = sig.Data;
    else
        warning('%s ignoré : type non reconnu', varName);
        continue;
    end

    y_full = squeeze(y_full);

    if size(y_full,1) == length(t_full)
        y = y_full(idx_export,:);
        data = [data y(:)];
        headers{end+1} = sprintf('vc_%d', k);

    elseif size(y_full,2) == length(t_full)
        y_full = y_full.';
        y = y_full(idx_export,:);
        data = [data y(:)];
        headers{end+1} = sprintf('vc_%d', k);

    else
        warning('%s ignoré : dimension incohérente [%s]', varName, num2str(size(y_full)));
    end
end

%% =========================
%% 2. Duty cycles g_u, g_L
%% =========================

duty_vars = {'g_u','g_L'};

for i = 1:length(duty_vars)

    varName = duty_vars{i};
    sig = out.get(varName);

    if isstruct(sig)
        y_full = sig.signals.values;
    elseif isa(sig,'timeseries')
        y_full = sig.Data;
    else
        warning('%s ignoré : type non reconnu', varName);
        continue;
    end

    y_full = squeeze(y_full);

    if size(y_full,1) == length(t_full)
        y = y_full(idx_export,:);

    elseif size(y_full,2) == length(t_full)
        y_full = y_full.';
        y = y_full(idx_export,:);

    else
        warning('%s ignoré : dimension incohérente [%s]', varName, num2str(size(y_full)));
        continue;
    end

    for k = 1:size(y,2)
        data = [data y(:,k)];
        headers{end+1} = sprintf('%s_%d', varName, k);
    end
end

%% =========================
%% 3. Variables scalaires
%% =========================

scalar_vars = {
    'vm_l'
    'vm_u'
    'i_u'
    'i_l'
};

for i = 1:length(scalar_vars)

    varName = scalar_vars{i};
    sig = out.get(varName);

    if isstruct(sig)
        y_full = sig.signals.values;
    elseif isa(sig,'timeseries')
        y_full = sig.Data;
    else
        warning('%s ignoré : type non reconnu', varName);
        continue;
    end

    y_full = squeeze(y_full);

    if size(y_full,1) == length(t_full)
        y = y_full(idx_export,:);
        data = [data y(:)];
        headers{end+1} = varName;

    elseif size(y_full,2) == length(t_full)
        y_full = y_full.';
        y = y_full(idx_export,:);
        data = [data y(:)];
        headers{end+1} = varName;

    else
        warning('%s ignoré : dimension incohérente [%s]', varName, num2str(size(y_full)));
    end
end

%% =========================
%% Écriture CSV
%% =========================

fid = fopen(filename,'w');

for k = 1:length(headers)
    if k < length(headers)
        fprintf(fid, '%s,', headers{k});
    else
        fprintf(fid, '%s\n', headers{k});
    end
end

fclose(fid);

writematrix(data, filename, 'WriteMode', 'append');

fprintf('Export terminé : %s\n', filename);
fprintf('Temps exporté : 0 à %.3f s\n', t_max);
fprintf('Décimation : 1 point sur %d\n', decim_factor);
fprintf('Pas exporté équivalent : %.2f µs\n', mean(diff(t))*1e6);
fprintf('Nombre de lignes : %d\n', length(t));
fprintf('Nombre de colonnes : %d\n', length(headers));