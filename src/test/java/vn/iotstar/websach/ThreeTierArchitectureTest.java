package vn.iotstar.websach;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;

class ThreeTierArchitectureTest {

    private static final Path JAVA_ROOT = Path.of("src", "main", "java", "vn", "iotstar", "websach");

    @Test
    void presentationLayerMustNotAccessRepositoriesOrPersistenceApisDirectly() throws IOException {
        assertSourcesDoNotContain(JAVA_ROOT.resolve("controller"), List.of(
                "vn.iotstar.websach.repository",
                "jakarta.persistence.EntityManager",
                "org.springframework.jdbc",
                "javax.sql.DataSource"
        ));
        assertSourceDoesNotContain(JAVA_ROOT.resolve("config/NotificationControllerAdvice.java"), List.of(
                "vn.iotstar.websach.repository",
                "jakarta.persistence.EntityManager",
                "org.springframework.jdbc",
                "javax.sql.DataSource"
        ));
    }

    @Test
    void dataAccessLayerMustNotDependOnPresentationOrBusinessLayers() throws IOException {
        assertSourcesDoNotContain(JAVA_ROOT.resolve("repository"), List.of(
                "vn.iotstar.websach.controller",
                "vn.iotstar.websach.service"
        ));
    }

    @Test
    void businessLayerMustNotDependOnPresentationLayer() throws IOException {
        assertSourcesDoNotContain(JAVA_ROOT.resolve("service"), List.of(
                "vn.iotstar.websach.controller"
        ));
    }

    private void assertSourcesDoNotContain(Path directory, List<String> forbiddenDependencies)
            throws IOException {
        try (var paths = Files.walk(directory)) {
            for (Path source : paths.filter(path -> path.toString().endsWith(".java")).toList()) {
                String content = Files.readString(source);
                for (String forbidden : forbiddenDependencies) {
                    assertFalse(content.contains(forbidden),
                            () -> source + " không đúng mô hình 3 tầng vì phụ thuộc trực tiếp vào " + forbidden);
                }
            }
        }
    }

    private void assertSourceDoesNotContain(Path source, List<String> forbiddenDependencies)
            throws IOException {
        String content = Files.readString(source);
        for (String forbidden : forbiddenDependencies) {
            assertFalse(content.contains(forbidden),
                    () -> source + " không đúng mô hình 3 tầng vì phụ thuộc trực tiếp vào " + forbidden);
        }
    }
}
