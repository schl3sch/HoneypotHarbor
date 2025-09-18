package com.github.schl3sch.honeypot_harbor_backend.analytics.controller;

import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.HoneypotResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.LogResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.StatisticsResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'ANALYST')")
public class AnalyticsController {
    private final AnalyticsService service;

    @GetMapping("/honeypots")
    public ResponseEntity<List<HoneypotResponse>> getHoneypots() {
        return ResponseEntity.ok(service.getAllHoneypots());
    }

    @GetMapping("/honeypots/{id}/logs")
    public ResponseEntity<List<LogResponse>> getLogsForHoneypot(@PathVariable Long id) {
        return ResponseEntity.ok(service.getLogsForHoneypot(id));
    }

    @GetMapping("/statistics/location")
    public ResponseEntity<List<StatisticsResponse>> getLocation() {
        return ResponseEntity.ok(service.getLocationForHoneypot());
    }

    @GetMapping("/statistics/top-usernames")
    public ResponseEntity<List<StatisticsResponse>> getTopUsernames() {
        return ResponseEntity.ok(service.getTopUsernames());
    }

    @GetMapping("/statistics/top-passwords")
    public ResponseEntity<List<StatisticsResponse>> getTopPasswords() {
        return ResponseEntity.ok(service.getTopPasswords());
    }

    @GetMapping("/statistics/attacks/today")
    public ResponseEntity<Long> getAttacksToday() {
        return ResponseEntity.ok(service.getAttacksToday());
    }

    @GetMapping("/statistics/attacks/all")
    public ResponseEntity<Long> getAttacksAll() {
        return ResponseEntity.ok(service.getAttacksAll());
    }

    @GetMapping("/statistics/attacks/time")
    public ResponseEntity<List<StatisticsResponse>> getAttacksOverTime() {
        return ResponseEntity.ok(service.getAttacksOverTime());
    }
}
