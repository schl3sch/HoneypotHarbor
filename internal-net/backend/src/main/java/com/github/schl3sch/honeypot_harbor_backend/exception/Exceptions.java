package com.github.schl3sch.honeypot_harbor_backend.exception;

public class Exceptions {
    public static class MustChangePasswordException extends RuntimeException {
        public MustChangePasswordException() {
            super("Initial admin must change password.");
        }
    }
}
