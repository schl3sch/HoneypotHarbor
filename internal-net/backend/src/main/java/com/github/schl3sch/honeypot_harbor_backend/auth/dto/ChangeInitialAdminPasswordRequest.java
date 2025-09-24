package com.github.schl3sch.honeypot_harbor_backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ChangeInitialAdminPasswordRequest {

    private String email;
    private String currentPassword;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 15, message = "Password needs to be between 6-15 characters")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@.#$!%^&*.?]).*$",
            message = "Password must include lowercase, uppercase, number, and special character"
    )
    private String newPassword;

    @NotBlank(message = "Password confirmation is required")
    private String confirmationPassword;

}
