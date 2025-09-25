package com.github.schl3sch.honeypot_harbor_backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import co.elastic.clients.elasticsearch.ElasticsearchClient;

@Configuration
public class ElasticsearchConfig {

    @Value("http://192.168.1.102:9200")
    private String serverUrl;

    @Value("${ELASTIC_USER}")
    private String username;

    @Value("${ELASTIC_PASSWORD}")
    private String password;

    // Connect to Elasticsearch
    @Bean
    public ElasticsearchClient elasticsearchClient() {
        return ElasticsearchClient.of(b -> b
            .host(serverUrl)
            .usernameAndPassword(username, password));
    }
}

    
