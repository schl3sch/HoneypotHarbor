package com.github.schl3sch.honeypot_harbor_backend.analytics.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.HoneypotResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.StatisticsResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.TopPasswordsResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.TopUsernamesResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.service.AnalyticsService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
public class AnalyticsController {
    private final AnalyticsService service;

    //@PreAuthorize("hasAnyRole('ADMIN', 'ANALYST')")
    @GetMapping("/honeypots")
    public ResponseEntity<List<HoneypotResponse>> getHoneypots() throws IOException {
        return ResponseEntity.ok(service.getAllHoneypots());
    }
    
    //@PreAuthorize("hasAnyRole('ADMIN', 'ANALYST')")
    @GetMapping("/honeypots/{id}/logs")
    public ResponseEntity<List<JsonNode>> getLogsForHoneypot(@PathVariable String id) throws IOException {
        return ResponseEntity.ok(service.getLogsForHoneypot(id));
    }

    @GetMapping("/statistics/location")
    public ResponseEntity<List<StatisticsResponse>> getLocation() {
        return ResponseEntity.ok(service.getLocationForHoneypot());
    }

    @GetMapping("/statistics/top-usernames")
    public ResponseEntity<List<TopUsernamesResponse>> getTopUsernames() throws IOException {
        return ResponseEntity.ok(service.getTopUsernames());
    }

    @GetMapping("/statistics/top-passwords")
    public ResponseEntity<List<TopPasswordsResponse>> getTopPasswords() throws IOException {
        return ResponseEntity.ok(service.getTopPasswords());
    }

    @GetMapping("/statistics/attacks/today")
    public ResponseEntity<Map<String, Long>> getAttacksToday() throws IOException {
        long count = service.getAttacksTodayCount();
        Map<String, Long> response = Map.of("count", count);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/statistics/attacks/all")
    public ResponseEntity<Map<String, Long>> getAttacksAll() throws IOException {
        long count = service.getAttacksAllCount();
        Map<String, Long> response = Map.of("count", count);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/statistics/attacks/time")
    public ResponseEntity<List<JsonNode>> getAttacksOverTime() throws IOException {
        return ResponseEntity.ok(service.getAttacksOverTime());
    }
}
