package com.example.backend.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.time.Duration;

@Service
@ConditionalOnProperty(name = "app.s3.enabled", havingValue = "true")
public class StorageService {
    private final S3Presigner presigner;
    private final String bucket;

    public StorageService(S3Presigner presigner, @Value("${app.s3.bucket}") String bucket) {
        this.presigner = presigner;
        this.bucket = bucket;
    }

    public String presignPut(String key, String contentType, int expiresSeconds) {
        PutObjectRequest objectRequest = PutObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .contentType(contentType)
                .build();
        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofSeconds(Math.max(60, Math.min(expiresSeconds, 3600))))
                .putObjectRequest(objectRequest)
                .build();
        PresignedPutObjectRequest presignedRequest = presigner.presignPutObject(presignRequest);
        return presignedRequest.url().toString();
    }

    public String presignGet(String key, int expiresSeconds) {
        GetObjectRequest objectRequest = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build();
        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                .signatureDuration(Duration.ofSeconds(Math.max(60, Math.min(expiresSeconds, 3600))))
                .getObjectRequest(objectRequest)
                .build();
        PresignedGetObjectRequest presignedRequest = presigner.presignGetObject(presignRequest);
        return presignedRequest.url().toString();
    }
}

