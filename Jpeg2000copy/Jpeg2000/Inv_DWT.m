function [ img_result ] = Inv_DWT( img_DWT , levels)
% Функция Inv_DWT выполняет обратное дискретное вейвлет-преобразование (IDWT)
% img_DWT: массив данных после DWT
% levels: количество уровней декомпозиции

siz = size (img_DWT); % Получаем размеры массива img_DWT
if (length(siz) == 2)
    siz(3) = 1; % Если изображение черно-белое, добавляем третье измерение
end

% Начинаем обратное преобразование на каждом уровне декомпозиции
img_result = img_DWT; % Начальное значение img_result равно img_DWT
for i = levels:-1:1 
    A = floor(siz(1) / (2^(i-1))); % Вычисляем размеры изображения на текущем уровне
    B = floor(siz(2) / (2^(i-1)));

    img_result0 = img_result(1:A, 1:B, :); % Выделяем область для текущего уровня
    img_result1 = myiDWT2_haar(img_result0, 1); % Выполняем обратное DWT на этом уровне
    img_result(1:A, 1:B, :) = img_result1; % Обновляем img_result
end

end
