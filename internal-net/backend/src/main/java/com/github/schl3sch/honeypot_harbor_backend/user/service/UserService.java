package com.github.schl3sch.honeypot_harbor_backend.user.service;

import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationResponse;
import com.github.schl3sch.honeypot_harbor_backend.auth.service.AuthenticationService;
import com.github.schl3sch.honeypot_harbor_backend.config.security.JwtService;
import com.github.schl3sch.honeypot_harbor_backend.user.UserRepository;
import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.ChangePasswordRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.security.Principal;

@Service
@RequiredArgsConstructor
public class UserService {
    private final PasswordEncoder passwordEncoder;
    private final UserRepository repository;
    private final JwtService jwtService;
    private final AuthenticationService authenticationService;

    public AuthenticationResponse changePassword(ChangePasswordRequest request, User user) {

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalStateException("Wrong password");
        }
        if (!request.getNewPassword().equals(request.getConfirmationPassword())) {
            throw new IllegalStateException("Password are not the same");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));

        repository.save(user);
        var jwtToken = jwtService.generateToken(user);

        authenticationService.revokeAllUserTokens(user);
        authenticationService.saveUserToken(user, jwtToken);

        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }
}