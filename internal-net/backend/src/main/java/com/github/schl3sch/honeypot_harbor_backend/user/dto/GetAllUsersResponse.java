package com.github.schl3sch.honeypot_harbor_backend.user.dto;

import com.github.schl3sch.honeypot_harbor_backend.user.model.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GetAllUsersResponse {
    private Integer id;
    private String firstname;
    private String lastname;
    private String email;
    private Role role;
}
