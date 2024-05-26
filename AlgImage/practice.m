% Закрытие всех открытых окон
close all;

% Скрипт для демонстрации функций обработки изображений

% Выбор изображения
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'All Image Files'});
if isequal(filename, 0)
    disp('User selected Cancel');
    return;
else
    fullpath = fullfile(pathname, filename);
    I = imread(fullpath);
end

% Отображение оригинального изображения
figure, imshow(I), title('Original Image');

% 3.1 Фильтры размытия и увеличения резкости

% Размытие (Gaussian Blur)
I_blur = imgaussfilt(I, 2); % sigma = 2
figure, imshow(I_blur), title('Gaussian Blur');

% Увеличение резкости (Sharpening)
I_sharpen = imsharpen(I);
figure, imshow(I_sharpen), title('Sharpened Image');

% 3.2 Морфологические операции

% Преобразование изображения в черно-белое
I_bw = imbinarize(rgb2gray(I));

% Определение структурного элемента
se = strel('disk', 5);

% Дилатация
I_dilate = imdilate(I_bw, se);
figure, imshow(I_dilate), title('Dilated Image');

% Эрозия
I_erode = imerode(I_bw, se);
figure, imshow(I_erode), title('Eroded Image');

% Открытие
I_open = imopen(I_bw, se);
figure, imshow(I_open), title('Opened Image');

% Закрытие
I_close = imclose(I_bw, se);
figure, imshow(I_close), title('Closed Image');

% 3.3 Алгоритмы сегментации

% Преобразование изображения в оттенки серого
I_gray = rgb2gray(I);

% Адаптивная бинаризация для лучшего выделения монет
I_adapt_thresh = imbinarize(I_gray, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);
figure, imshow(I_adapt_thresh), title('Adaptive Thresholding');

% Использование морфологических операций для улучшения выделения объектов
se = strel('disk', 2);
I_close = imclose(I_adapt_thresh, se);
I_open = imopen(I_close, se);

% Очистка небольших объектов
I_clean = bwareaopen(I_open, 50);
figure, imshow(I_clean), title('Cleaned Image');

% Вычисление расстояний
D = -bwdist(~I_clean);
D = imhmin(D, 2); % подавление минимальных значений

% Применение трансформации водораздела
L = watershed(D);

% Маска объектов
I_segmented = label2rgb(L, 'jet', 'w', 'shuffle');
figure, imshow(I_segmented), title('Watershed Segmentation');
