import java.awt.image.BufferedImage;
import java.io.*;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import javax.imageio.ImageIO;

public class ImageCompressor {

    // Размер блока, используемый для сжатия
    private static final int BLOCK_SIZE = 8;


    // Матрица квантования, используемая для сжатия
    private static final int[][] QUANTIZATION_MATRIX = {
            {16, 11, 10, 16, 24, 40, 51, 61},
            {12, 12, 14, 19, 26, 58, 60, 55},
            {14, 13, 16, 24, 40, 57, 69, 56},
            {14, 17, 22, 29, 51, 87, 80, 62},
            {18, 22, 37, 56, 68, 109, 103, 77},
            {24, 35, 55, 64, 81, 104, 113, 92},
            {49, 64, 78, 87, 103, 121, 120, 101},
            {72, 92, 95, 98, 112, 100, 103, 99}
    };

    public static void main(String[] args) throws IOException {

        BufferedImage inputImage = ImageIO.read(new File("input2.jpg"));
        // Преобразовать изображение в оттенки серого
        BufferedImage grayImage = new BufferedImage(
                inputImage.getWidth(), inputImage.getHeight(),
                BufferedImage.TYPE_BYTE_GRAY);
        grayImage.createGraphics().drawImage(inputImage, 0, 0, null);

        // Получить значения пикселей в виде двумерного массива
        int[][] pixels = new int[grayImage.getHeight()][grayImage.getWidth()];
        for (int y = 0; y < grayImage.getHeight(); y++) {
            for (int x = 0; x < grayImage.getWidth(); x++) {
                pixels[y][x] = grayImage.getRGB(x, y) & 0xFF;
            }
        }
        // Алгоритм кодирования(сжатия)
        // Разделение изображение на блоки и сжатие каждого блока
        int[][][] compressedBlocks = new int[pixels.length / BLOCK_SIZE][pixels[0].length / BLOCK_SIZE][BLOCK_SIZE * BLOCK_SIZE];
        int[][] blockMeans = new int[pixels.length / BLOCK_SIZE][pixels[0].length / BLOCK_SIZE];
        for (int blockY = 0; blockY < pixels.length / BLOCK_SIZE; blockY++) {
            for (int blockX = 0; blockX < pixels[0].length / BLOCK_SIZE; blockX++) {
                // Извлечение блока пикселей
                int[][] block = new int[BLOCK_SIZE][BLOCK_SIZE];
                int blockMean = 0;
                for (int y = 0; y < BLOCK_SIZE; y++) {
                    for (int x = 0; x < BLOCK_SIZE; x++) {
                        int pixelY = blockY * BLOCK_SIZE + y;
                        int pixelX = blockX * BLOCK_SIZE + x;
                        block[y][x] = pixels[pixelY][pixelX];
                        blockMean += block[y][x];
                        blockMean /= BLOCK_SIZE * BLOCK_SIZE;
                        blockMeans[blockY][blockX] = blockMean;

                    }
                }

                // Вычислить дифференциальный блок
                int[][] differentialBlock = new int[BLOCK_SIZE][BLOCK_SIZE];
                for (int y = 0; y < BLOCK_SIZE; y++) {
                    for (int x = 0; x < BLOCK_SIZE; x++) {
                        differentialBlock[y][x] = block[y][x] - blockMean;
                    }
                }
                //Спектральное преобразование, преобразование Фурье
                // Применение дискретно-косинусного преобразования к дифференциальному блоку
                double[][] dctBlock = applyDCT(differentialBlock);

                // Квантование коэффициентов, полученных от дискретно-косинусного преобразования
                int[] quantizedBlock = quantizeDCT(dctBlock);

                // Сохранить квантованные коэффициенты (их среднее значение)
                for (int i = 0; i < quantizedBlock.length; i++) {
                    compressedBlocks[blockY][blockX][i] = quantizedBlock[i];
                }
            }
        }

        FileOutputStream fileOutputStream = new FileOutputStream("compressed.bin");
        DataOutputStream dataOutputStream = new DataOutputStream(fileOutputStream);

// Запись размеров сжатого изображения
        dataOutputStream.writeInt(compressedBlocks.length);
        dataOutputStream.writeInt(compressedBlocks[0].length);

// Запись квантованных коэффициентов и средних значений для каждого блока
        for (int blockY = 0; blockY < compressedBlocks.length; blockY++) {
            for (int blockX = 0; blockX < compressedBlocks[0].length; blockX++) {
                // Запись среднего значения
                dataOutputStream.writeInt(blockMeans[blockY][blockX]);

                // Запись квантованных коэффициентов
                for (int i = 0; i < compressedBlocks[blockY][blockX].length; i++) {
                    dataOutputStream.writeInt(compressedBlocks[blockY][blockX][i]);
                }
            }
        }

// Закрытие потоков вывода
        dataOutputStream.close();
        fileOutputStream.close();

        compressFile("compressed.bin", "compressedGZIP.bin");
        System.out.println("Сжатие успешно завершено.");

/**
 * Декодирование
 */

        decompressFile("compressedGZIP.bin", "decompressed.bin");



        FileInputStream fileInputStream = new FileInputStream("decompressed.bin");
        DataInputStream dataInputStream = new DataInputStream(fileInputStream);

// Чтение размеров сжатого изображения
        int compressedHeight = dataInputStream.readInt();
        int compressedWidth = dataInputStream.readInt();

// Чтение квантованных коэффициентов и средних значений для каждого блока
        int[][][] compressedBlocks1 = new int[compressedHeight][compressedWidth][BLOCK_SIZE * BLOCK_SIZE];
        int[][] blockMeans1 = new int[compressedHeight][compressedWidth];
        for (int blockY = 0; blockY < compressedHeight; blockY++) {
            for (int blockX = 0; blockX < compressedWidth; blockX++) {
                // Чтение среднего значения
                blockMeans1[blockY][blockX] = dataInputStream.readInt();

                // Чтение квантованных коэффициентов
                for (int i = 0; i < BLOCK_SIZE * BLOCK_SIZE; i++) {
                    compressedBlocks1[blockY][blockX][i] = dataInputStream.readInt();
                }
            }
        }

// Закрытие потоков ввода
        dataInputStream.close();
        fileInputStream.close();

        System.out.println("Распаковка успешно завершена.");

// Вычисление размеров восстановленного изображения
        int decompressedHeight = compressedHeight * BLOCK_SIZE;
        int decompressedWidth = compressedWidth * BLOCK_SIZE;

// Создание двумерного массива для хранения значений пикселей восстановленного изображения
        int[][] decompressedPixels = new int[decompressedHeight][decompressedWidth];

// Восстановление изображения путем выполнения обратных операций
        for (int blockY = 0; blockY < compressedHeight; blockY++) {
            for (int blockX = 0; blockX < compressedWidth; blockX++) {
                // Получение квантованных коэффициентов и среднего значения для блока
                int[] quantizedBlock = compressedBlocks1[blockY][blockX];
                int blockMean = blockMeans1[blockY][blockX];

                // Деквантование коэффициентов
                double[][] dctBlock = dequantizeDCT(quantizedBlock);

                // Применение обратного дискретного преобразования к блоку
                int[][] decompressedBlock = applyIDCT(dctBlock);

                // Добавление среднего значения к значениям пикселей
                for (int y = 0; y < BLOCK_SIZE; y++) {
                    for (int x = 0; x < BLOCK_SIZE; x++) {
                        int pixelY = blockY * BLOCK_SIZE + y;
                        int pixelX = blockX * BLOCK_SIZE + x;
                        decompressedPixels[pixelY][pixelX] = decompressedBlock[y][x] + blockMean;
                    }
                }
            }
        }

// Создание BufferedImage для хранения восстановленного изображения
        BufferedImage decompressedImage = new BufferedImage(
                decompressedWidth, decompressedHeight, BufferedImage.TYPE_BYTE_GRAY);

// Установка значений пикселей в BufferedImage
        for (int y = 0; y < decompressedHeight; y++) {
            for (int x = 0; x < decompressedWidth; x++) {
                int pixelValue = decompressedPixels[y][x];
                int rgb = (pixelValue << 16) | (pixelValue << 8) | pixelValue;
                decompressedImage.setRGB(x, y, rgb);
            }
        }

// Сохранение восстановленного изображения в файл
        ImageIO.write(decompressedImage, "jpg", new File("decompressed.jpg"));

        System.out.println("Изображение сжато.");
    }

    /**
     * Применяет дискретно косинусное преобразование (DCT) к указанному блоку из
     * пикселей и возвращает результирующие коэффициенты.
     */
    private static double[][] applyDCT(int[][] block) {
        int N = block.length;
        double[][] dct = new double[N][N];
        for (int u = 0; u < N; u++) {
            for (int v = 0; v < N; v++) {
                double sum = 0.0;
                for (int x = 0; x < N; x++) {
                    for (int y = 0; y < N; y++) {
                        sum += block[y][x] * Math.cos(((2 * x + 1) * u * Math.PI) / (2.0 * N))
                                * Math.cos(((2 * y + 1) * v * Math.PI) / (2.0 * N));
                    }
                }
                dct[v][u] = sum * (2.0 / N) * (u == 0 ? 1.0 / Math.sqrt(2) : 1.0) * (v == 0 ? 1.0 / Math.sqrt(2) : 1.0);
            }
        }
        return dct;
    }

    /**
     * Квантует указанные коэффициенты DCT и возвращает результирующий массив
     * из квантованных значений.
     * Коэффициенты почленно делятся на значения матрицы квантования и округляются
     */
    private static int[] quantizeDCT(double[][] dct) {
        int N = dct.length;
        int[] quantized = new int[N * N];
        for (int i = 0; i < N * N; i++) {
            int row = i / N;
            int col = i % N;
            quantized[i] = (int) Math.round(dct[row][col] / QUANTIZATION_MATRIX[row][col]);
        }
        return quantized;
    }

    /**
     * Деквантирует указанный массив квантованных коэффициентов DCT и возвращает
     * результирующий массив коэффициентов.
     */
    private static double[][] dequantizeDCT(int[] quantized) {
        int N = (int) Math.sqrt(quantized.length);
        double[][] dct = new double[N][N];
        for (int i = 0; i < N * N; i++) {
            int row = i / N;
            int col = i % N;
            dct[row][col] = quantized[i] * QUANTIZATION_MATRIX[row][col];
        }
        return dct;
    }

    /**
     * Применяет обратное дискретное косинусное преобразование (IDCT) к указанному массиву коэффициентов DCT
     * и возвращает результирующее
     * блок пикселей.
     */
    private static int[][] applyIDCT(double[][] dct) {
        int N = dct.length;
        int[][] block = new int[N][N];
        for (int x = 0; x < N; x++) {
            for (int y = 0; y < N; y++) {
                double sum = 0.0;
                for (int u = 0; u < N; u++) {
                    for (int v = 0; v < N; v++) {
                        sum += (u == 0 ? 1.0 / Math.sqrt(2) : 1.0) * (v == 0 ? 1.0 / Math.sqrt(2) : 1.0)
                                * dct[v][u] * Math.cos(((2 * x + 1) * u * Math.PI) / (2.0 * N))
                                * Math.cos(((2 * y + 1) * v * Math.PI) / (2.0 * N));
                    }
                }
                block[y][x] = (int) Math.round(sum * (2.0 / N));
            }
        }
        return block;
    }
    public static void compressFile(String inputFile, String outputFile) {
        try {
            // Чтение исходного файла
            FileInputStream fis = new FileInputStream(inputFile);
            // Создание файла для записи сжатых данных
            FileOutputStream fos = new FileOutputStream(outputFile);
            // Создание GZIPOutputStream для сжатия данных и записи их в файл
            GZIPOutputStream gzos = new GZIPOutputStream(fos);

            byte[] buffer = new byte[1024];
            int bytesRead;
            // Чтение блоков данных из исходного файла и запись сжатых данных в выходной файл
            while ((bytesRead = fis.read(buffer)) != -1) {
                gzos.write(buffer, 0, bytesRead);
            }

            // Закрытие потоков
            fis.close();
            gzos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public static void decompressFile(String inputFile, String outputFile) {
        try {
            // Чтение сжатого файла
            FileInputStream fis = new FileInputStream(inputFile);
            // Создание GZIPInputStream для чтения сжатых данных из файла
            GZIPInputStream gzis = new GZIPInputStream(fis);
            // Создание файла для записи распакованных данных
            FileOutputStream fos = new FileOutputStream(outputFile);

            byte[] buffer = new byte[1024];
            int bytesRead;
            // Чтение блоков сжатых данных и запись распакованных данных в выходной файл
            while ((bytesRead = gzis.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }

            // Закрытие потоков
            gzis.close();
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}


