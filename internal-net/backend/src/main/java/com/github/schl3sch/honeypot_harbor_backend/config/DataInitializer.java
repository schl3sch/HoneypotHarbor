package com.github.schl3sch.honeypot_harbor_backend.config;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.github.schl3sch.honeypot_harbor_backend.user.model.Role;
import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import com.github.schl3sch.honeypot_harbor_backend.user.UserRepository;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    @Value("${ADMIN_PASSWORD}")
    private String adminPassword;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner initAdmin() {
        return args -> {
            if (userRepository.findByEmail("admin").isEmpty()) {
                User admin = User.builder()
                        .firstname("Admin")
                        .lastname("Admin")
                        .email("admin")
                        .password(passwordEncoder.encode(adminPassword))
                        .role(Role.ADMIN)
                        .build();
                userRepository.save(admin);
                System.out.println("Initial ADMIN user created: username=admin, password=admin");
            }
        };
    }
}
