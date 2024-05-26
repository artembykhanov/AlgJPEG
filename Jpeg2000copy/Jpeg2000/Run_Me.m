clc % Очистка командного окна
clear all % Очистка рабочего пространства MATLAB
close all % Закрытие всех открытых графиков

%% Запрос ввода изображения от пользователя
[FileName,PathName] = uigetfile('*.*','Выберите файл изображения');
img = imread([PathName FileName]); % Чтение изображения
siz = size (img); % Получение размеров изображения
if (length(siz) == 2) % Если изображение черно-белое
siz(3) = 1; % Добавление третьего измерения
end
                    
img = double(img); 
%% Encoder
[Img_Y_DWT_Quant_enc, Img_Chroma1_DWT_Quant_enc ,Img_Chroma2_DWT_Quant_enc, Tiles, transform_sel,levels,Parts0,Parts1,Parts2 ] = Encoder(img);

%% Decoder
img_decoded = Decoder(Img_Y_DWT_Quant_enc, Img_Chroma1_DWT_Quant_enc ,Img_Chroma2_DWT_Quant_enc, Tiles, transform_sel,levels,siz );

%%
siz_dec = size (img_decoded );
if (length(siz_dec) == 2) % Если декодированное изображение черно-белое
siz_dec(3) = 1; % Добавление третьего измерения
end
img_1 = img(1:siz_dec(1), 1:siz_dec(2), :); % Обрезка оригинального изображения до размеров декодированного

[ mse ] = MSE( img_1 , img_decoded ); % Вычисление среднеквадратичной ошибки между оригинальным и декодированным изображением
img_decoded = uint8(img_decoded); % Преобразование декодированного изображения в тип данных uint8
figure; % Создание нового графика
subplot (1,2,1)
imshow (uint8(img));
title ('Оригинальное изображение (До jpeg2000)')
subplot (1,2,2)
imshow (uint8(img_decoded));
title ('Сжатое изображение');
%% Расчет коэффициента сжатия

size_image0 = Compressed_size( Img_Y_DWT_Quant_enc); % Размер сжатого изображения (компонента Y)
size_image1 = Compressed_size( Img_Chroma1_DWT_Quant_enc); % Размер сжатого изображения (компонента Chroma1)
size_image2 = Compressed_size( Img_Chroma2_DWT_Quant_enc); % Размер сжатого изображения (компонента Chroma2)
compressed_size = size_image0 + size_image1 + size_image2; % Общий размер сжатого изображения
input_size = siz(1)*siz(2)*siz(3); % Размер входного изображения
compression_ratio = input_size/compressed_size; % Расчет коэффициента сжатия