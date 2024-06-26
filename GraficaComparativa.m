% Excel Sol. 1
data_table = readtable('/MATLAB Drive/Resultados_Refrigeración.xlsx');

x_data = data_table.Tiempo_Horas_;
tempint_data = data_table.TemperaturaDelInterior__C_;
tempext_data = data_table.TemperaturaDelExterior__C_;

% Excel Sol. 2
data_table2 = readtable('/MATLAB Drive/Experimento2.xlsx');

x_2 = data_table2.Var1;
tempint2_data = data_table2.Var2;
tempext2_data = data_table2.Var3;

% Parametros Sol.1 y Sol.1 (Función analítica)
kc = 0.022;
A = 0.5852;
T_ext = 22;
z = 0.02;
dt = 3600;
m = [23586.36, 0.23336, 0.01205];
C = [0.242, 1, 0.215]; 
T_int_inicial = 6;
tiempo = 24;

T_int_valores = zeros(1, tiempo);
T_ext_valores = ones(1, tiempo) * T_ext;

T_int = T_int_inicial;
for i = 1:tiempo
    T_int_valores(i) = T_int;
    T_int = calcular_T_int(T_int, kc, A, T_ext, z, dt, m, C);
end

% Parametros Sol.2 y Sol.2 (Temperatura exterior) (Función analítica)
T0 = 22.23;
Tmax = 29.42;
Tmin = 10.05;
T = 24 * 3600;
Amp = (Tmax - Tmin) / 2;
w = 2 * pi / T;
phi = 0.05;
dt = 0.1 * 3600;
tiempo2 = 0:dt:T;

T_ext2 = zeros(size(tiempo2));

for i = 1:length(tiempo2)-1
    T_ext2(i+1) = T0 + Amp * sin(w * tiempo2(i) + phi);
end

% Parametros Sol.2 y Sol.2 (Temperatura interior) (Función analítica)
T02 = 7.9;
Tmax2 = 27.25;
Tmin2 = 7.9;
T2 = 24 * 3600;
Amp2 = (Tmax2 - Tmin2) / 2;
phi2_start = -pi/2;
phi2_end = asin((Tmax2 - Tmin2) / Amp2);
w2 = 2 * pi / T2;
dt2 = 1;

tiempo3 = 0:dt2:T2;

T_sin = Amp2 * sin(w2 * tiempo3 + phi2_start) + Tmin2;
T_sin = T_sin + 10;

% Error experimental Sol. 1 (Experimental vs. Analítica)
n = min(length(tempint_data), length(T_int_valores));
Error = 0;

for i = 1:n
    Error = Error + abs(tempint_data(i) - T_int_valores(i)) / tempint_data(i);
end

Error = Error / n * 100;
fprintf("Error porcentual en el interior del cooler = %.2f %c\n", Error, "%");

% Error experimental Sol. 2 (Experimental vs. Analítica)
Error2 = 0;
Error2 = Error2 + abs(tempint2_data(i) - T_sin(i)) / tempint2_data(i);

Error2 = Error2 / n * 100;
fprintf("Error porcentual en el exterior del cooler = %.2f %c\n", Error2, "%");

% Plots
hold on
plot(0:tiempo-1, T_int_valores)
plot(0:tiempo-1, T_ext_valores, '--') 
plot(x_data, tempint_data);
plot(x_data, tempext_data);
plot(x_2, tempint2_data);
plot(x_2, tempext2_data);
plot(tiempo2/3600, T_ext2);
plot(tiempo3/3600, T_sin);
hold off

xlim([0.1 24])
xlabel('Tiempo (h)');
ylabel('Temperatura (ºC)');
title('Temperatura vs. Tiempo');
legend("T(t) con Δt = 1 s", "T_{ext} = 22ºC", "Temp. Interior Exp. 1", "Temp. Exterior Exp. 1", "Temp. Interior Exp. 2", "Temp. Exterior Exp. 2", "Temp. Exterior Ideal", "Temp. Interior Ideal")

% Función Temperatura interior Analítica
function T_int_final = calcular_T_int(T_int, kc, A, T_ext, z, dt, m, C)
    n = length(m);
    suma_mjCj = 0;
    for j = 1:n
        suma_mjCj = suma_mjCj + m(j) * C(j);
    end
    T_int_final = T_int + (kc * A * (T_ext - T_int) / (z * suma_mjCj)) * dt;
end
