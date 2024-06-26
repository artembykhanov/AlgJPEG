function [ img_out ] = Inv_DC_level_shift( img )
% Функция Inv_DC_level_shift выполняет обратное смещение уровня постоянной составляющей (DC)
% img: входное изображение

img = double(img(:,:,:)); % Преобразуем входное изображение в тип double
img_out = 128 + img(:,:,:); % Выполняем обратное смещение, добавляя 128 к каждому пикселю

end
