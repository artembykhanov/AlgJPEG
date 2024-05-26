function [img_out] = Inv_Tiling(img_parts, Size0, tile_size)
Si = size(img_parts);
NAMES = fieldnames(img_parts);

% img_out =  zeros (X1*sqrt(max(siz)),Y1*sqrt(max(siz)),Z1);
% Определение размеров изображения на основе количества плиток и их размера
m = (Size0(1) - mod(Size0(1), tile_size)) / tile_size; 
n = (Size0(2) - mod(Size0(2), tile_size)) / tile_size;
% Вычисление дополнительных блоков для неполного заполнения последней строки и столбца
if (mod(Size0(1), tile_size) == 0)
    m1 = 0;
else 
    m1 = floor(log2(mod(Size0(1), tile_size)));
end
if (mod(Size0(2), tile_size) == 0)
    n1 = 0;
else 
    n1 = floor(log2(mod(Size0(2), tile_size)));
end

% Матрица для учета различий в размещении блоков
arr = [0  0  0  0  0  0;...
       0  1  2  4  8  16;...
       0  2  1  2  4  8;...
       0  4  2  1  2  4;...
       0  8  4  2  1  2;...
       0  16 8  4  2  1];

count = 1; % Счетчик для перебора плиток
for i = 1:m
    for j = 1:n
        % Определение области, куда будет помещена текущая плитка
        a = tile_size * (i - 1) + 1 : 1 : tile_size * i;
        b = tile_size * (j - 1) + 1 : 1 : tile_size * j;
        % Извлечение текущей плитки из структуры и установка её в соответствующую область изображения
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
end

% Обработка случая неполного заполнения последней строки или столбца
if (count > max(Si))
    return  
end
if (m1 ~= 0)
    for k = 1:(tile_size * n / (2^m1))
        a = Size0(1) - mod(Size0(1), tile_size) + 1 : 1 : (Size0(1) - mod(Size0(1), tile_size) + 2^m1);
        b = 2^m1 * (k - 1) + 1 : 1 : 2^m1 * k;
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
end

if (count > max(Si))
    return  
end
if (n1 ~= 0)
    for j = 1:(tile_size * m / (2^n1))
        b = Size0(2) - mod(Size0(2), tile_size) + 1 : 1 : (Size0(2) - mod(Size0(2), tile_size) + 2^n1);
        a = 2^n1 * (j - 1) + 1 : 1 : 2^n1 * j;
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
end

% Расстановка дополнительных блоков в случае различных размеров строк и столбцов
for k = 1:arr(m1 + 1, n1 + 1)
    if (m1 < n1)
        a = Size0(2) - mod(Size0(2), tile_size) + 1 : 1 : (Size0(2) - mod(Size0(2), tile_size) + 2^m1);
        b = Size0(1) - mod(Size0(1), tile_size) + 1 + 2^m1 * (k - 1) : 1 : Size0(1) - mod(Size0(1), tile_size) + 2^m1 * k;             
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
    if (m1 > n1)
        a = Size0(2) - mod(Size0(2), tile_size) + 1 + 2^n1 * (k - 1) : 1 : Size0(2) - mod(Size0(2), tile_size) + 2^n1 * k;            
        b = Size0(1) - mod(Size0(1), tile_size) + 1            : 1 : Size0(1) - mod(Size0(1), tile_size) + 2^n1   ;
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
    if (m1 == n1)
        a = Size0(1) - mod(Size0(1), tile_size) + 1 : 1 : Size0(1) - mod(Size0(1), tile_size) + 2^m1 * k;
        b = Size0(2) - mod(Size0(2), tile_size) + 1 : 1 : Size0(2) - mod(Size0(2), tile_size) + 2^n1 * k;
        img_out(a, b, :) = getfield(img_parts(count), NAMES{1});
        count = count + 1;
    end
end  
end
