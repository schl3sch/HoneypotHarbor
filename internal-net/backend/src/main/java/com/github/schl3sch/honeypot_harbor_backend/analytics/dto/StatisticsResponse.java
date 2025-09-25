package com.github.schl3sch.honeypot_harbor_backend.analytics.dto;

public class StatisticsResponse {
    private String timestamp;

    public StatisticsResponse(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getTimestamp() {
        return timestamp;
    }
}
