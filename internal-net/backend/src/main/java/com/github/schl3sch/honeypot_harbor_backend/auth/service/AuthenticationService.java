package com.github.schl3sch.honeypot_harbor_backend.auth.service;

import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationRequest;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.AuthenticationResponse;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.ChangeInitialAdminPasswordRequest;
import com.github.schl3sch.honeypot_harbor_backend.auth.dto.RegisterRequest;
import com.github.schl3sch.honeypot_harbor_backend.config.security.JwtService;
import com.github.schl3sch.honeypot_harbor_backend.exception.Exceptions;
import com.github.schl3sch.honeypot_harbor_backend.token.TokenRepository;
import com.github.schl3sch.honeypot_harbor_backend.token.model.TokenType;
import com.github.schl3sch.honeypot_harbor_backend.token.model.Token;
import com.github.schl3sch.honeypot_harbor_backend.user.model.Role;
import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import com.github.schl3sch.honeypot_harbor_backend.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository repository;
    private final TokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthenticationResponse register(RegisterRequest request) {
        if(repository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Something wrent wrong..");
        }
        if(!request.getPassword().equals(request.getPasswordConfirmation())){
            throw new IllegalArgumentException("Passwords do not match.");
        }
        var user = User.builder()
                .firstname(request.getFirstname())
                .lastname(request.getLastname())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .build();

        var savedUser = repository.save(user);
        var jwtToken = jwtService.generateToken(user);
        saveUserToken(savedUser, jwtToken);

        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }

    public AuthenticationResponse authenticate(AuthenticationRequest request) {

        var user = repository.findByEmail(request.getEmail())
                .orElseThrow();

        if ("admin".equals(request.getEmail()) && "admin".equals(request.getPassword())
                && passwordEncoder.matches("admin", user.getPassword())) {
            throw new Exceptions.MustChangePasswordException();
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        var jwtToken = jwtService.generateToken(user);

        revokeAllUserTokens(user);
        saveUserToken(user, jwtToken);

        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }

    public AuthenticationResponse changeInitialAdminPassword(ChangeInitialAdminPasswordRequest request) {

        var user = repository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalStateException("User not found"));

        if (!"admin".equals(request.getEmail()) || !passwordEncoder.matches("admin", user.getPassword())) {
            throw new IllegalStateException("Admin password has already been changed");
        }

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalStateException("Wrong current password");
        }

        if (!request.getNewPassword().equals(request.getConfirmationPassword())) {
            throw new IllegalStateException("New password and confirmation do not match");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        repository.save(user);

        var jwtToken = jwtService.generateToken(user);
        saveUserToken(user, jwtToken);

        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }

    public void saveUserToken(User user, String jwtToken) {
        var token = Token.builder()
                .user(user)
                .token(jwtToken)
                .tokenType(TokenType.BEARER)
                .expired(false)
                .revoked(false)
                .build();
        tokenRepository.save(token);
    }

    public void revokeAllUserTokens(User user) {
        var validUserTokens = tokenRepository.findAllValidTokenByUser(user.getId());
        if (validUserTokens.isEmpty()) {
            return;
        }
        validUserTokens.forEach(token -> {
            token.setExpired(true);
            token.setRevoked(true);
        });
        tokenRepository.saveAll(validUserTokens);
    }
}
