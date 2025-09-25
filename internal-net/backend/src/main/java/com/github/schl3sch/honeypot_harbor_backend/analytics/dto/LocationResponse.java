package com.github.schl3sch.honeypot_harbor_backend.analytics.dto;

public class LocationResponse {
    private double lat;
    private double lon;
    private long count;

    public LocationResponse(double lat, double lon, long count) {
        this.lat = lat;
        this.lon = lon;
        this.count = count;
    }

    public double getLat() {
        return lat;
    }
    public double getLon() {
        return lon;
    }
    public long getCount() {
        return count;
    }
}
