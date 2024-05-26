function [ img_result ] = myiDWT2_haar( img , levels )
% Функция myiDWT2_haar выполняет обратное двумерное дискретное вейвлет-преобразование Хаара
% img: входное изображение
% levels: количество уровней декомпозиции

siz = size(img); % Получаем размеры входного изображения
if (length(siz) == 2)
    siz(3) = 1; % Если изображение черно-белое, добавляем третье измерение
end

% Размеры изображения на самом грубом уровне декомпозиции
a = floor(siz(1) / (2^(levels)));
b = floor(siz(2) / (2^(levels)));

% Разбиение изображения на составляющие волны Хаара
img_scaled = img(1:a, 1:b, :);
img_H_wave = img(1:a, b+1:2*b, :);
img_V_wave = img(a+1:2*a, 1:b, :);
img_D_wave = img(a+1:2*a, b+1:2*b, :);

% Восстановление изображения
img_scaled = Up_sample(img_scaled, 0); % Увеличение размера в строках
img_H_wave = Up_sample(img_H_wave, 0); % Увеличение размера в строках
img_V_wave = Up_sample(img_V_wave, 0); % Увеличение размера в строках
img_D_wave = Up_sample(img_D_wave, 0); % Увеличение размера в строках

% Транспонирование для подготовки к обратному преобразованию
img_scaled = img_scaled';
img_H_wave = img_H_wave';
img_V_wave = img_V_wave';
img_D_wave = img_D_wave';

% Обратное преобразование на каждом уровне
img_0 = idwt_haar(img_scaled, 0);
img_1 = idwt_haar(img_H_wave, 1);
img_2 = idwt_haar(img_V_wave, 0);
img_3 = idwt_haar(img_D_wave, 1);

% Транспонирование для подготовки к следующему этапу
img_0 = img_0';
img_1 = img_1';
img_2 = img_2';
img_3 = img_3';

% Сложение результатов восстановления
img_result0 = img_0 + img_1;
img_result1 = img_2 + img_3;

% Увеличение размера в столбцах
img_result0 = Up_sample(img_result0, 1);
img_result1 = Up_sample(img_result1, 1);

% Обратное преобразование на самом грубом уровне
img_result0 = idwt_haar(img_result0, 0);
img_result1 = idwt_haar(img_result1, 1);

% Сложение результатов восстановления на самом грубом уровне
img_result = img_result0 + img_result1;

end
