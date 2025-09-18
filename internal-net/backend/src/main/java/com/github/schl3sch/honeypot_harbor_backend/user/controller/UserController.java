package com.github.schl3sch.honeypot_harbor_backend.user.controller;

import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationResponse;
import com.github.schl3sch.honeypot_harbor_backend.user.UserService;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.ChangePasswordRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

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
}
