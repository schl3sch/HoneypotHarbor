package com.github.schl3sch.honeypot_harbor_backend.user;

import com.github.schl3sch.honeypot_harbor_backend.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
}
