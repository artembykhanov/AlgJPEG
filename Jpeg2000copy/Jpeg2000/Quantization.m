function [ img_out ] = Quantization( img, dead_zone )
% Функция Quantization выполняет квантование изображения
% img: входное изображение для квантования
% dead_zone: размер зоны без изменения (dead zone)

siz = size (img); % Получаем размеры входного изображения
if (length(siz) == 2)
    siz(3) = 1; % Если изображение черно-белое, добавляем третье измерение
end
img_out = zeros(siz(1), siz(2), siz(3)); % Инициализируем выходное изображение

for i = 1:siz(1)
    for j = 1:siz(2)
        if ((img(i,j,:) >= -dead_zone) && (img(i,j,:) <= dead_zone))
            img_out(i,j,:) = 0; % Зона без изменения
        else
            img_out(i,j,:) = round(img(i,j,:)); % Квантование
        end
    end
end

% Другой вариант реализации, закомментированный код:
% dum = abs(img);
% dum = dum > -dead_zone*step_siz;
% dum = dum.*img;
% img_out = sign(dum).*floor((abs(dum)+step_siz*dead_zone)./step_siz);

end
