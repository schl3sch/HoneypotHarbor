package com.github.schl3sch.honeypot_harbor_backend.config;


import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.apache.http.HttpHost;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ElasticsearchConfig {

    @Value("http://192.168.1.102:9200")
    private String serverUrl;

    @Value("elastic")
    private String username;

    @Value("${ELASTIC_PASSWORD}")
    private String password;

    @Bean
    public ElasticsearchClient elasticsearchClient() {

        BasicCredentialsProvider credentialsProvider = new BasicCredentialsProvider();
        credentialsProvider.setCredentials(AuthScope.ANY,
                new UsernamePasswordCredentials(username, password));

        HttpHost httpHost = HttpHost.create(serverUrl);

        // Build RestClient with timeouts
        RestClientBuilder builder = RestClient.builder(httpHost)
                .setHttpClientConfigCallback(httpClientBuilder ->
                        httpClientBuilder.setDefaultCredentialsProvider(credentialsProvider)
                )
                .setRequestConfigCallback(requestConfigBuilder ->
                        requestConfigBuilder
                                .setConnectTimeout(5000)
                                .setSocketTimeout(10000)
                );

        RestClient restClient = builder.build();

        // Transport und Client
        RestClientTransport transport = new RestClientTransport(restClient, new JacksonJsonpMapper());

        return new ElasticsearchClient(transport);
    }
}

    
