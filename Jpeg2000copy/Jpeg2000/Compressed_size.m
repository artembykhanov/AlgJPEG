% Функция Compressed_size вычисляет сжатый размер изображения, хранящегося
% в структурах данных. Входной аргумент imput_Img представляет собой
% массив структур, содержащих изображения. Функция просматривает каждое
% изображение в массиве, вычисляет его размер сжатого представления и
% возвращает общий сжатый размер.

function [ size_image ] = Compressed_size( imput_Img)
    Si = size (imput_Img);
    NAMES = fieldnames(imput_Img);
    size_image = 0;
    for i = 1:max(Si)
         s = max(size (getfield(imput_Img(i),NAMES{1})));
         size_image = size_image + s;
    end
end
