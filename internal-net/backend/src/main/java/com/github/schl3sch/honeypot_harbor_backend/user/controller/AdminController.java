package com.github.schl3sch.honeypot_harbor_backend.user.controller;
import com.github.schl3sch.honeypot_harbor_backend.user.dto.GetAllUsersResponse;
import com.github.schl3sch.honeypot_harbor_backend.user.service.AdminService;
import com.github.schl3sch.honeypot_harbor_backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService service;

    @GetMapping("/users")
    public List<GetAllUsersResponse> getAllUsers() {
        return service.getAllUsers();
    }
}
