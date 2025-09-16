package com.github.schl3sch.honeypot_harbor_backend.config.security.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class ApiKeyFilter extends OncePerRequestFilter {

    @Value("${API_KEY}")
    private String apiKey;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String requestKey = request.getHeader("X-Api-Key");

        if (!apiKey.equals(requestKey)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("Forbidden: Invalid API Key");
            return;
        }

        filterChain.doFilter(request, response);
    }

    @Configuration
    @EnableWebSecurity
    @RequiredArgsConstructor
    public static class SecurityConfiguration {
        private final JwtAuthenticationFilter jwtAuthFilter;
        private final AuthenticationProvider authenticationProvider;
        private final ApiKeyFilter apiKeyFilter;
    
        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception{
    
            http
                    .csrf()
                    .disable()
                    .authorizeHttpRequests()
                    .requestMatchers("/api/v1/auth/**")
                    .permitAll()
                    .anyRequest()
                    .authenticated()
                    .and()
                    .sessionManagement()
                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    .authenticationProvider(authenticationProvider)
                    .addFilterBefore(apiKeyFilter, UsernamePasswordAuthenticationFilter.class)
                    .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
    
            return http.build();
        }
    }
}
