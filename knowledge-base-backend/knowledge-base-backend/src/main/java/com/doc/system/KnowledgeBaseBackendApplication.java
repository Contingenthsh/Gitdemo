package com.doc.system;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.doc.system.mapper")
public class KnowledgeBaseBackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(KnowledgeBaseBackendApplication.class, args);
    }
}