package com.github.schl3sch.honeypot_harbor_backend.auth.controller;

import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationRequest;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationResponse;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.ChangeInitialAdminPasswordRequest;
import com.github.schl3sch.honeypot_harbor_backend.auth.service.AuthenticationService;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.RegisterRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthenticationController {

    private final AuthenticationService service;

    @PostMapping("/register")
    public ResponseEntity<AuthenticationResponse> register(
            @RequestBody @Valid RegisterRequest request
    ) {
        return ResponseEntity.ok(service.register(request));
    }

    @PostMapping("/authenticate")
    public ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody AuthenticationRequest request
    ) {
        return ResponseEntity.ok(service.authenticate(request));
    }

    @GetMapping("/check-change-password")
    public ResponseEntity<String> checkChangePassword(
            @RequestParam String email
    ) {
        service.checkIfInitialAdmin(email);
        return ResponseEntity.ok("Password change required");
    }

    @PostMapping("/change/password")
    public ResponseEntity<AuthenticationResponse> changePassword(
            @RequestBody ChangeInitialAdminPasswordRequest request
    ) {
        return ResponseEntity.ok(service.changeInitialAdminPassword(request));
    }
}
