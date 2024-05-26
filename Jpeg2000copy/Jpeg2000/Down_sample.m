function [ img_out ] = Down_sample( img , flag)

% Субдискретизация в строках
if (flag == 0 )
    img_out = img(1:2:end,:,:);
end

% Субдискретизация в столбцах
if (flag == 1 )
    img_out = img(:,1:2:end,:);
end

% Субдискретизация в строках и столбцах
if (flag == 2 )
    img_out = img(2:2:end,2:2:end,:);
end

end
