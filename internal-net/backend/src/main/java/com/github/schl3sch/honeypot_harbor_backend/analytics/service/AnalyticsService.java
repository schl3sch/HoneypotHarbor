package com.github.schl3sch.honeypot_harbor_backend.analytics.service;

import java.io.IOException;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.HoneypotResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.LocationResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.TopPasswordsResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.TopUsernamesResponse;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.CompositeAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.CompositeAggregationSource;
import co.elastic.clients.elasticsearch._types.aggregations.CompositeBucket;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final ElasticsearchClient client;

    public List<HoneypotResponse> getAllHoneypots() throws IOException {
        // Return all Honeypots (honeypot_id) that uploaded logs in Elasticsearch
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0)
            .aggregations("honeypots", a -> a
                .terms(t -> t
                    .field("honeypot_id.keyword")
                    .size(10))),
            Void.class
        );

        List<HoneypotResponse> honeypots = response.aggregations()
        .get("honeypots").sterms().buckets().array().stream()
        .map(bucket -> new HoneypotResponse(bucket.key().stringValue())).toList();

        return honeypots;
    }

    public List<JsonNode> getLogsForHoneypot(String honeypotId) throws IOException {
         // Get all logs from the specified Honeypot as JsonNodes
        SearchResponse<JsonNode> response = client.search(s -> s
            .index("cowrie-*")
            .query(q -> q.term(t -> t
                .field("honeypot_id.keyword")
                .value(honeypotId))).size(1000),
            JsonNode.class
        );

        // Return all JsonNodes
        return response.hits().hits().stream()
            .map(hit -> hit.source())
            .collect(Collectors.toList());
    }

    public List<LocationResponse> getLocationForHoneypot() throws IOException {
        // Get "lat" and "lon" fields as a composite aggregation (no duplicates and .docCount() available)
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0).aggregations("locations", a -> a
                .composite(c -> c.size(10000).sources(
                    List.of(
                        Map.of("lat", CompositeAggregationSource.of(cs -> cs.terms(t -> t.field("geoip.geo.location.lat")))),
                        Map.of("lon", CompositeAggregationSource.of(cs -> cs.terms(t -> t.field("geoip.geo.location.lon"))))
                    )))),
            Void.class
        );

        List<LocationResponse> results = new ArrayList<>();
        Aggregate agg = response.aggregations().get("locations");

        // For every (lat, lon) pair: Write "lat", "lon" and their count (frequency of their appearance in "response") into a LocationResponse and add to results
        if (agg.isComposite()) {
            CompositeAggregate composite = agg.composite();
            for (CompositeBucket bucket : composite.buckets().array()) {
                Double lat = bucket.key().get("lat").doubleValue();
                Double lon = bucket.key().get("lon").doubleValue();
                long count = bucket.docCount();
            
                if (lat != 0.0 && lon != 0.0) {
                    results.add(new LocationResponse(lat, lon, (int) count));
                }
            }
        }

        return results;
    }

    public List<TopUsernamesResponse> getTopUsernames() throws IOException {
        // Query top 10 used usernames in logs
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0)
            .aggregations("top_usernames", a -> a
                .terms(t -> t
                    .field("username.keyword")
                    .size(10))),
            Void.class
        );

        // Return the top 10 used usernames with the amount of uses in a List<TopUsernamesResponse>
        return response.aggregations().get("top_usernames").sterms().buckets().array().stream()
        .map(bucket -> new TopUsernamesResponse(bucket.key().stringValue(), bucket.docCount())).toList();
    }

    public List<TopPasswordsResponse> getTopPasswords() throws IOException {
        // Query top 10 used passwords in logs
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0)
            .aggregations("top_passwords", a -> a
                .terms(t -> t
                    .field("password.keyword")
                    .size(10))),
            Void.class
        );

        //Return the top 10 used passwords with the amount of uses in a List<TopPasswordsResponse>
        return response.aggregations()
        .get("top_passwords").sterms().buckets().array().stream()
        .map(bucket -> new TopPasswordsResponse(bucket.key().stringValue(), bucket.docCount())).toList();
    }

    public List<JsonNode> getAttacksToday() throws IOException {
        // Set startOfDay as midnight today
        Instant startOfDay = LocalDate.now()
            .atStartOfDay(ZoneId.systemDefault())
            .toInstant();

        // Query all logs where "timestamp" is today and track total hits
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0).trackTotalHits(t -> t.enabled(true))
            .query(q -> q
                .range(r -> r
                    .date(d -> d.field("timestamp")
                    .gte(startOfDay.toString()).lte("now")))),
            Void.class
        );

        // Set "count" to the tracked total hits from "response"
        long count = response.hits().total().value();
        
        // Build JSON from "count" and return
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode node = mapper.createObjectNode();
        node.put("count", count);

        return List.of((JsonNode) node);
    }

    public List<JsonNode> getAttacksAll() throws IOException {
        // Query all logs and track total hits
        SearchResponse<Void> response = client.search(s -> s
            .index("cowrie-*").size(0).trackTotalHits(t -> t.enabled(true))
            .query(q -> q.matchAll(m -> m)),
            Void.class
        );

        // Set "count" to the tracked total hits from "response"
        long count = response.hits().total().value();
        
        // Build a Json from "count" and return
        ObjectMapper mapper = new ObjectMapper();
        ObjectNode node = mapper.createObjectNode();
        node.put("count", count);

        return List.of((JsonNode) node);
    }

    public List<JsonNode> getAttacksOverTime() throws IOException {
        // Get all timestamps from all logs
        SearchResponse<JsonNode> response = client.search(s -> s
            .index("cowrie-*").size(10000).query(q -> q.matchAll(m -> m))
            .source(src -> src.filter(f -> f.includes("timestamp"))),
            JsonNode.class
        );

        // Return timestamps as a List<JsonNode>
        List<JsonNode> timestamps = response.hits().hits().stream()
            .map(hit -> hit.source()).filter(Objects::nonNull).toList();

        return timestamps;
    }

}