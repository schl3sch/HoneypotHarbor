package com.github.schl3sch.honeypot_harbor_backend.user.controller;

import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationResponse;
import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import com.github.schl3sch.honeypot_harbor_backend.user.service.UserService;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.ChangePasswordRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService service;

    @PostMapping("/change/password")
    public ResponseEntity<AuthenticationResponse> changePassword(
            @RequestBody ChangePasswordRequest request,
            Principal connectedUser
    ) {
        var response = service.changePassword(request, connectedUser);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/role")
    public ResponseEntity<Map<String, String>> getRole(Principal connectedUser) {
        var user = (User) ((UsernamePasswordAuthenticationToken) connectedUser).getPrincipal();
        return ResponseEntity.ok(Map.of("role", user.getRole().name()));
    }
}
