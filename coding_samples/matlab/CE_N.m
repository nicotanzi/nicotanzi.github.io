%% Cake Eating Problem

% Existe una torta con tamaño constante através del tiempo
% Hay un consumidor, con preferencias CRRA caracterizadas por
% Factor de descuento: beta
% Coeficiente de Aversión al Riesgo Relativo: sigma

% K(t) representa la torta disponible en el período t
% c(t) representa la porción de la torta comida en t
% Por ende, K(t+1) = K(t) - c(t),
% y K(t)>= 0   c(t)>=0  K(0)=200

% La ecuación de Bellman puede escribirse como:
% V(K) = max{ U(c) + b V(K-c) }
% Sujeta a las restricciones mencionadas
% Si interiorizamos la ley de movimiento de la torta:
% V(K) = max{ U(K-K') + b V(K') }
% Notese que al principio maximizaba respecto a c, ahora respecto a K'

% El objetivo es hallar V(K), lo haremos iterativamente
% Dado un V_n hallaremos un V_n+1

% Pensaremos a una función somo un conjunto de pares ordenados:
% {(y,x): y=f(x)} el código nos permitirá hallar el conjunto
% Pero no nos permitira hallar la forma funcional

close all; % limpio el espacio de trabajo de MATLAB
clear all;
%% PARÁMETROS

beta=0.99; % beta del problema
sigma=1;
K=1:0.5:200; % K es el vector (fila) de valores que puede tomar la torta
T=200; % Número de iteraciones
toler=.0001;

%% INICIALIZACIÓN DE MATRICES Y VECTORES

% Como K es un vector, size(K)=[1 399], size(K,2)=399 length(K)=399

% Voy a inicializar muchos vectores que luego llenaré
V = zeros(size(K)); % Función de Valor
v = zeros(size(K)); % Función de Valor próxima iteración
m = zeros(size(K)); % ubicación del K'
G = zeros(size(K)); % K' (imagen de la fun de pol)

% A iterar se actualizarán la función de valor V y de pol G
% Guardaré la imagen de V y la imagen de G de la iteración n
% en la fila número n de cada matriz
matV = zeros(T,length(K));
matG = zeros(T,length(K));

% También guardaré los errores entre la iteracción actual y la anterior
D=zeros(1,T); 


% Para poder hallar iterativamente a V(K) en:
% V(K) = max{ U(K-K') + b V(K') }
% Necesitamos un punto de partida, el cual será:
% V(K)=U(K) (me como todo la torta el período siguiente)

% El problema consiste en dado un K
% encontrar un K' que maximiza dicha función
% Computacionalmente el problema implica probar con muchos K'

% Además esto implica resolver el problema:
% max{ U(K-K') + b V(K') }
% Lo cuál también lo haremos iterativamente
% Este problema dice, dado V(.) y dado K
% Hallar el K que maximiza V(.) y computarlo
% El problema consiste en dado un K
% encontrar un K' que maximiza dicha función
% Computacionalmente el problema implica probar con muchos K'

%% PRIMETA ITERACIÓN V_0=max(K)
for i=1:length(K)
   
% Para cada K posible, es decir para todo K(i) posible
% debo encontrar un K' posible que maximice la función obj
% Si defino a K' como K(j), dado que K>=K' i, entonces i>=j
    
    S = zeros(size(K)); % inicializo un vector
    for j=1:i-1
% K(i) es K, mientras K(j) es K'
% Como K>=K' i
% Voy a querer probar con muchas K' y quedarme con la que maximiza
        if sigma==1 % si sigma es 1, entonces la CRRA tiende a una logarítmica
    S(j)=log(K(i)-K(j))+beta.*log(K(j)); 
        else
    S(j)=((K(i)-K(j)).^(1-sigma))./(1-sigma)+beta.*(K(j).^(1-sigma))./(1-sigma);
        end
    end
    % El vector S, me guarda todos los valores tal que:
    % S(K) = { U(K-K') + b max(K') } 
    % S(K) es una correspondencia, donde elijo todos los K' posibles
    V(i)=max(S);
    % R(K) = max{ U(K-K') + b max(K') }
    % Es decir que R(K) es la primera iteración
end

% Guardo los datos de la primera iteración
matV(1,:)=V;
matG(1,:)=K;

% La diferencia de la primera iteración
V_0 = zeros(size(K));
for i=1:size(K,2)
    if sigma==1 
        V(i)=log(K(i)); 
    else
        V(i)=((K(i)).^(1-sigma))./(1-sigma);
    end
end
diff=(V-V_0);
D(1)=max(diff); % Guardo los errores



%% ITERACIONES SUBSIGUIENTES

ultima_it=T;

for h=1:T
    
for i=1:length(K)
    s = zeros(size(K));
    for j=1:i-1
        if sigma==1
    s(j)=log(K(i)-K(j))+beta.*V(j);
        else
    s(j)=((K(i)-K(j)).^(1-sigma))./(1-sigma)+beta.*V(j);
        end
    end
    [v(i),m(i)]=max(s);
    G(i)=K(m(i));
    % Si s=[10 25 14], entonces r(i)=25 m(i)=2
    % Si s=[-22 34 87], entonces r(i)=87 m(i)=3
    % r(i) es la imagen de la función de valor para K(i)
    % m(i) es la ubicación del K', K(m(i)) es la imagen de la f de pol
end  

diff=(V-v); % Computo la diferencia con la anterior
V=v; % Actualizo la función de Valor
matV(h+1,:)=v; % Guardo en la fila h, la f de valor de la iteración h+1
matG(h+1,:)=G; % Guardo en la fila h, la f de valor de la iteración h+1
D(h+1)=max(diff); % Guardo los errores

% Si el nivel de tolerancia es el adecuado salgo, sino continuo
if abs (diff)<=toler
    disp("Se alcanzó el nivel de tolerancia estipulado luego de la iteración:")
    disp(h+1)
    ultima_it=h+1;
    break
end

end

%% GRAFICOS

figure (1)
plot (V);
figure (2)
plot(D);
figure (3)
plot (K,G,K,K);
legend('Policy Fuction','45°');
grid


%% GIF VFI

% Nombre del archivo GIF
filename = 'evolucion_valor.gif';

% Determinar índices para 10 imágenes espaciadas uniformemente
num_frames = 10; % Número deseado de imágenes en el GIF
indices = round(linspace(1, ultima_it, num_frames)); % Índices de iteraciones

% Crear un gráfico para el GIF
figure(4);
for h = indices
    plot(K, matV(h, :), 'LineWidth', 2);
    title(['Iteración ', num2str(h)]);
    xlabel('K');
    ylabel('V(K)');
    grid on;
    xlim([min(K), max(K)]);
    ylim([min(matV(h, :)) - 10, max(matV(h, :)) + 10]); % Ajusta los límites si es necesario
    
    % Capturar el frame del gráfico
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);

    % Guardar el frame en el GIF
    if h == indices(1)
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.5);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    end
end
disp(['GIF creado: ', filename]);
