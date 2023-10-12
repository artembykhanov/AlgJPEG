import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class ImageCompressorJava {

    public static void main(String[] args) {
        String inputImagePath = "input2.jpg";
        String outputImagePath = "decompressedJava.jpg";
        float quality = 0.08f; // Коэффициент сжатия (0.0 - 1.0)

        compressJPEG(inputImagePath, outputImagePath, quality);
    }

    public static void compressJPEG(String inputImagePath, String outputImagePath, float quality) {
        File inputFile = new File(inputImagePath);
        File outputFile = new File(outputImagePath);

        try {
            BufferedImage image = ImageIO.read(inputFile);

            // Получение объекта ImageWriter для формата JPEG
            ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();

            // Создание параметров сжатия JPEG
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);

            // Создание источника изображения и приемника данных для записи сжатого изображения
            ImageOutputStream outputStream = ImageIO.createImageOutputStream(outputFile);
            writer.setOutput(outputStream);

            // Запись сжатого изображения
            writer.write(null, new IIOImage(image, null, null), param);

            // Закрытие потоков
            outputStream.close();
            writer.dispose();

            System.out.println("Изображение успешно сжато и сохранено.");
        } catch (IOException e) {
            System.out.println("Ошибка при сжатии изображения: " + e.getMessage());
        }
    }
}
