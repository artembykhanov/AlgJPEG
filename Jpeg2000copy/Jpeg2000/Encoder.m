    function [Img_Y_DWT_Quant_enc, Img_Chroma1_DWT_Quant_enc ,Img_Chroma2_DWT_Quant_enc, Tiles, transform_sel, levels ,Parts0, Parts1, Parts2] = Encoder(img)

% levels = str2double(inputdlg('Please enter the number of levels (>=1)',...
%                              'Input for levels',1,{'7'}));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
levels = 3;
transform_sel = 4;
dead_zone = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
siz = size(img);
if (length(siz) == 2)
    siz(3) = 1;
end
tile_size = 64;

%% Разбиение входного изображения на плитки

[Img_Tiled, Tiles] = Tiling(img);
 
%% Смещение уровня DC для каждой плитки изображения

Img_Tiled_DC(1:Tiles) = struct('DC',[]);
for m = 1:Tiles
   Img_Tiled_DC(m).DC = DC_level_shift(Img_Tiled(m).tile);
end
dumy = Inv_Tiling(Img_Tiled_DC, siz, tile_size);
figure;
imshow(uint8(dumy));
title('Изображение после смещения уровня DC')

%% Преобразование цветности изображения

Img_Tiled_DC_trans(1:Tiles) = struct('trans',[]);
h = waitbar(0,'Преобразование цвета выполняется, пожалуйста, подождите...');
for m = 1:Tiles
   Img_Tiled_DC_trans(m).trans = Comp_Transform(Img_Tiled_DC(m).DC, transform_sel);
   waitbar(m / Tiles)
end
close(h)
dumy = Inv_Tiling(Img_Tiled_DC_trans, siz, tile_size);
figure;
imshow(uint8(dumy));
title('Изображение после преобразования цветности')

%% Разделение на компоненты

Img_Y(1:Tiles) = struct('y',[]);
for m = 1:Tiles
   dum_img = Img_Tiled_DC_trans(m).trans;
   Img_Y(m).y = dum_img(:,:,1); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma1(1:Tiles) = struct('chr1',[]);
for m = 1:Tiles
   dum_img = Img_Tiled_DC_trans(m).trans;
   Img_Chroma1(m).chr1 = dum_img(:,:,2); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma2(1:Tiles) = struct('chr2',[]);
for m = 1:Tiles
   dum_img = Img_Tiled_DC_trans(m).trans;
   Img_Chroma2(m).chr2 = dum_img(:,:,3); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Поддискретизация компонент Chroma, если применяется цветовое преобразование YCrCb или YUV

if ((transform_sel == 3) || (transform_sel == 4))
for m = 1:Tiles
   Img_Chroma1(m).chr1 = Down_sample(Img_Chroma1(m).chr1 , 2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for m = 1:Tiles
   Img_Chroma2(m).chr2 = Down_sample(Img_Chroma2(m).chr2 , 2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Вычисления ДПТ-Хаара

Img_Y_DWT(1:Tiles) = struct('DWTY',[]);
h = waitbar(0,'Вычисление DWT для компоненты Y, пожалуйста, подождите...');
for m = 1:Tiles
    [Img_Y_DWT(m).DWTY, Parts0] = DWT(Img_Y(m).y , levels);
    waitbar(m / Tiles)
end
close(h)
dumy = Inv_Tiling(Img_Y_DWT, siz, tile_size);
figure;
imshow(uint8(dumy));
title('Компонента Y изображения после DWT')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma1_DWT(1:Tiles) = struct('DWT1',[]);
h = waitbar(0,'Вычисление DWT для компоненты Chroma1, пожалуйста, подождите...');
for m = 1:Tiles
    [Img_Chroma1_DWT(m).DWT1, Parts1] = DWT(Img_Chroma1(m).chr1 , levels);
    waitbar(m / Tiles)
end
close(h)
if ((transform_sel == 3) || (transform_sel == 4))
     size02 = siz([1 2]) ./ 2;
     tile_size = 32;
 else 
     size02 = siz;
     tile_size = 64;
end
dumy = Inv_Tiling(Img_Chroma1_DWT, size02, tile_size);
figure;
imshow(uint8(dumy));
title('Компонента Chroma1 изображения после DWT')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma2_DWT(1:Tiles) = struct('DWT2',[]);
h = waitbar(0,'Вычисление DWT для компоненты Chroma2, пожалуйста, подождите...');
for m = 1:Tiles
    [Img_Chroma2_DWT(m).DWT2 , Parts2]= DWT(Img_Chroma2(m).chr2 , levels);
    waitbar(m / Tiles)
end
close(h)
if ((transform_sel == 3) || (transform_sel == 4))
     size02 = siz([1 2]) ./ 2;
     tile_size = 32;
 else 
     size02 = siz;
     tile_size = 64;
end
dumy = Inv_Tiling(Img_Chroma2_DWT, size02, tile_size);
figure;
imshow(uint8(dumy));
title('Компонента Chroma2 изображения после DWT')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Квантование

Img_Y_DWT_Quant(1:Tiles) = struct('DWTY_quant',[]);
h = waitbar(0,'Выполняется квантование для компоненты Y, пожалуйста, подождите...');
for m = 1:Tiles
    Img_Y_DWT_Quant(m).DWTY_quant = Quantization(Img_Y_DWT(m).DWTY, dead_zone);
    waitbar(m / Tiles)
end
close(h);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma1_DWT_Quant(1:Tiles) = struct('DWT1_Quant',[]);
h = waitbar(0,'Выполняется квантование для компоненты Chroma1, пожалуйста, подождите...');
for m = 1:Tiles
    Img_Chroma1_DWT_Quant(m).DWT1_Quant = Quantization(Img_Chroma1_DWT(m).DWT1, dead_zone);
    waitbar(m / Tiles)
end
close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma2_DWT_Quant(1:Tiles) = struct('DWT2_Quant',[]);
h = waitbar(0,'Выполняется квантование для компоненты Chroma2, пожалуйста, подождите...');
for m = 1:Tiles
    Img_Chroma2_DWT_Quant(m).DWT2_Quant = Quantization(Img_Chroma2_DWT(m).DWT2, dead_zone);
    waitbar(m / Tiles)
end
close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Кодирование 

Img_Y_DWT_Quant_enc(1:Tiles) = struct('enc',[], 'rowcol', []);
h = waitbar(0,'Выполняется кодирование для компоненты Y, пожалуйста, подождите...');
for m = 1:Tiles
    [Img_Y_DWT_Quant_enc(m).enc, Img_Y_DWT_Quant_enc(m).rowcol] = RLC(Img_Y_DWT_Quant(m).DWTY_quant);
    waitbar(m / Tiles)
end
close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma1_DWT_Quant_enc(1:Tiles) = struct('enc',[] ,'rowcol', []);
h = waitbar(0,'Выполняется кодирование для компоненты Chroma1, пожалуйста, подождите...');
for m = 1:Tiles
    [Img_Chroma1_DWT_Quant_enc(m).enc, Img_Chroma1_DWT_Quant_enc(m).rowcol] = RLC(Img_Chroma1_DWT_Quant(m).DWT1_Quant);
    waitbar(m / Tiles)
end
close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Img_Chroma2_DWT_Quant_enc(1:Tiles) = struct('enc',[], 'rowcol', []);
h = waitbar(0,'Выполняется кодирование для компоненты Chroma2, пожалуйста, подождите...');
for m = 1:Tiles
   [Img_Chroma2_DWT_Quant_enc(m).enc, Img_Chroma2_DWT_Quant_enc(m).rowcol] = RLC(Img_Chroma2_DWT_Quant(m).DWT2_Quant);
    waitbar(m / Tiles)
end
close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
