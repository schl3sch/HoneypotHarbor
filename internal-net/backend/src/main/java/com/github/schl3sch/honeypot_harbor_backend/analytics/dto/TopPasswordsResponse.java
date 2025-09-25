package com.github.schl3sch.honeypot_harbor_backend.analytics.dto;

public class TopPasswordsResponse {
    private String password;
    private long count;

    public TopPasswordsResponse(String password, long count) {
        this.password = password;
        this.count = count;
    }

    public String getPassword() {
        return password;
    }

    public long getCount() {
        return count;
    }
}
