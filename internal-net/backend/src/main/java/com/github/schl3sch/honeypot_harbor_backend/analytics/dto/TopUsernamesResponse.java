package com.github.schl3sch.honeypot_harbor_backend.analytics.dto;

public class TopUsernamesResponse {
    private String username;
    private long count;

    public TopUsernamesResponse(String username, long count) {
        this.username = username;
        this.count = count;
    }

    public String getUsername() {
        return username;
    }

    public long getCount() {
        return count;
    }
}
