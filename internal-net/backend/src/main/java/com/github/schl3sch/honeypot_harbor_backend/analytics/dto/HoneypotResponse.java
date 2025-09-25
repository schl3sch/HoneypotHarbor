package com.github.schl3sch.honeypot_harbor_backend.analytics.dto;

public class HoneypotResponse {

    private String honeypotId;
    
    public HoneypotResponse(String honeypotId) {
        this.honeypotId = honeypotId;
    }

    public String getHoneypotId() {
        return honeypotId;
    }
}

