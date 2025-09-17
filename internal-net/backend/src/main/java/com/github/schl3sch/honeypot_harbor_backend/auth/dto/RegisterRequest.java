package com.github.schl3sch.honeypot_harbor_backend.auth.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {
    @NotBlank(message = "Firstname is required")
    @Size(min = 2, max = 15, message = "Firstname needs to be between 2-15 characters")
    private String firstname;

    @NotBlank(message = "Lastname is required")
    @Size(min = 2, max = 15, message = "Lastname needs to be between 2-15 characters")
    private String lastname;

    @NotBlank(message = "Email is required")
    @Email(message = "Please enter a valid email address")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 15, message = "Password needs to be between 6-15 characters")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@.#$!%^&*.?]).*$",
            message = "Password must include lowercase, uppercase, number, and special character"
    )
    private String password;

    @NotBlank(message = "Password confirmation is required")
    private String passwordConfirmation;
}
