package com.github.schl3sch.honeypot_harbor_backend.user.service;

import com.github.schl3sch.honeypot_harbor_backend.user.UserRepository;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.GetAllUsersResponse;
import com.github.schl3sch.honeypot_harbor_backend.user.model.Role;
import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

import java.security.Principal;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository repository;

    public List<GetAllUsersResponse> getAllUsers(String currentUserEmail) {
        return repository.findAll()
                .stream()
                .filter(user -> !currentUserEmail.equalsIgnoreCase(user.getEmail()))
                .map(user -> GetAllUsersResponse.builder()
                        .id(user.getId())
                        .firstname(user.getFirstname())
                        .lastname(user.getLastname())
                        .email(user.getEmail())
                        .role(user.getRole())
                        .build())
                .collect(Collectors.toList());
    }

    public void updateUserRole(Integer id, Role newRole) {
        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id " + id));

        user.setRole(newRole);
        repository.save(user);
    }
}