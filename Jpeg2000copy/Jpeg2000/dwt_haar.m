function [ img_scal, img_wave ] = dwt_haar( img )

% Получение размеров изображения
siz = size (img);
if (length(siz) == 2)
    siz(3) = 1;
end

% Создание временного массива для изображения с дополнительным столбцом
img_dum = zeros(siz(1), siz(2) + 1, siz(3));
img_dum(1:siz(1), 1:siz(2), :) = img(:,:,:);

% Инициализация массивов для хранения коэффициентов преобразования
img_scal = zeros(siz(1), siz(2), siz(3));
img_wave = zeros(siz(1), siz(2), siz(3));

% Задание коэффициентов масштабирования и вейвлета для преобразования Хаара
Scaling0 = [1/sqrt(2) 1/sqrt(2)];
Scaling1 = ones(siz(1), 1);
Scaling = Scaling1 * Scaling0;

Wavelet0 = [-1/sqrt(2) 1/sqrt(2)];
Wavelet1 = ones(siz(1), 1);
Wavelet = Wavelet1 * Wavelet0;

% Применение масштабирования и вейвлета ко всему изображению
for k = 1: siz(3)
    for i = 1: siz(2)
        img_scal(:, i) = sum(img_dum(:, i:i+1) .* Scaling, 2);
        img_wave(:, i) = sum(img_dum(:, i:i+1) .* Wavelet, 2);
    end
end

end
