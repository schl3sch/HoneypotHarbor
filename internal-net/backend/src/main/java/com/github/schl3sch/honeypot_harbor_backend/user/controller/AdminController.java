package com.github.schl3sch.honeypot_harbor_backend.user.controller;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.GetAllUsersResponse;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.UpdateUserRoleRequest;
import com.github.schl3sch.honeypot_harbor_backend.user.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService service;

    @GetMapping("/users")
    public List<GetAllUsersResponse> getAllUsers(
            Principal connectedUser
    ) {
        String currentUserEmail = connectedUser.getName();
        return service.getAllUsers(currentUserEmail);
    }

    @PutMapping("/users/{id}/role")
    public ResponseEntity<String> updateUserRole(
            @PathVariable Integer id,
            @RequestBody UpdateUserRoleRequest request
    ) {
        service.updateUserRole(id, request.getRole());
        return ResponseEntity.ok("Role updated successfully");
    }
}
