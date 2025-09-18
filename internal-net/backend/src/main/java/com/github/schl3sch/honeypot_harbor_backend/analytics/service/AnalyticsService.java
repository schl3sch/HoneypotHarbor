package com.github.schl3sch.honeypot_harbor_backend.analytics.service;

import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.HoneypotResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.LogResponse;
import com.github.schl3sch.honeypot_harbor_backend.analytics.dto.StatisticsResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    public List<HoneypotResponse> getAllHoneypots() {
        // TODO: Implement
        return List.of();
    }

    public List<LogResponse> getLogsForHoneypot(Long id) {
        // TODO: Implement
        return List.of();
    }

    public List<StatisticsResponse> getLocationForHoneypot() {
        // TODO: Implement
        return List.of();
    }

    public List<StatisticsResponse> getTopUsernames() {
        // TODO: Implement
        return List.of();
    }

    public List<StatisticsResponse> getTopPasswords() {
        // TODO: Implement
        return List.of();
    }

    public Long getAttacksToday() {
        // TODO: Implement
        return 0L;
    }

    public Long getAttacksAll() {
        // TODO: Implement
        return 0L;
    }

    public List<StatisticsResponse> getAttacksOverTime() {
        // TODO: Implement
        return List.of();
    }
}