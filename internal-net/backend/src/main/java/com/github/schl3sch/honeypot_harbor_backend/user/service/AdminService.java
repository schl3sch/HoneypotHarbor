package com.github.schl3sch.honeypot_harbor_backend.user.service;

import com.github.schl3sch.honeypot_harbor_backend.user.UserRepository;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.GetAllUsersResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

import java.security.Principal;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository repository;

    public List<GetAllUsersResponse> getAllUsers() {
        return repository.findAll()
                .stream()
                .map(user -> GetAllUsersResponse.builder()
                        .id(user.getId())
                        .firstname(user.getFirstname())
                        .lastname(user.getLastname())
                        .email(user.getEmail())
                        .role(user.getRole())
                        .build())
                .collect(Collectors.toList());
    }
}