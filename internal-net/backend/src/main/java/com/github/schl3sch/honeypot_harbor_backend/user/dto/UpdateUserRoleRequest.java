package com.github.schl3sch.honeypot_harbor_backend.user.dto;

import com.github.schl3sch.honeypot_harbor_backend.user.model.Role;
import lombok.Data;

@Data
public class UpdateUserRoleRequest {
    private Role role;
}
