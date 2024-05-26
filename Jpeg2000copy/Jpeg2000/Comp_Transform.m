function [ img_out ] = Comp_Transform( img, x )
% Функция для выполнения компонентного преобразования цветности изображения.

siz = size (img);
if (length(siz) == 2)
    siz(3) = 1;
end
img_out = zeros(siz(1),siz(2),siz(3));

%% RGB to YC1C2 (approx. KLT)
% Преобразование из RGB в YC1C2 (приближенное Карунена-Лоэва преобразование).
if (x == 1)
    T_Matrix = [1/3 1/3 1/3; 1/2 0 -1/2 ; -1/4 1/2 -1/4 ];
    for i = 1:siz(1)
        for j = 1:siz(1)
            B = img(i,j,:);
            C = double(B(:));
            img_out(i,j,:) = T_Matrix*C;  
        end
    end
end

%% RGB to YCoCg
% Преобразование из RGB в YCoCg.
if (x == 2)
    T_Matrix = [1/4 1/2 1/4; 1/2 0 -1/2 ; -1/4 1/2 -1/4 ];
    for i = 1:siz(1)
        for j = 1:siz(1)
           B = img(i,j,:);
            C = double(B(:));
            img_out(i,j,:) = T_Matrix*C; 
        end
    end
end

%% RGB to YCrCb(lossy2000)
% Преобразование из RGB в YCrCb (потери 2000).
if (x == 3)
    T_Matrix = [.299 .587 .114; .5 -0.4187 -0.0813 ; -0.1687 -0.3313 0.5 ];
    for i = 1:siz(1)
        for j = 1:siz(1)
           B = img(i,j,:);
            C = double(B(:));
            img_out(i,j,:) = T_Matrix*C;
        end
    end
end

%% RGB to YCuCv (lossless2000)
% Преобразование из RGB в YCuCv (без потерь 2000).
if (x == 4)
    T_Matrix = [1/4 1/2 1/4; 0 -1 1 ; 1 -1 0 ];
    for i = 1:siz(1)
        for j = 1:siz(2)
           B = img(i,j,:);
            C = double(B(:));
            img_out(i,j,:) = T_Matrix*C;
        end
    end
end

end
