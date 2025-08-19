package com.example.backend.storage;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/storage")
@Validated
@ConditionalOnProperty(name = "app.s3.enabled", havingValue = "true")
public class StorageController {
    private final StorageService storageService;

    public StorageController(StorageService storageService) {
        this.storageService = storageService;
    }

    @PostMapping("/presign/put")
    public Map<String, String> presignPut(
            @RequestParam @NotBlank String key,
            @RequestParam(defaultValue = "application/octet-stream") String contentType,
            @RequestParam(defaultValue = "300") @Min(60) @Max(3600) int expiresSeconds
    ) {
        String url = storageService.presignPut(key, contentType, expiresSeconds);
        return Map.of("url", url);
    }

    @GetMapping("/presign/get")
    public Map<String, String> presignGet(
            @RequestParam @NotBlank String key,
            @RequestParam(defaultValue = "300") @Min(60) @Max(3600) int expiresSeconds
    ) {
        String url = storageService.presignGet(key, expiresSeconds);
        return Map.of("url", url);
    }
}
