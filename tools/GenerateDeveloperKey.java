import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyPair;
import java.security.KeyPairGenerator;

public class GenerateDeveloperKey {
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            throw new IllegalArgumentException("Usage: GenerateDeveloperKey <output.der>");
        }

        KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
        generator.initialize(4096);
        KeyPair keyPair = generator.generateKeyPair();

        Files.write(Path.of(args[0]), keyPair.getPrivate().getEncoded());
    }
}
